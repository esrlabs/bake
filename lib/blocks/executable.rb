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
      
      def calcCmdlineFile()
        @exe_name + ".cmdline"
      end
      
      def calcMapFile
        @mapfile = nil
        if (not Bake.options.docu) and (not Bake.options.lint) and (not @config.mapFile.nil?)
          if @config.mapFile.name == ""
            @mapfile = @exe_name.chomp(File.extname(@exe_name)) + ".map"
          else
            @mapfile = @config.mapFile.name 
          end
        end
      end
      
      def depHasError(block)
        block.dependencies.each do |dep|
          subBlock = Blocks::ALL_BLOCKS[dep]
          return true unless subBlock.result
          return depHasError(subBlock)
        end
        return false
      end

      def needed?(libs)
        return false if Bake.options.prepro
        return "because linkOnly was specified" if Bake.options.linkOnly
        
        # exe
        return "because executable does not exist" if not File.exists?(@exe_name)

        eTime = File.mtime(@exe_name)
        
        # linkerscript
        if @linker_script
          return "because linker script does not exist - will most probably result in an error" if not File.exists?(@linker_script)
          return "because linker script is newer than executable" if eTime < File.mtime(@linker_script)
        end
        
        # sources
        @compileBlock.objects.each do |obj|
          return "because object #{obj} does not exist" if not File.exists?(obj)
          return "because object #{obj} is newer than executable" if eTime < File.mtime(obj)
        end
        
        # libs
        libs.each do |lib|
          return "because library #{lib} does not exist" if not File.exists?(lib)
          return "because library #{lib} is newer than executable" if eTime < File.mtime(lib)
        end
        false
      end
            
      def execute
        
        Dir.chdir(@projectDir) do
          return false if depHasError(@block)
          
          libs, linker_libs_array = LibElements.calc_linker_lib_string(@block, @tcs)
          
          cmdLineCheck = false
          cmdLineFile = calcCmdlineFile()
          reason = needed?(libs)
          if not reason
            cmdLineCheck = true
            reason = config_changed?(cmdLineFile)
          end
          return unless reason
          


          linker = @tcs[:LINKER]
    
          cmd = Utils.flagSplit(linker[:COMMAND], false) # g++
          cmd += linker[:MUST_FLAGS].split(" ")
          cmd += Bake::Utils::flagSplit(linker[:FLAGS],true)
          
            
          cmd << linker[:EXE_FLAG]
          if linker[:EXE_FLAG_SPACE]
            cmd << @exe_name
          else
            cmd[cmd.length-1] += @exe_name
          end

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
          
          return if cmdLineCheck and BlockBase.isCmdLineEqual?(cmd, cmdLineFile)
          
          BlockBase.prepareOutput(@exe_name)
          
          printCmd(cmdLinePrint, "Linking #{@exe_name}", reason, false)
          success, consoleOutput = ProcessHelper.run(cmd, false, false, outPipe)
          BlockBase.writeCmdLineFile(cmd, cmdLineFile) if success
          process_result(cmdLinePrint, consoleOutput, linker[:ERROR_PARSER], nil, reason, success)
    
          check_config_file()
        end
        
      end
      
      def clean
        Dir.chdir(@projectDir) do
          if File.exist?@output_dir 
            puts "Deleting folder #{@output_dir}" if Bake.options.verbose >= 2
            FileUtils.rm_rf(@output_dir)
          end
        end unless Bake.options.filename
      end
      
    end
    
  end
end