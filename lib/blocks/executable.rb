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
      
      def ignore?
        Bake.options.prepro
      end
      
      def needed?(libs)
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
          childs = getBlocks(:childs)
          return false if childs.any? { |b| b.result == false }
            
          allSources = []
          (childs + [@block]).each do |b|
            Dir.chdir(b.projectDir) do
              b.getCompileBlocks.each do |c|
                allSources += c.calcSources(true, true).map! { |s| File.expand_path(s) }
              end
            end
          end
          duplicateSources = allSources.group_by{ |e| e }.select { |k, v| v.size > 1 }.map(&:first)
          duplicateSources.each do |d|
            Bake.formatter.printWarning("Source compiled more than once: #{d}") 
          end
                    
          libs, linker_libs_array = LibElements.calc_linker_lib_string(@block, @tcs)
          
          cmdLineCheck = false
          cmdLineFile = calcCmdlineFile()
          
          return true if ignore?
          reason = needed?(libs)
          if not reason
            cmdLineCheck = true
            reason = config_changed?(cmdLineFile)
          end
            
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
          
          if cmdLineCheck and BlockBase.isCmdLineEqual?(cmd, cmdLineFile)
            success = true
          else
            ToCxx.linkBlock
            
            BlockBase.prepareOutput(@exe_name)
            
            printCmd(cmdLinePrint, "Linking #{@exe_name}", reason, false)
            BlockBase.writeCmdLineFile(cmd, cmdLineFile)
            success, consoleOutput = ProcessHelper.run(cmd, false, false, outPipe)
            process_result(cmdLinePrint, consoleOutput, linker[:ERROR_PARSER], nil, reason, success)
      
            check_config_file()
          end
          
          Bake::Bundle.instance.addBinary(@exe_name, @linker_script, isMainProject? ? @config : nil)
          
          return success
        end
      end
      
      def clean
        Dir.chdir(@projectDir) do
          if File.exist?@output_dir 
            puts "Deleting folder #{@output_dir}" if Bake.options.verbose >= 2
            FileUtils.rm_rf(@output_dir)
          end
        end unless Bake.options.filename
        return true
      end
      
    end
    
  end
end