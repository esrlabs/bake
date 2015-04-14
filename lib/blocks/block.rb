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

      attr_reader :lib_elements, :projectDir, :library, :config
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
      
      def set_library(library)
        @library = library
      end
      
      def initialize(config, referencedConfigs)
        @inDeps = false
        @visited = false
        @library = nil
        @config = config
        @referencedConfigs = referencedConfigs
        @projectName = config.parent.name
        @configName = config.name
        @projectDir = config.get_project_dir
        @@block_counter = 0
        @result = false
        
        @lib_elements = Bake::LibElements.calcLibElements(self)
      end
      
      def add_lib_element(elem)
        @lib_elements[2000000000] = [elem]
      end
      
      def convPath(dir, elem=nil)
         if dir.respond_to?("name")
           d = dir.name
           elem = dir
         else
           d = dir
         end
         
         return d if Bake.options.no_autodir
         
         inc = d.split("/")
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
                 if not res.nil?
                   return res
                 end 
               end
             end
           else
             if elem and Bake.options.verbose >= 2
               Bake.formatter.printInfo("\"..\" in path name found", elem)
             end
           end
           
           res = d # relative from self as last resort
         end
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
        result = false
        begin
          step.send method
          result = true
        rescue Bake::SystemCommandFailed => scf
        rescue SystemExit => exSys
          ProcessHelper.killProcess(true)
        rescue Exception => ex1
          if not Bake::IDEInterface.instance.get_abort
            Bake.formatter.printError("Error: #{ex1.message}")
            puts ex1.backtrace if Bake.options.debug
          end
        end 
        
        if Bake::IDEInterface.instance.get_abort
          raise AbortException.new
        end
        
        return result
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
        result = true
        preSteps.each do |step|
          result = executeStep(step, method) if result
          return false if not result and Bake.options.stopOnFirstError
        end

        mainSteps.each do |step|
          result = executeStep(step, method) if result
          return false if not result and Bake.options.stopOnFirstError
        end

        postSteps.each do |step|
          result = executeStep(step, method) if result
          return false if not result and Bake.options.stopOnFirstError
        end
        
        return result        
      end
      
      def execute
        if (@inDeps)
          if Bake.options.verbose >= 1
            Bake.formatter.printWarning("Circular dependency found including project #{@projectName} with config #{@configName}", @config)
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
          Bake.formatter.printAdditionalInfo "**** Building #{Block.block_counter} of #{@@num_projects}: #{@projectName} (#{@configName}) ****"     
        end

        @result = callSteps(:execute)
        return (depResult && result)
      end

      def clean
        return true if (@visited)
        @visited = true

        depResult = callDeps(:clean)
        return false if not depResult and Bake.options.stopOnFirstError
        
        if Bake.options.verbose >= 2
          Bake.formatter.printAdditionalInfo "**** Cleaning #{Block.block_counter} of #{@@num_projects}: #{@projectName} (#{@configName}) ****"     
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
        
        return (depResult && result)
      end
      
      def startup
        return true if (@visited)
        @visited = true

        depResult = callDeps(:startup)
        return false if not depResult and Bake.options.stopOnFirstError
                
        if Bake.options.verbose >= 1 and not startupSteps.empty? 
          Bake.formatter.printAdditionalInfo "**** Starting up #{@projectName} (#{@configName}) ****"     
        end
        
        result = true
        startupSteps.each do |step|
          result = executeStep(step, :startupStep) if result
          return false if not result and Bake.options.stopOnFirstError
        end
        
        return (depResult && result)
      end      

      def exits
        return true if (@visited)
        @visited = true
      
        depResult = callDeps(:exits)
        return false if not depResult and Bake.options.stopOnFirstError
        
        if Bake.options.verbose >= 1 and not exitSteps.empty?
          Bake.formatter.printAdditionalInfo "**** Exiting #{@projectName} (#{@configName}) ****"     
        end
        
        result = true
        exitSteps.each do |step|
          result = executeStep(step, :exitStep) if result
          return false if not result and Bake.options.stopOnFirstError
        end
        
        return (depResult && result)
      end      

                  
    end
    
    
    
  end
  
  
end