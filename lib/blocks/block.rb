require 'bake/libElement'
require 'bake/model/metamodel'
require 'common/abortException'
require "thwait"

module Bake

  BUILD_PASSED = 0
  BUILD_FAILED = 1
  BUILD_ABORTED = 2

  module Blocks

    CC2J = []
    ALL_BLOCKS = {}
    ALL_COMPILE_BLOCKS = {}

    class Block

      @@block_counter = 0
      @@delayed_result = true
      @@threads = []

      attr_reader :lib_elements, :projectDir, :library, :config, :projectName, :prebuild, :output_dir, :tcs
      attr_accessor :visited, :inDeps, :result

      def startupSteps
        @startupSteps ||= []
      end

      def preSteps
        @preSteps ||= []
      end

      def mainSteps
        @mainSteps ||= []
      end

      def postSteps
        @postSteps ||= []
      end

      def exitSteps
        @exitSteps ||= []
      end

      def cleanSteps
        @cleanSteps ||= []
      end

      def dependencies
        @dependencies ||= []
      end

      def childs
        @childs ||= []
      end

      def parents
        @parents ||= []
      end

      def depToBlock
        @depToBlock ||= {}
      end

      def set_library(library)
        @library = library
      end

      def initialize(config, referencedConfigs, prebuild, tcs)
        @inDeps = false
        @prebuild = prebuild
        @visited = false
        @library = nil
        @config = config
        @referencedConfigs = referencedConfigs
        @projectName = config.parent.name
        @configName = config.name
        @projectDir = config.get_project_dir
        @result = true
        @tcs = tcs

        @lib_elements = Bake::LibElements.calcLibElements(self)

        calcOutputDir
      end

      def getCompileBlocks()
        mainSteps.select { |m| Compile === m }
      end

      def convPath(dir, elem=nil, warnIfLocal=false)
        if dir.respond_to?("name")
          d = dir.name
          elem = dir
        else
          d = dir
        end

        return d if Bake.options.no_autodir

        inc = d.split("/")
        if (inc[0] == "..") # very simple check, but should be okay for 99.9 % of the cases
          if elem and Bake.options.verbose >= 2
            SyncOut.mutex.synchronize do
              Bake.formatter.printInfo("path starts with \"..\"", elem)
            end
          end
        end

        res = []

        return d if (inc[0] == "." || inc[0] == "..") # prio 0: force local

        if (inc[0] == @projectName) # prio 1: the real path magic
          resPathMagic = inc[1..-1].join("/") # within self
          resPathMagic = "." if resPathMagic == ""
          res << resPathMagic
        elsif @referencedConfigs.include?(inc[0])
          dirOther = @referencedConfigs[inc[0]].first.parent.get_project_dir
          resPathMagic = File.rel_from_to_project(@projectDir, dirOther, false)
          postfix = inc[1..-1].join("/")
          resPathMagic = resPathMagic + "/" + postfix if postfix != ""
          resPathMagic = "." if resPathMagic == ""
          res << resPathMagic
        end

        if File.exists?(@projectDir + "/" + d) # prio 2: local, e.g. "include"
          res << d
        end

        # prioo 3: check if dir exists without Project.meta entry
        Bake.options.roots.each do |r|
          absIncDir = r+"/"+d
          if File.exists?(absIncDir)
            res << File.rel_from_to_project(@projectDir,absIncDir,false)
          end
        end

        return d if res.empty? # prio 4: fallback, no path found

        res = res.map{ |r| Pathname.new(r).cleanpath.to_s }.uniq

        if warnIfLocal && res.length > 1
          if elem and Bake.options.verbose >= 2
            SyncOut.mutex.synchronize do
              Bake.formatter.printInfo("#{d} matches several paths:", elem)
              puts "  #{res[0]} (chosen)"
              res[1..-1].each { |r| puts "  #{r}" }
            end
          end
        end

        res[0]
      end

      def self.inc_block_counter()
        @@block_counter += 1
      end

      def self.block_counter
        @@block_counter
      end

      def self.reset_block_counter
        @@block_counter = 0
      end

      def self.reset_delayed_result
        @@delayed_result = true
      end

      def self.delayed_result
        @@delayed_result
      end

      def self.threads
        @@threads
      end

      def calcIsBuildBlock
        @startupSteps ||= []

        return true if Metamodel::ExecutableConfig === @config
        if Metamodel::CustomConfig === @config
          return true if @config.step
        else
          return true if @config.files.length > 0
          if ((@config.startupSteps && @config.startupSteps.step.length > 0) ||
          (@config.preSteps && @config.preSteps.step.length > 0) ||
          (@config.postSteps && @config.postSteps.step.length > 0) ||
          (@config.exitSteps && @config.exitSteps.step.length > 0) ||
          (@config.cleanSteps && @config.cleanSteps.step.length > 0) ||
          (@config.preSteps && @config.preSteps.step.length > 0))
            return true
          end
        end
        return false
      end

      def isBuildBlock?
        @isBuildBlock ||= calcIsBuildBlock
      end

      def self.set_num_projects(blocks)
        if Bake.options.verbose >= 2
          @@num_projects = blocks.length
        else
          counter = 0
          blocks.each do |b|
            counter += 1 if b.isBuildBlock? || b.prebuild
          end
          @@num_projects = counter
        end
      end

      def executeStep(step, method)
        begin
          @result = step.send(method) && @result
        rescue Bake::SystemCommandFailed => scf
          @result = false
          ProcessHelper.killProcess(true)
        rescue SystemExit => exSys
          @result = false
          ProcessHelper.killProcess(true)
        rescue Exception => ex1
          @result = false
          if not Bake::IDEInterface.instance.get_abort
            SyncOut.mutex.synchronize do
              Bake.formatter.printError("Error: #{ex1.message}")
              puts ex1.backtrace if Bake.options.debug
            end
          end
        end

        if Bake::IDEInterface.instance.get_abort
          raise AbortException.new
        end

        # needed for ctrl-c in Cygwin console
        #####################################
        # additionally, the user has to enable raw mode of Cygwin console: "stty raw".
        # raw mode changes the signals into raw characters.
        # original problem: Cygwin is compiled with broken control handler config,
        # which might not be changed due to backward compatibility.
        # the control handler works only with programs compiled under Cygwin, which is
        # not true for Windows RubyInstaller packages.
        ctrl_c_found = false
        begin
          while IO.select([$stdin],nil,nil,0) do
            nextChar = $stdin.sysread(1)
            if nextChar == "\x03"
              ctrl_c_found = true
            end
          end
        rescue Exception => e
        end
        raise AbortException.new if ctrl_c_found

        return @result
      end

      def callDeps(method)
        depResult = true
        dependencies.each do |dep|
          depResult = (ALL_BLOCKS[dep].send(method) and depResult)
          break if not depResult and Bake.options.stopOnFirstError
        end
        return depResult
      end

      def execute_in_thread(method)
        if method == :execute
          @@mutex.synchronize do
            if @@threads.length == Bake.options.threads
             endedThread = ThreadsWait.new(@@threads).next_wait
             @@threads.delete(endedThread)
            end
          end
          @@threads << Thread.new() {

            exceptionOccured = false
            begin
              yield
              exceptionOccured = true
            rescue Bake::SystemCommandFailed => scf # normal compilation error
            rescue SystemExit => exSys
            rescue Exception => ex1
              if not Bake::IDEInterface.instance.get_abort
                SyncOut.mutex.synchronize do
                  Bake.formatter.printError("Error: #{ex1.message}")
                  puts ex1.backtrace if Bake.options.debug
                end
              end
            end
            if !exceptionOccured
              @result = false
              @@delayed_result = false
            end
          }
        else
          yield
        end
        raise AbortException.new if Bake::IDEInterface.instance.get_abort
      end

      def blockAbort?(res)
        ((not res) || !@@delayed_result) and Bake.options.stopOnFirstError or Bake::IDEInterface.instance.get_abort
      end

      def callSteps(method)

        @config.writeEnvVars()
        Thread.current[:lastCommand] = nil

        preSteps.each do |step|
          ThreadsWait.all_waits(Blocks::Block::threads)
          @result = executeStep(step, method) if @result
          return false if blockAbort?(@result)
        end unless @prebuild

        threadableSteps    = mainSteps.select { |step|   Library === step || Compile === step  }
        nonThreadableSteps = mainSteps.select { |step| !(Library === step || Compile === step) }

        execute_in_thread(method) {
          threadableSteps.each do |step|
            if !@prebuild || (Library === step)
              @result = executeStep(step, method) if @result
              @@delayed_result &&= @result
            end
            return false if blockAbort?(@result)
          end
        } if !threadableSteps.empty?
        nonThreadableSteps.each do |step|
          if !@prebuild || (Library === step)
            ThreadsWait.all_waits(Blocks::Block::threads)
            @result = executeStep(step, method) if @result
          end
          return false if blockAbort?(@result)
        end

        postSteps.each do |step|
          ThreadsWait.all_waits(Blocks::Block::threads)
          @result = executeStep(step, method) if @result
          return false if blockAbort?(@result)
        end unless @prebuild

        return @result
      end

      def execute
        if (@inDeps)
          if Bake.options.verbose >= 3
            SyncOut.mutex.synchronize do
              Bake.formatter.printWarning("While calculating next config, a circular dependency was found including project #{@projectName} with config #{@configName}", @config)
            end
          end
          return true
        end

        return true if (@visited)
        @visited = true

        @inDeps = true
        depResult = callDeps(:execute)
        @inDeps = false
        return false if blockAbort?(depResult)

        Bake::IDEInterface.instance.set_build_info(@projectName, @configName)

        SyncOut.mutex.synchronize do
          if Bake.options.verbose >= 2 || isBuildBlock? || @prebuild
            typeStr = "Building"
            if @prebuild
              typeStr = "Using"
            elsif not isBuildBlock?
              typeStr = "Applying"
            end
            Block.inc_block_counter()
            Bake.formatter.printAdditionalInfo "**** #{typeStr} #{Block.block_counter} of #{@@num_projects}: #{@projectName} (#{@configName}) ****"
          end
          puts "Project path: #{@projectDir}" if Bake.options.projectPaths
        end

        @result = callSteps(:execute)
        return (depResult && @result)
      end

      def clean
        return true if (@visited)
        @visited = true

        depResult = callDeps(:clean)
        return false if not depResult and Bake.options.stopOnFirstError

        if Bake.options.verbose >= 2 || isBuildBlock? || @prebuild
          typeStr = "Cleaning"
          if @prebuild
            typeStr = "Checking"
          elsif not isBuildBlock?
            typeStr = "Skipping"
          end
          Block.inc_block_counter()
          Bake.formatter.printAdditionalInfo "**** #{typeStr} #{Block.block_counter} of #{@@num_projects}: #{@projectName} (#{@configName}) ****"
        end

        @result = callSteps(:clean)

        if Bake.options.clobber
          Dir.chdir(@projectDir) do
            if File.exist?".bake"
              puts "Deleting folder .bake" if Bake.options.verbose >= 2
              if !Bake.options.dry
                FileUtils.rm_rf(".bake")
              end
            end
          end
        end

        cleanSteps.each do |step|
          @result = executeStep(step, :cleanStep) if @result
          return false if not @result and Bake.options.stopOnFirstError
        end unless @prebuild

        return (depResult && @result)
      end

      def self.init_threads()
        @@threads = []
        @@result = true
        @@mutex = Mutex.new
      end

      def startup
        return true if (@visited)
        @visited = true

        depResult = callDeps(:startup)

        if Bake.options.verbose >= 1 and not startupSteps.empty?
          Bake.formatter.printAdditionalInfo "**** Starting up #{@projectName} (#{@configName}) ****"
        end

        startupSteps.each do |step|
          @result = executeStep(step, :startupStep) && @result
        end

        return (depResult && @result)
      end

      def exits
        return true if (@visited)
        @visited = true

        depResult = callDeps(:exits)

        if Bake.options.verbose >= 1 and not exitSteps.empty?
          Bake.formatter.printAdditionalInfo "**** Exiting #{@projectName} (#{@configName}) ****"
        end

        exitSteps.each do |step|
          @result = executeStep(step, :exitStep) && @result
        end

        return (depResult && @result)
      end

      def getSubBlocks(b, method)
        b.send(method).each do |child_b|
          if not @otherBlocks.include?child_b and not child_b == self
            @otherBlocks << child_b
            getSubBlocks(child_b, method)
          end
        end
      end

      def getBlocks(method)
        @otherBlocks = []
        getSubBlocks(self, method)
        return @otherBlocks
      end

      def isMainProject?
        @projectName == Bake.options.main_project_name and @config.name == Bake.options.build_config
      end

      def calcOutputDir
        if @tcs[:OUTPUT_DIR] != nil
          p = convPath(@tcs[:OUTPUT_DIR])
          @output_dir = p
        else
          qacPart = Bake.options.qac ? (".qac" + Bake.options.buildDirDelimiter) : ""
          if isMainProject?
            @output_dir = "build" + Bake.options.buildDirDelimiter + qacPart + Bake.options.build_config
          else
            @output_dir = "build" + Bake.options.buildDirDelimiter + qacPart + @config.name + "_" + Bake.options.main_project_name + "_" + Bake.options.build_config
          end
        end
      end

    end



  end


end