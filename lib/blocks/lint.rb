require 'blocks/compile'

module Bake
  module Blocks
    class Lint < Compile
  
      def initialize(block, config, referencedConfigs, tcs)
        super(block,config, referencedConfigs, tcs)
      end
  
      def execute
        Dir.chdir(@projectDir) do
          compiler = @tcs[:COMPILER][:CPP]
          calcSources
          
          if Bake.options.lint_min >= 0 and Bake.options.lint_min >= @source_files.length
            Bake.formatter.printError "Error: lint_min is set to #{Bake.options.lint_min}, but only #{@source_files.length} file(s) are specified to lint"
            ExitHelper.exit(1) 
          end
          
          if Bake.options.lint_max >= 0 and Bake.options.lint_max >= @source_files.length
            Bake.formatter.printError "Error: lint_max is set to #{Bake.options.lint_max}, but only #{@source_files.length} file(s) are specified to lint"
            ExitHelper.exit(1) 
          end      
          
          @source_files = @source_files[Bake.options.lint_min..Bake.options.lint_max]    
          
          cmd = [compiler[:COMMAND]]
          cmd += compiler[:COMPILE_FLAGS]
            
          cmd += @include_array[:CPP]
          cmd += @define_array[:CPP]
            
          cmd += @tcs[:LINT_POLICY]
          
          cmd += @source_files
                  
          rd, wr = IO.pipe
          cmd << {:err=>wr,:out=>wr}
          success, consoleOutput = ProcessHelper.safeExecute() { sp = spawn(*cmd); ProcessHelper.readOutput(sp, rd, wr) }
          cmd.pop
  
          process_result(cmd, consoleOutput, compiler[:ERROR_PARSER], "", success)
        end
      end  
      
      def clean
      end
      
    end
  end
end
