require 'bake/libElement'
require 'common/abortException'

module Bake

  BUILD_PASSED = 0
  BUILD_FAILED = 1
  BUILD_ABORTED = 2

  module Blocks

    CC2J = []
    ALL_BLOCKS = {}
    ALL_COMPILE_BLOCKS = {}

    class Block

      attr_reader :lib_elements, :projectDir, :library, :config, :projectName, :warnConvValid, :prebuild
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

      def dependencies
        @dependencies ||= []
      end

      def childs
        @childs ||= []
      end

      def parents
        @parents ||= []
      end

      def set_library(library)
        @library = library
      end

      def initialize(config, referencedConfigs, prebuild)
        @inDeps = false
        @prebuild = prebuild
        @visited = false
        @library = nil
        @config = config
        @referencedConfigs = referencedConfigs
        @projectName = config.parent.name
        @configName = config.name
        @projectDir = config.get_project_dir
        @@block_counter = 0
        @result = true

        @lib_elements = Bake::LibElements.calcLibElements(self)
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

         @warnConvValid = false

         return d if Bake.options.no_autodir

         inc = d.split("/")
         res = nil
         if (inc[0] == @projectName)
           res = inc[1..-1].join("/") # within self
           res = "." if res == ""
         elsif @referencedConfigs.include?(inc[0])
           dirOther = @referencedConfigs[inc[0]].first.parent.get_project_dir
           res = File.rel_from_to_project(@projectDir, dirOther, false)
           postfix = inc[1..-1].join("/")
           res = res + "/" + postfix if postfix != ""
         else
           if (inc[0] != "..")
             return d if File.exists?(@projectDir + "/" + d) # e.g. "include"
             # check if dir exists without Project.meta entry
             Bake.options.roots.each do |r|
               absIncDir = r+"/"+d
               if File.exists?(absIncDir)
                 res = File.rel_from_to_project(@projectDir,absIncDir,false)
               end
             end
           else
             if elem and Bake.options.verbose >= 2
               Bake.formatter.printInfo("\"..\" in path name found", elem)
             end
           end

           if res.nil? # relative from self as last resort
             warnIfLocal = false # no path magic -> no warning
             res = d
           end
         end

         @warnConvValid = File.exists?(@projectDir + "/" + d) if warnIfLocal # only warn if path magic hides local path

         res
       end


      def self.block_counter
        @@block_counter += 1
      end

      def self.reset_block_counter
        @@block_counter = 0
      end

      def self.set_num_projects(num)
        @@num_projects = num
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
            Bake.formatter.printError("Error: #{ex1.message}")
            puts ex1.backtrace if Bake.options.debug
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

      def callSteps(method)

        preSteps.each do |step|
          @result = executeStep(step, method) if @result
          return false if not @result and Bake.options.stopOnFirstError
        end unless @prebuild

        mainSteps.each do |step|
          if !@prebuild || (Library === step)
            @result = executeStep(step, method) if @result
          end
          return false if not @result and Bake.options.stopOnFirstError
        end

        postSteps.each do |step|
          @result = executeStep(step, method) if @result
          return false if not @result and Bake.options.stopOnFirstError
        end unless @prebuild

        return @result
      end

      def execute
        if (@inDeps)
          if Bake.options.verbose >= 3
            Bake.formatter.printWarning("While calculating next config, a circular dependency was found including project #{@projectName} with config #{@configName}", @config)
          end
          return true
        end

        return true if (@visited)
        @visited = true

        @inDeps = true
        depResult = callDeps(:execute)
        @inDeps = false
        return false if not depResult and Bake.options.stopOnFirstError

        Bake::IDEInterface.instance.set_build_info(@projectName, @configName)

        if Bake.options.verbose >= 1
          typeStr = @prebuild ? "Using" : "Building"
          Bake.formatter.printAdditionalInfo "**** #{typeStr} #{Block.block_counter} of #{@@num_projects}: #{@projectName} (#{@configName}) ****"
        end
        puts "Project path: #{@projectDir}" if Bake.options.projectPaths

        @result = callSteps(:execute)
        return (depResult && @result)
      end

      def clean
        return true if (@visited)
        @visited = true

        depResult = callDeps(:clean)
        return false if not depResult and Bake.options.stopOnFirstError

        if Bake.options.verbose >= 2
          typeStr = @prebuild ? "Checking" : "Cleaning"
          Bake.formatter.printAdditionalInfo "**** #{typeStr} #{Block.block_counter} of #{@@num_projects}: #{@projectName} (#{@configName}) ****"
        end

        @result = callSteps(:clean)

        if Bake.options.clobber
          Dir.chdir(@projectDir) do
            if File.exist?".bake"
              puts "Deleting folder .bake" if Bake.options.verbose >= 2
              FileUtils.rm_rf(".bake")
            end
          end
        end

        return (depResult && @result)
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

    end



  end


end