require 'imported/buildingblocks/source_library'

module Bake
  class Lint < SourceLibrary

    def initialize(name)
      super(name)
      @lint_max = -1
      @lint_min = -1
    end

    def set_lint_min(x)
      @lint_min = x
      self
    end
    
    def set_lint_max(x)
      @lint_max = x
      self
    end
    
    def get_task_name()
      @task_name ||= File.join([@output_dir, "#{@name}_lint"])
    end    
    
    def convert_to_rake()
      compiler = @tcs[:COMPILER][:CPP]
      
      res = typed_file_task Rake::Task::LINT, get_task_name do
        dir = @project_dir
        
        Dir.chdir(dir) do
          srcs = calc_sources_to_build.keys
          
          if @lint_min >= 0 and @lint_min >= srcs.length
            Bake.formatter.printError "Error: lint_min is set to #{@lint_min}, but only #{srcs.length} file(s) are specified to lint"
            ExitHelper.exit(1) 
          end
          
          if @lint_max >= 0 and @lint_max >= srcs.length
            Bake.formatter.printError "Error: lint_max is set to #{@lint_max}, but only #{srcs.length} file(s) are specified to lint"
            ExitHelper.exit(1) 
          end      
          
          @lint_min = 0 if @lint_min < 0
          @lint_max = -1 if @lint_max < 0
          srcs = srcs[@lint_min..@lint_max]    

          cmd = [compiler[:COMMAND]]
          cmd += compiler[:COMPILE_FLAGS]
            
          cmd += @include_string[:CPP]
          cmd += @define_string[:CPP]
            
          cmd += @tcs[:LINT_POLICY]
          
          cmd += srcs
  
          if Bake::Utils.old_ruby?
            cmd.map! {|c| ((c.include?" ") ? ("\""+c+"\"") : c )}
            
            cmdLine = cmd.join(" ")
            if cmdLine.length > 8000
              inputName = aname+".tmp"
              File.open(inputName,"wb") { |f| f.write(cmd[1..-1].join(" ")) }
              success, consoleOutput = ProcessHelper.safeExecute() { `#{compiler[:COMMAND] + " @" + inputName}` }
            else
              success, consoleOutput = ProcessHelper.safeExecute() { `#{cmd.join(" ")} 2>&1` }
            end
          else
            rd, wr = IO.pipe
            cmd << {:err=>wr,:out=>wr}
            success, consoleOutput = ProcessHelper.safeExecute() { sp = spawn(*cmd); ProcessHelper.readOutput(sp, rd, wr) }
            cmd.pop
          end          
          
          process_result(cmd, consoleOutput, compiler[:ERROR_PARSER], "Linting #{name}", success)
        end
      end

      def res.needed?
        true
      end
      
      return res
    end

  end
end
