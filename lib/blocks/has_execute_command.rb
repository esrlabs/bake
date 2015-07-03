module Bake
  
  module Blocks
  
    module HasExecuteCommand
      
      def executeCommand(commandLine, ignoreStr=nil, exitCodeArray = [0])
        puts commandLine if Bake.options.verbose >= 1
        puts "(executed in '#{@projectDir}')" if Bake.options.verbose >= 3
        cmd_result = false
        output = ""
        begin
          Dir.chdir(@projectDir) do
            cmd_result, output = ProcessHelper.run([commandLine], true, true, nil, exitCodeArray)
          end
        rescue Exception=>e
          puts e.message
          puts e.backtrace if Bake.options.debug
        end
          
        if (cmd_result == false and (not ignoreStr or not output.include?ignoreStr))
          Bake.formatter.printError("Command \"#{commandLine}\" failed", @config)
          puts "(executed in '#{@projectDir}')" if Bake.options.verbose >= 3
          raise SystemCommandFailed.new
        end
        return cmd_result
      end
          
    end
    
  end
end