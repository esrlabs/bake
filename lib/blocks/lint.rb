require 'blocks/compile'

module Bake
  module Blocks
    class Lint < Compile
  
      def initialize(block, config, referencedConfigs, tcs)
        super(block,config, referencedConfigs, tcs)
      end
  
      def execute
        success = true
        Dir.chdir(@projectDir) do
          compiler = @tcs[:COMPILER][:CPP]
          calcSources
          
          noFilesToLint = (@source_files.length == 0)
          
          if Bake.options.lint_min >= 1 and Bake.options.lint_min >= @source_files.length
            noFilesToLint = true 
          end
          
          if Bake.options.lint_max >= 0 and Bake.options.lint_max < Bake.options.lint_min
            noFilesToLint = true 
          end
                    
          if noFilesToLint
            Bake.formatter.printInfo("No files to lint", @config)
          else
            @source_files = @source_files[Bake.options.lint_min..Bake.options.lint_max]    
            
            cmd = [compiler[:COMMAND]]
            cmd += compiler[:COMPILE_FLAGS]
              
            cmd += @include_array[:CPP]
            cmd += @define_array[:CPP]
              
            cmd += @tcs[:LINT_POLICY]
            
            cmd += @source_files
                   
            printCmd(cmd, "Linting #{@source_files.length} file(s)...", nil, false)
            success, consoleOutput = ProcessHelper.run(cmd, false)
            process_result(cmd, consoleOutput, compiler[:ERROR_PARSER], "Linting...", nil, success)
          end
        end
        return success
      end  
      
      def clean
        return true
      end
      
    end
  end
end
