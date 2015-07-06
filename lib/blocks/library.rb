require 'blocks/blockBase'

module Bake
  
  module Blocks
    
    class Library < BlockBase
      
      def initialize(block, config, referencedConfigs, tcs, compileBlock)
        super(block,config, referencedConfigs, tcs)
        @compileBlock = compileBlock
        
        block.set_library(self)
      end
      
      def archive_name()
        @archive_name ||= File.join([@output_dir, "lib#{@projectName}.a"])
      end
  
      def calcCmdlineFile()
        archive_name + ".cmdline"
      end
      
      def needed?
        return false if Bake.options.linkOnly
        return false if Bake.options.prepro
        
        # lib
        return "because library does not exist" if not File.exists?(archive_name)

        aTime = File.mtime(archive_name)
                
        # sources
        @compileBlock.objects.each do |obj|
          return "because object #{obj} does not exist" if not File.exists?(obj)
          return "because object #{obj} is newer than executable" if aTime < File.mtime(obj)
        end
        
        false
      end
      
      def execute

        Dir.chdir(@projectDir) do
          cmdLineCheck = false
          cmdLineFile = calcCmdlineFile()
          reason = needed?
          if not reason
            cmdLineCheck = true
            reason = config_changed?(cmdLineFile)
          end
          return true unless reason
          archiver = @tcs[:ARCHIVER]
       
          cmd = Utils.flagSplit(archiver[:COMMAND], false) # ar
          cmd += Bake::Utils::flagSplit(archiver[:FLAGS],true) # --all_load
          cmd += archiver[:ARCHIVE_FLAGS].split(" ")
            
          if archiver[:ARCHIVE_FLAGS_SPACE]
            cmd << archive_name
          else
            cmd[cmd.length-1] += archive_name
          end
          
          cmd += @compileBlock.objects
        
          return true if cmdLineCheck and BlockBase.isCmdLineEqual?(cmd, cmdLineFile)
        
          BlockBase.prepareOutput(archive_name)
          
          BlockBase.writeCmdLineFile(cmd, cmdLineFile)
          success, consoleOutput = ProcessHelper.run(cmd, false, false)
          process_result(cmd, consoleOutput, archiver[:ERROR_PARSER], "Creating #{archive_name}", reason, success)
         
          check_config_file()
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