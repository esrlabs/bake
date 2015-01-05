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
          Bake.formatter.printError("Command \"#{commandLine}\" failed", @config)
          puts "(executed in '#{@projectDir}')" if not Bake.options.verboseHigh
          raise SystemCommandFailed.new
        end
      end
          
    end
    
  end
end