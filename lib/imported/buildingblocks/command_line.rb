require 'imported/buildingblocks/building_block'
require 'imported/utils/process'

module Bake

  class CommandLine < BuildingBlock

    def set_command_line(x)
      @line = x
      self
    end

    def get_command_line
      @line
    end

    def set_defined_in_file(x)
      @defined_in_file = x
      self
    end

    def get_defined_in_file
      @defined_in_file
    end

    def set_defined_in_line(x)
      @defined_in_line = x
      self
    end

    def get_defined_in_line
      @defined_in_line
    end

    def initialize(name)
      set_command_line(name)
      @num = Rake.application.command_line_number
      super(get_task_name)
    end

    def get_task_name()
      "command line (#{@num}): " + get_command_line
    end

    def convert_to_rake()
      res = task get_task_name do
        Dir.chdir(@project_dir) do
          check_config_file
          cmd = get_command_line
          puts cmd + (RakeFileUtils.verbose ? "\n(executed in '#{@project_dir}')" : "")
          cmd_result = false
          begin
            rd, wr = IO.pipe
            cmd = [cmd]
            cmd << {
             :err=>wr,
             :out=>wr
            }
            cmd_result, consoleOutput = ProcessHelper.safeExecute() { sp = spawn(*cmd); ProcessHelper.readOutput(sp, rd, wr) }
            puts consoleOutput
          rescue
          end
          if (cmd_result == false)
            if Rake.application.idei
              err_res = ErrorDesc.new
              err_res.file_name = (@defined_in_file ? @defined_in_file : @project_dir)
              err_res.line_number = (@defined_in_line ? @defined_in_line : 0)
              err_res.severity = ErrorParser::SEVERITY_ERROR
              err_res.message = "Command \"#{get_command_line}\" failed"
              Rake.application.idei.set_errors([err_res])
            end
            Printer.printError "Error: command \"#{get_command_line}\" failed" + (RakeFileUtils.verbose ? "" : "\n(executed in '#{@project_dir}')")
            raise SystemCommandFailed.new
          end
        end
      end
      res.immediate_output = true
      res.transparent_timestamp = true
      res.type = Rake::Task::COMMANDLINE
      setup_rake_dependencies(res)
      res
    end


  end
end
