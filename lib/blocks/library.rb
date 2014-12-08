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
        
        return true if not File.exist?(archive_name)
        aTime = File.mtime(archive_name)
        return true if aTime < File.mtime(@config.file_name)
        return true if aTime < Bake::Config.defaultToolchainTime
        @compileBlock.objects.each do |obj|
          return true if not File.exists?(obj) or aTime < File.mtime(obj)
        end
        false
      end
      
      def execute

        Dir.chdir(@projectDir) do
          return unless needed?
          
          prepareOutputDir(archive_name)
        
          archiver = @tcs[:ARCHIVER]
       
          cmd = [archiver[:COMMAND]] # ar
          cmd += Bake::Utils::flagSplit(archiver[:FLAGS],true) # --all_load
          cmd += archiver[:ARCHIVE_FLAGS].split(" ")
          cmd << archive_name
          cmd += @compileBlock.objects
          
          # todo: always these lines? could be made dry  
          rd, wr = IO.pipe
          cmd << { :err=>wr, :out=>wr }
          success, consoleOutput = ProcessHelper.safeExecute() { sp = spawn(*cmd); ProcessHelper.readOutput(sp, rd, wr) }
          cmd.pop
         
          process_result(cmd, consoleOutput, archiver[:ERROR_PARSER], "Creating #{archive_name}", success)
         
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