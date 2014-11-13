require 'imported/ext/stdout'
require 'imported/utils/exit_helper'
require 'imported/errorparser/error_parser'


require 'rake'
require 'stringio'
require 'thread'

require 'imported/utils/printer'

module Bake
  class SystemCommandFailed < Exception
  end
end

module Rake

  class Application
    attr_writer :max_parallel_tasks
    attr_writer :check_unnecessary_includes
    attr_writer :deriveIncludes
    attr_writer :preproFlags
    attr_writer :consoleOutput_fullnames
    attr_writer :consoleOutput_visualStudio
    attr_writer :addEmptyLine
    attr_writer :debug
    attr_writer :lint
    def max_parallel_tasks
      @max_parallel_tasks ||= 8
    end
    
    def debug
      @debug ||= false
    end
    
    def addEmptyLine
      @addEmptyLine ||= false
    end
    
    def check_unnecessary_includes
      @check_unnecessary_includes ||= false
    end

    def idei
      @idei ||= Bake::IDEInterface.new
    end

    def idei=(value)
      @idei = value
    end

    def command_line_number
      @command_line_number ||= 1
      res = @command_line_number
      @command_line_number += 1
      res
    end
    
    def makefile_number
      @makefile_number ||= 1
      res = @makefile_number
      @makefile_number += 1
      res
    end
    
    def deriveIncludes
      @deriveIncludes ||= false
    end

    def preproFlags
      @preproFlags ||= false
    end

    def consoleOutput_fullnames
      @consoleOutput_fullnames ||= false
    end
    
    def consoleOutput_visualStudio
      @consoleOutput_visualStudio ||= false
    end
    
    def lint
      @lint ||= false
    end
    
  end

  class Jobs
    def initialize(jobs, max, &block)
      nr_of_threads = [max, jobs.length].min
      @jobs = jobs
      @threads = []
      nr_of_threads.times do
        @threads << Thread.new do
          block.call(self)
        end
      end
    end

    def get_next_or_nil
      the_next = nil
      mutex.synchronize {
        the_next = @jobs.shift
      }
      the_next
    end
    def join
      @threads.each{|t| while not t.join(2) do end}
    end
    def mutex
      @mutex ||= Mutex.new
    end
  end

  #############
  # - Limit parallel tasks
  #############
  class MultiTask < Task
    def set_building_block(bb)
      @bb = bb
    end
    
    def invoke_prerequisites(args, invocation_chain)
      super(args, invocation_chain)

      return if @failure # pre step has failed

      Dir.chdir(@bb.project_dir) do
        if Dir.pwd != @bb.project_dir and File.dirname(Dir.pwd) != File.dirname(@bb.project_dir)
          isSym = false
          begin
            isSym = File.symlink?(@bb.project_dir)
          rescue
          end
          if isSym
            message = "Symlinks only allowed with the same parent dir as the target: #{@bb.project_dir} --> #{Dir.pwd}"
            res = Bake::ErrorDesc.new
            res.file_name = @bb.project_dir
            res.line_number = 0
            res.severity = Bake::ErrorParser::SEVERITY_ERROR
            res.message = message
            Rake.application.idei.set_errors([res])
            Bake::Printer.printError message
            set_failed
            return
          end
        end
      
        file_tasks = @bb.create_object_file_tasks
        
        if file_tasks == nil # = error
          set_failed
          return
        end
        
        enhance(file_tasks)
        return if file_tasks.length == 0
        
        @error_strings = {}
        
        Jobs.new(file_tasks, application.max_parallel_tasks) do |jobs|
          handle_jobs(jobs, args, invocation_chain)
        end.join
        
        # can only happen in case of bail_on_first_error.
        # if not sorted, it may be confusing when builing more than once and the order of the error appearances changes from build to build
        # (it is not deterministic which file compilation finishes first)
        @error_strings.sort.each {|es| puts es[1]} 
      
        if Rake.application.check_unnecessary_includes
          if not @failure # otherwise the dependency files might be incorrect or not complete
            @bb.incArray.each do |i|
              next if i=="."
              if not @bb.deps_in_depFiles.any? { |d| d.index(i) == 0 }
                msg = "Info: Include to #{i} seems to be unnecessary"
                Bake::Printer.printInfo msg
                res = Bake::ErrorDesc.new
                res.file_name = @project_dir
                res.line_number = 0
                res.severity = Bake::ErrorParser::SEVERITY_INFO
                res.message = msg
                Rake.application.idei.set_errors([res])              
              end
            end
          end
        end
      
      end
      
      
    end

    def handle_jobs(jobs, args, invocation_chain)
      while true do
        job = jobs.get_next_or_nil
        break unless job

        prereq = application[job]
        prereq.output_after_execute = false
        prereq.invoke_with_call_chain(args, invocation_chain)
        set_failed if prereq.failure
        output(prereq, prereq.output_string)
      end
    end

    def output(prereq, to_output)
      return if Rake::Task.output_disabled
      return unless output_after_execute

      mutex.synchronize do
        if to_output and to_output.length > 0
          if Rake::Task.bail_on_first_error and prereq and prereq.failure
            @error_strings[prereq.name] = to_output
          else
            puts to_output
          end
        end
      end
    end

    def mutex
      @mutex ||= Mutex.new
    end

  end

  class Task
    class << self
      attr_accessor :bail_on_first_error
      attr_accessor :output_disabled
    end

    attr_accessor :failure # specified if that task has failed
    attr_accessor :deps # used to store deps by depfile task for the apply task (no re-read of depsfile)
    attr_accessor :type
    attr_accessor :transparent_timestamp
    attr_accessor :output_string
    attr_accessor :output_after_execute
    attr_accessor :immediate_output
    attr_accessor :prerequisites

    UNKNOWN     = 0x0000 #
    OBJECT      = 0x0001 #
    SOURCEMULTI = 0x0002 # x
    DEPFILE     = 0x0004 #
    LIBRARY     = 0x0008 # x
    EXECUTABLE  = 0x0010 # x
    CONFIG      = 0x0020 #
    APPLY       = 0x0040 #
    UTIL        = 0x0080 #
    BINARY      = 0x0100 # x
    MODULE      = 0x0200 # x
    MAKE        = 0x0400 # x
    RUN         = 0x0800 #
    CUSTOM      = 0x1000 # x
    COMMANDLINE = 0x2000 # x
    LINT        = 0x4000 #

    STANDARD    = 0x371A # x above means included in STANDARD
    attr_reader :ignore
    execute_org = self.instance_method(:execute)
    initialize_org = self.instance_method(:initialize)
    timestamp_org = self.instance_method(:timestamp)
    invoke_prerequisites_org = self.instance_method(:invoke_prerequisites)
    invoke_org = self.instance_method(:invoke)

    define_method(:initialize) do |task_name, app|
      initialize_org.bind(self).call(task_name, app)
      @type = UNKNOWN
      @deps = nil
      @transparent_timestamp = false
      @ignore = false
      @failure = false
      @output_after_execute = true
      @immediate_output = true
    end

    define_method(:invoke) do |*args|
      Bake::ExitHelper.set_exit_code(0)
      invoke_org.bind(self).call(*args)
      if @failure or Rake.application.idei.get_abort
        Bake::ExitHelper.set_exit_code(1)
      end
    end

    define_method(:invoke_prerequisites) do |task_args, invocation_chain|
      new_invoke_prerequisites(task_args, invocation_chain)
    end

    def new_invoke_prerequisites(task_args, invocation_chain)
      orgLength = 0
      while @prerequisites.length > orgLength do
        orgLength = @prerequisites.length

        @prerequisites.dup.each do |n| # dup needed when apply tasks changes that array
          break if Rake.application.idei.get_abort
          #break if @failure

          prereq = nil
          begin
            prereq = application[n, @scope]
            prereq_args = task_args.new_scope(prereq.arg_names)
            prereq.invoke_with_call_chain(prereq_args, invocation_chain)
            set_failed if prereq.failure
          rescue Bake::ExitHelperException
            raise
          rescue Exception => e
            if prereq and Rake::Task[n].ignore
              @prerequisites.delete(n)
              def self.needed?
                true
              end
              return
            end
            Bake::Printer.printError "Error #{name}: #{e.message}"
            if RakeFileUtils.verbose
              puts e.backtrace
            end       
            set_failed
            if e.message.include?"Circular dependency detected"
              Rake.application.idei.set_abort(true)
            end
          end

        end
      end
    end

    def set_failed()
      @failure = true
      if Rake::Task.bail_on_first_error
        Rake.application.idei.set_abort(true)
      end
    end

    define_method(:execute) do |arg|
      
      if Rake::application.preproFlags
        if  self.type == SOURCEMULTI
          @failure = true
          break
        end
      end
       
      break if @failure # check if a prereq has failed
      break if Rake.application.idei.get_abort
      new_execute(execute_org, arg)
    end

    def new_execute(execute_org, arg)
      if not @immediate_output
        s = name == 'console' ? nil : StringIO.new
        tmp = Thread.current[:stdout]
        Thread.current[:stdout] = s unless tmp
      end

      begin
        execute_org.bind(self).call(arg)
      rescue Bake::ExitHelperException
        raise
      rescue Bake::SystemCommandFailed => scf
        handle_error(scf, true)
      rescue SystemExit => exSys
        Rake.application.idei.set_abort(true)
      rescue Exception => ex1
        handle_error(ex1, false)
      end
      
      if not @immediate_output
        self.output_string = s.string
        Thread.current[:stdout] = tmp
        output(nil, self.output_string)
      end
    end

    def handle_error(ex1, isSysCmd)
      if not Rake.application.idei.get_abort()
        if not isSysCmd
          Bake::Printer.printError "Error for task #{@name}: #{ex1.message}"
          Bake::Printer.printError(ex1.backtrace) if Rake.application.debug
        end
      end
      begin
        FileUtils.rm(@name) if File.exists?(@name)
      rescue Exception => ex2
        Bake::Printer.printError "Error: Could not delete #{@name}: #{ex2.message}"
      end
      set_failed
    end

    def output(name, to_output)
      return if Rake::Task.output_disabled
      return unless output_after_execute

      if to_output and to_output.length > 0
        puts to_output
      end
    end

    reenable_org = self.instance_method(:reenable)
    define_method(:reenable) do
      reenable_org.bind(self).call
      @failure = false
    end

    define_method(:timestamp) do
      if @transparent_timestamp
        ts = Rake::EARLY
        @prerequisites.each do |pre|
          prereq_timestamp = Rake.application[pre].timestamp
          ts = prereq_timestamp if prereq_timestamp > ts
        end
      else
        ts = timestamp_org.bind(self).call()
      end
      ts
    end

    def ignore_missing_file
      @ignore = true
    end

    def visit(&block)
      if block.call(self)
        prerequisite_tasks.each do |t|
          t.visit(&block)
        end
      end
    end

  end

end
