module Bake
  
  module Blocks
  
    module HasExecuteCommand
      
      def executeCommand(commandLine)
        puts commandLine if not Bake.options.verboseLow
        puts "(executed in '#{@projectDir}')" if Bake.options.verboseHigh
        cmd_result = false
        begin
          Dir.chdir(@projectDir) do
            rd, wr = IO.pipe
            cmd = [commandLine]
            cmd << { :err=>wr, :out=>wr }
            cmd_result, consoleOutput = ProcessHelper.safeExecute() { sp = spawn(*cmd); ProcessHelper.readOutput(sp, rd, wr) }
            puts consoleOutput
            
          # bei makefile.... - must be tested!
            #cmd_result = ProcessHelper.spawnProcess(commandLine + " 2>&1")
          end
  
        rescue
        end
          
        if (cmd_result == false)
          if Bake::IDEInterface.instance # todo
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