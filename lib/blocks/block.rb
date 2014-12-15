require 'bake/libElement'
require 'common/abortException'

module Bake

  BUILD_PASSED = 0
  BUILD_FAILED = 1
  BUILD_ABORTED = 2
  
  module Blocks

    
    ALL_BLOCKS = {} # NEW
    ALL_COMPILE_BLOCKS = {} # NEW
    ABORTED = false


    trap("INT") do
      ProcessHelper.killProcess
      ABORTED = true
      #Bake::IDEInterface.instance.set_abort(true)
    end
        
    class Block

      attr_reader :lib_elements, :projectDir, :library, :config
      attr_accessor :visited, :inDeps
  
      def preSteps
        @preSteps ||= []
      end
      
      def mainSteps
        @mainSteps ||= []
      end      
      
      def postSteps
        @postSteps ||= []
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
        
        @lib_elements = Bake::LibElements.calcLibElements(self)
      end
      
      def add_lib_element(elem)
        @lib_elements[2000000000] = [elem]
      end
      
      def convPath(dir)
         d = dir.respond_to?("name") ? dir.name : dir
         return d if Bake.options.no_autodir
         
         inc = d.split("/")
         if (inc[0] == @projectName)
           res = inc[1..-1].join("/") # within self
           res = "." if res == "" 
         elsif @referencedConfigs.include?(inc[0])
           dirOther = @referencedConfigs[inc[0]].first.parent.get_project_dir
           res = File.rel_from_to_project(@projectDir, dirOther)
           postfix = inc[1..-1].join("/")
           res = res + postfix if postfix != ""
         else
           if (inc[0] != "..")
             return d if File.exists?(@projectDir + "/" + d) # e.g. "include"
           
             # check if dir exists without Project.meta entry
             Bake.options.roots.each do |r|
               absIncDir = r+"/"+d
               if File.exists?(absIncDir)
                 res = File.rel_from_to_project(@projectDir,absIncDir)
                 if not res.nil?
                   return res
                 end 
               end
             end
           else
             Bake.formatter.printInfo "Info: #{@projectName} uses \"..\" in path name #{d}" if Bake.options.verboseHigh
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
          # delete file?
        rescue SystemExit => exSys
          ProcessHelper.killProcess
        rescue Exception => ex1
          # delete file?
          if not ABORTED # means no kill from IDE. TODO: test this!
            Bake.formatter.printError "Error: #{ex1.message}"
            puts ex1.backtrace if Bake.options.debug
          end
        end 
        
        if ABORTED
          raise AbortException.new
        end
        
        #if not result and Bake.options.stopOnFirstError 
                 
        return result
      end
      
      #def handle_error(ex1, isSysCmd)
      #  begin
          #FileUtils.rm(@name) if File.exists?(@name)
      #  rescue Exception => ex2
          #Bake.formatter.printError "Error: Could not delete #{@name}: #{ex2.message}"
      #  end
      #end
      

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
          if not Bake.options.verboseLow
            Bake.formatter.printWarning "Warning: circular dependency found including project #{@projectName} with config #{@configName}"
          end
          return true
        end

        return true if (@visited)
        @visited = true
   
        @inDeps = true
        depResult = callDeps(:execute)
        @inDeps = false
        return false if not depResult and Bake.options.stopOnFirstError
        
        if not Bake.options.verboseLow
          Bake.formatter.printAdditionalInfo "**** Building #{Block.block_counter} of #{@@num_projects}: #{@projectName} (#{@configName}) ****"     
        end

        result = callSteps(:execute)
        return (depResult && result)
      end

      def clean
        return true if (@visited)
        @visited = true

        depResult = callDeps(:clean)
        return false if not depResult and Bake.options.stopOnFirstError
        
        if Bake.options.verboseHigh
          Bake.formatter.printAdditionalInfo "**** Cleaning #{Block.block_counter} of #{@@num_projects}: #{@projectName} (#{@configName}) ****"     
        end
        
        result = callSteps(:clean)
        
        if Bake.options.clobber
          Dir.chdir(@projectDir) do
            if File.exist?".bake" 
              puts "Deleting folder .bake" if Bake.options.verboseHigh
              FileUtils.rm_rf(".bake")
            end
          end          
        end
        
        return (depResult && result)
      end      
            
    end
    
    
    
  end
  
  
end