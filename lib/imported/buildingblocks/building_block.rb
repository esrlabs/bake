require 'imported/buildingblocks/has_dependencies_mixin'
require 'imported/utils/exit_helper'
require 'imported/ext/rake'
require 'imported/ext/file'
require 'imported/ide_interface'
require 'imported/toolchain/colorizing_formatter'

# no deprecated warning for rake >= 0.9.x
include Rake::DSL if defined?(Rake::DSL)
module Bake

  # stores all defined buildingblocks by name (the name should be unique)
  ALL_BUILDING_BLOCKS = {}

  trap("INT") do
    Rake.application.idei.set_abort(true)
  end

  class BuildingBlock
    include HasDependencies

    attr_reader :name
    attr_reader :config_name
    attr_reader :config_files

    attr_reader :project_dir
    attr_accessor :output_dir
    attr_accessor :output_dir_relPath
    attr_accessor :pre_step

    def set_name(x)
      @name = x
      self
    end

    def set_tcs(x)
      @tcs = x
      self
    end

    def has_tcs?
      @tcs != nil
    end

    def tcs()
      raise "Toolchain settings must be set before!" if @tcs.nil?
      @tcs
    end

    def set_config_files(x)
      @config_files = x
      @config_date = Time.now
      self
    end

    def set_project_dir(x)
      @project_dir = File.expand_path(x)
      self
    end

    def set_output_dir(x)
      return self if @output_dir
      
      if not @project_dir
        raise "Error: set project dir before output dir!"
      end

      if File.is_absolute?(x)
        @output_dir = x
        @output_dir_relPath = File.rel_from_to_project(@project_dir, x)
      else
        @output_dir = File.join(@project_dir,  x)
        @output_dir_relPath = x
      end
      
      self
    end

    def initialize(name)
      @name = name
      @config_name = nil
      @config_files = []
      @config_date = nil
      @project_dir = nil
      @tcs = nil
      @output_dir = nil
      @pre_step = nil
      @printedCmdAlternate = false
      @lastCommand = nil

      if ALL_BUILDING_BLOCKS.include?(@name) and not self.instance_of?(BinaryLibrary)
        raise "building block already exists: #{name}"
      else
        ALL_BUILDING_BLOCKS[@name] = self
      end
    end

    def set_config_name(x)
      @config_name = x
    end

    def complete_init()
      if self.respond_to?(:calc_compiler_strings)
        calc_compiler_strings
      end
    end

    def get_task_name()
      raise "this method must be implemented by decendants"
    end

    ##
    # convert all dependencies of a building block to rake task prerequisites (e.g. exe needs lib)
    #
    def setup_rake_dependencies(task, multitask = nil)
      dependencies.reverse_each do |d|
        begin
          bb = ALL_BUILDING_BLOCKS[d]
          raise "Error: tried to add the dependencies of \"#{d}\" to \"#{@name}\" but such a building block could not be found!" unless bb

          if multitask and bb.pre_step
            multitask.prerequisites.unshift(bb.get_task_name)
          else
            task.prerequisites.unshift(bb.get_task_name)
          end
        rescue ExitHelperException
          raise
        rescue Exception => e
          Bake.formatter.printError e.message
          ExitHelper.exit(1)
        end
      end

      task
    end

    def add_output_dir_dependency(file, taskOfFile, addDirToCleanTask)
      d = File.dirname(file)
      directory d
      taskOfFile.enhance([d])

      if addDirToCleanTask
        CLEAN.include(@output_dir)
      end
    end

    def printCmd(cmd, alternate, showPath)
      @lastCommand = cmd
      if showPath or Bake.options.verboseHigh or (alternate.nil? and not Bake.options.verboseLow)
        @printedCmdAlternate = false
        exedIn = ""
        exedIn = "\n(executed in '#{@project_dir}')" if (showPath or Bake.options.verboseHigh)
        puts "" if Bake.options.verboseHigh # todo: why?
        if cmd.is_a?(Array)
          puts cmd.join(' ') + exedIn
        else
          puts cmd + exedIn
        end
      else
        @printedCmdAlternate = true
        puts alternate if not Bake.options.verboseLow
      end
      @lastCommand = cmd
    end


    def process_result(cmd, console_output, error_parser, alternate, success)
      hasError = (success == false)
      if (cmd != @lastCommand) or (@printedCmdAlternate and hasError)
        printCmd(cmd, alternate, (hasError and not Bake.options.lint))
      end
      errorPrinted = process_console_output(console_output, error_parser)

      if hasError
        if not errorPrinted
          Bake.formatter.printError "Error: system command failed"
          res = ErrorDesc.new
          res.file_name = @project_dir
          res.line_number = 0
          res.message = "Unknown error, see log output. Maybe the bake error parser has to be updated..."
          res.severity = ErrorParser::SEVERITY_ERROR
          Rake.application.idei.set_errors([res])
        end
      end
      if hasError or errorPrinted
        raise SystemCommandFailed.new
      end
    end

    def read_file_or_empty_string(filename)
      begin
        return File.read(filename)
      rescue
        return ""
      end
    end

    def typed_file_task(type, *args, &block)
      t = file *args do
        block.call
      end
      t.type = type
      return t
    end

    def remove_empty_strings_and_join(a, j=' ')
      return a.reject{|e|e.to_s.empty?}.join(j)
    end

    def catch_output(cmd)
      new_command = "#{cmd} 2>&1"
      # "/" does not work on windows with backticks, switch the separator on windows:
      new_command.gsub!(File::SEPARATOR, File::ALT_SEPARATOR) if File::ALT_SEPARATOR
      return `#{new_command}`
    end

    def check_config_file()
      if @config_date
        @config_files.each do |c|
          err_msg = nil
          if File.exists?(c) and File.mtime(c) > @config_date
            @config_date = File.mtime(c)
            begin
              FileUtils.touch(c)
            rescue Exception
            end
          end
        end
      end
    end

  end

end
