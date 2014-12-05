module Bake
  module Blocks
    
    class BlockBase

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
          rescue Exception
            # TODO: verbose error message
          end
        end
      end
            
      def prepareOutputDir(filename)
        if File.exists?(filename)
          FileUtils.rm(filename)
        else 
          FileUtils.mkdir_p(File.dirname(filename))
        end        
      end
      
      def calcOutputDir
        if @tcs[:OUTPUT_DIR] != nil
          p = @block.convPath(@tcs[:OUTPUT_DIR])
          @output_dir = p
        elsif @projectName == Bake.options.main_project_name and @config.name == Bake.options.build_config 
          @output_dir = Bake.options.build_config
        else
          @output_dir = Bake.options.build_config + "_" + Bake.options.main_project_name
        end
      end
      
      def printCmd(cmd, alternate, showPath)
        @lastCommand = cmd
        if showPath or Bake.options.verboseHigh or (alternate.nil? and not Bake.options.verboseLow)
          @printedCmdAlternate = false
          exedIn = ""
          exedIn = "\n(executed in '#{@projectDir}')" if (showPath or Bake.options.verboseHigh)
          puts "" if Bake.options.verboseHigh # todo: why?
          if cmd.is_a?(Array)
            puts cmd.join(' ') + exedIn
          else
            puts cmd + exedIn
          end
        else
          @printedCmdAlternate = true
          puts alternate if not Bake.options.verboseLow
        end
        @lastCommand = cmd
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
                  console_output_VS << error_parser.makeVsError(l, d) << "\n"
                  descCounter = descCounter + 1
                end
                console_output = console_output_VS
              end
  
              if Bake::GCCLintErrorParser === error_parser # hack: need to know if lint is enabled...
                ret = error_descs.any? { |e| e.severity != ErrorParser::SEVERITY_OK }
              else
                ret = error_descs.any? { |e| e.severity == ErrorParser::SEVERITY_ERROR }
              end
  
              console_output.gsub!(/[\r]/, "")
              Bake.formatter.format(console_output, error_descs, error_parser)
  
              Bake::IDEInterface.instance.set_errors(error_descs)
            rescue Exception => e
              Bake.formatter.printWarning "Parsing output failed (maybe language not set to English?): " + e.message
              puts "Original output:"
              puts console_output
              raise e
            end
          else
            puts console_output # fallback
          end
        end
        ret
      end
      
      def process_result(cmd, console_output, error_parser, alternate, success)
        hasError = (success == false)
        if (cmd != @lastCommand) or (@printedCmdAlternate and hasError)
          printCmd(cmd, alternate, (hasError and not Bake.options.lint))
        end
        errorPrinted = process_console_output(console_output, error_parser)
  
        if hasError
          if not errorPrinted
            Bake.formatter.printError "Error: system command failed"
            res = ErrorDesc.new
            res.file_name = @project_dir
            res.line_number = 0
            res.message = "Unknown error, see log output. Maybe the bake error parser has to be updated..."
            res.severity = ErrorParser::SEVERITY_ERROR
            Bake::IDEInterface.instance.set_errors([res])
          end
        end
        if hasError or errorPrinted
          raise SystemCommandFailed.new
        end
      end      
      
      
      
      
      
          

#
#@lib_elements.sort.each do |x|
#  v = x[1]
#  elem = 0
#  while elem < v.length do 
#    bbModule.main_content.add_lib_elements([v[elem..elem+1]])
#    elem = elem + 2
#  end
#end
      
      
      
            
    end
    
  end
  
  
end