require 'blocks/blockBase'

module Bake
  
  module Blocks
    
    class Executable < BlockBase
      
      def initialize(block, config, referencedConfigs, tcs, compileBlock)
        super(block, config, referencedConfigs, tcs)
        @compileBlock = compileBlock

        calcArtifactName
        calcMapFile
        calcLinkerScript

      end
      
      def calcLinkerScript
        @linker_script = @config.linkerScript.nil? ? nil : @block.convPath(@config.linkerScript) 
      end
      
      def calcArtifactName
        if not @config.artifactName.nil? and @config.artifactName.name != "" 
          baseFilename = @config.artifactName.name
        else
          baseFilename = "#{@projectName}#{@tcs[:LINKER][:OUTPUT_ENDING]}"
        end
        @exe_name ||= File.join([@output_dir, baseFilename])
      end
      
      def calcMapFile
        @mapfile = nil
        if (not Bake.options.lint) and (not @config.mapFile.nil?)
          if @config.mapFile.name == ""
            @mapfile = @exe_name.chomp(File.extname(@exe_name)) + ".map"
          else
            @mapfile = @config.mapFile.name 
          end
        end
      end
      

      def needed?(libs)
        return true if Bake.options.linkOnly
        return false if Bake.options.prepro
        
        # exe
        return true if not File.exists?(@exe_name)
        eTime = File.mtime(@exe_name)
          
        # config
        return true if eTime < File.mtime(@config.file_name)
        return true if eTime < Bake::Config.defaultToolchainTime
        
        # linkerscript
        if @linker_script
          return true if not File.exists?(@linker_script) or eTime < File.mtime(@linker_script)
        end
        
        # sources
        @compileBlock.objects.each do |obj|
          return true if not File.exists?(obj) or eTime < File.mtime(obj)
        end
        
        # libs
        libs.each do |lib|
          return true if not File.exists?(lib) or File.mtime(lib) > eTime
        end
        false
      end
            
      def execute
        
        Dir.chdir(@projectDir) do
          
          libs, linker_libs_array = LibElements.calc_linker_lib_string(@block, @tcs)
          return unless needed?(libs)
          
          prepareOutput(@exe_name)

          linker = @tcs[:LINKER]
    
          cmd = Utils.flagSplit(linker[:COMMAND], false) # g++
          cmd += linker[:MUST_FLAGS].split(" ")
          cmd += Bake::Utils::flagSplit(linker[:FLAGS],true)
          cmd << linker[:EXE_FLAG]
          cmd << @exe_name # -o debug/x.exe
          cmd += @compileBlock.objects
          cmd << linker[:SCRIPT] if @linker_script # -T
          cmd << @linker_script if @linker_script # xy/xy.dld
          cmd += linker[:MAP_FILE_FLAG].split(" ") if @mapfile # -Wl,-m6
          if not linker[:MAP_FILE_PIPE] and @mapfile 
            cmd[cmd.length-1] << @mapfile 
          end
          cmd += Bake::Utils::flagSplit(linker[:LIB_PREFIX_FLAGS],true) # "-Wl,--whole-archive "
          cmd += linker_libs_array
          cmd += Bake::Utils::flagSplit(linker[:LIB_POSTFIX_FLAGS],true) # "-Wl,--no-whole-archive "
    
          mapfileStr = (@mapfile and linker[:MAP_FILE_PIPE]) ? " >#{@mapfile}" : ""
    
          # pre print because linking can take much time
          cmdLinePrint = cmd.dup
          outPipe = (@mapfile and linker[:MAP_FILE_PIPE]) ? "#{@mapfile}" : nil
          cmdLinePrint << "> #{outPipe}" if outPipe
          
          printCmd(cmdLinePrint, "Linking #{@exe_name}", false)
          success, consoleOutput = ProcessHelper.run(cmd, false, false, outPipe)
          process_result(cmdLinePrint, consoleOutput, linker[:ERROR_PARSER], nil, success)
    
          check_config_file()
        end
        
      end
      
      def clean
        Dir.chdir(@projectDir) do
          if File.exist?@output_dir 
            puts "Deleting folder #{@output_dir}" if Bake.options.verboseHigh
            FileUtils.rm_rf(@output_dir)
          end
        end unless Bake.options.filename
      end
      
    end
    
  end
end