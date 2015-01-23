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
  
      def needed?
        return false if Bake.options.linkOnly
        return false if Bake.options.prepro
        
        # lib
        return "because library does not exist" if not File.exists?(archive_name)

        aTime = File.mtime(archive_name)
        
        # config
        return "because config file has been changed" if aTime < File.mtime(@config.file_name)
        return "because DefaultToolchain has been changed" if aTime < Bake::Config.defaultToolchainTime
                
        # sources
        @compileBlock.objects.each do |obj|
          return "because object #{obj} does not exist" if not File.exists?(obj)
          return "because object #{obj} is newer than executable" if aTime < File.mtime(obj)
        end
        
        false
      end
      
      def execute

        Dir.chdir(@projectDir) do
          reason = needed?
          return unless reason
          
          prepareOutput(archive_name)
        
          archiver = @tcs[:ARCHIVER]
       
          cmd = Utils.flagSplit(archiver[:COMMAND], false) # ar
          cmd += Bake::Utils::flagSplit(archiver[:FLAGS],true) # --all_load
          cmd += archiver[:ARCHIVE_FLAGS].split(" ")
          cmd << archive_name
          cmd += @compileBlock.objects
          
          success, consoleOutput = ProcessHelper.run(cmd, false, false)
          process_result(cmd, consoleOutput, archiver[:ERROR_PARSER], "Creating #{archive_name}", reason, success)
         
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