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
          
          noFilesToLint = (@source_files.length == 0)
          
          if Bake.options.lint_min >= 1 and Bake.options.lint_min >= @source_files.length
            noFilesToLint = true 
          end
          
          if Bake.options.lint_max >= 0 and Bake.options.lint_max < Bake.options.lint_min
            noFilesToLint = true 
          end
                    
          if noFilesToLint
            Bake.formatter.printInfo "Info: no files to lint"
          else
            @source_files = @source_files[Bake.options.lint_min..Bake.options.lint_max]    
            
            cmd = [compiler[:COMMAND]]
            cmd += compiler[:COMPILE_FLAGS]
              
            cmd += @include_array[:CPP]
            cmd += @define_array[:CPP]
              
            cmd += @tcs[:LINT_POLICY]
            
            cmd += @source_files
                   
            success, consoleOutput = ProcessHelper.run(cmd, false)
            process_result(cmd, consoleOutput, compiler[:ERROR_PARSER], "", success)
          end
        end
      end  
      
      def clean
      end
      
    end
  end
end
