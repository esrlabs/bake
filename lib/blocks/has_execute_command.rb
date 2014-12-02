module Bake
  
  module Blocks
  
    module HasExecuteCommand
      
      def executeCommand(commandLine)
        puts commandLine + (Bake.options.verboseHigh ? "\n(executed in '#{@projectDir}')" : "")
        cmd_result = false
        begin
          rd, wr = IO.pipe
          cmd = [commandLine]
          cmd << { :err=>wr, :out=>wr }
          cmd_result, consoleOutput = ProcessHelper.safeExecute() { sp = spawn(*cmd); ProcessHelper.readOutput(sp, rd, wr) }
          puts consoleOutput
          
        # bei makefile.... - must be tested!
        #  cmd_result = ProcessHelper.spawnProcess(commandLine + " 2>&1")
  
        rescue
        end
          
  
  
        if (cmd_result == false)
          if Rake.application.idei # todo
            err_res = ErrorDesc.new
            err_res.file_name = @config.file_name.to_s
            err_res.line_number = @config.line_number
            err_res.severity = ErrorParser::SEVERITY_ERROR
            err_res.message = "Command \"#{commandLine}\" failed"
            Rake.application.idei.set_errors([err_res])
          end
          Bake.formatter.printError "Error: command \"#{commandLine}\" failed" + (Bake.options.verboseHigh ? "" : "\n(executed in '#{@project_dir}')")
          # TODO raise SystemCommandFailed.new
        end
      end
          
    end
    
  end
end