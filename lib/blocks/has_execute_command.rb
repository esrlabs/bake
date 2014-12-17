module Bake
  
  module Blocks
  
    module HasExecuteCommand
      
      def executeCommand(commandLine, ignoreStr=nil)
        puts commandLine if not Bake.options.verboseLow
        puts "(executed in '#{@projectDir}')" if Bake.options.verboseHigh
        cmd_result = false
        output = ""
        begin
          Dir.chdir(@projectDir) do
            cmd_result, output = ProcessHelper.run([commandLine], true)
          end
        rescue Exception=>e
          puts e.message
          puts e.backtrace if Bake.options.debug
        end
          
        if (cmd_result == false and (not ignoreStr or not output.include?ignoreStr))
          if Bake::IDEInterface.instance
            err_res = ErrorDesc.new
            err_res.file_name = @config.file_name.to_s
            err_res.line_number = @config.line_number
            err_res.severity = ErrorParser::SEVERITY_ERROR
            err_res.message = "Command \"#{commandLine}\" failed"
            Bake::IDEInterface.instance.set_errors([err_res])
          end
          Bake.formatter.printError "Error: command \"#{commandLine}\" failed"
          puts "(executed in '#{@projectDir}')" if not Bake.options.verboseHigh
          raise SystemCommandFailed.new
        end
      end
          
    end
    
  end
end