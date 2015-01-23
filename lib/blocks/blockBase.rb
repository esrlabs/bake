module Bake
  module Blocks
    
    class BlockBase

      attr_reader :tcs
      
      def initialize(block, config, referencedConfigs, tcs)
        @block = block
        @config = config
        @referencedConfigs = referencedConfigs
        @projectName = config.parent.name
        @projectDir = config.get_project_dir
        @tcs = tcs
        @config_date = Time.now
        
        @printedCmdAlternate = false
        @lastCommand = nil
        
        calcOutputDir
      end

      def check_config_file()
        if File.exists?(@config.file_name) and File.mtime(@config.file_name) > @config_date
          begin
            FileUtils.touch(@config.file_name)
          rescue Exception=>e
            if Bake.options.verboseHigh
              Bake.formatter.printWarning("Could not touch #{@config.file_name}: #{e.message}", @config.file_name)              
            end
          end
        end
      end
            
      def prepareOutput(filename)
        begin
          if File.exists?(filename)
            FileUtils.rm(filename)
          else 
            FileUtils.mkdir_p(File.dirname(filename))
          end
        rescue Exception => e
          if Bake.options.debug
            puts e.message
            puts e.backtrace
          end
        end        
      end
      
      def calcOutputDir
        if @tcs[:OUTPUT_DIR] != nil
          p = @block.convPath(@tcs[:OUTPUT_DIR])
          @output_dir = p
        elsif @projectName == Bake.options.main_project_name and @config.name == Bake.options.build_config 
          @output_dir = Bake.options.build_config
        else
          @output_dir = @config.name + "_" + Bake.options.main_project_name + "_" + Bake.options.build_config
        end
      end
      
      def printCmd(cmd, alternate, reason, forceVerbose)
        
        if (cmd == @lastCommand)
          if (Bake.options.verboseHigh or (@printedCmdAlternate and not forceVerbose))
            return
          end
        end
        
        @lastCommand = cmd
        
        return if Bake.options.verboseLow and not forceVerbose

        if forceVerbose or Bake.options.verboseHigh or not alternate
          @printedCmdAlternate = false
          if Bake.options.verboseHigh
            puts "" # for A.K. :-)  
            exedIn = "\n(executed in '#{@projectDir}')"
            because = reason ? "\n(#{reason})" : ""
          else
            exedIn = ""
            because = ""
          end
          
          if cmd.is_a?(Array)
            puts cmd.join(' ') + exedIn + because
          else
            puts cmd + exedIn + because
          end
        else
          @printedCmdAlternate = true
          puts alternate
        end

      end
      
      def process_console_output(console_output, error_parser)
        ret = false
        if not console_output.empty?
          if error_parser
            begin
              error_descs, console_output_full = error_parser.scan_lines(console_output, @projectDir)
  
              console_output = console_output_full if Bake.options.consoleOutput_fullnames
              
              if Bake.options.consoleOutput_visualStudio
                console_output_VS = ""
                descCounter = 0
                console_output.each_line do |l|
                  d = error_descs[descCounter]
                  console_output_VS << error_parser.makeVsError(l.rstrip, d) << "\n"
                  descCounter = descCounter + 1
                end
                console_output = console_output_VS
              end
  
              if Bake.options.lint
                # ignore error output
              else
                ret = error_descs.any? { |e| e.severity == ErrorParser::SEVERITY_ERROR }
              end
  
              console_output.gsub!(/[\r]/, "")
              Bake.formatter.format(console_output, error_descs, error_parser)
  
              Bake::IDEInterface.instance.set_errors(error_descs)
            rescue Exception => e
              Bake.formatter.printWarning("Parsing output failed (maybe language not set to English?): " + e.message)
              Bake.formatter.printWarning("Original output:")
              Bake.formatter.printWarning(console_output)
              raise e
            end
          else
            puts console_output # fallback
          end
        end
        ret
      end
      
      def process_result(cmd, console_output, error_parser, alternate, reason, success)
        hasError = (success == false)
        printCmd(cmd, alternate, reason, (hasError and not Bake.options.lint))
        errorPrinted = process_console_output(console_output, error_parser)
        
        if hasError and not errorPrinted
          Bake.formatter.printError("System command failed", @projectDir)
        end
        if hasError or errorPrinted
          raise SystemCommandFailed.new
        end
      end      
      
    end
    
  end
end
