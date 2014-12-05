require 'bake/libElement'

module Bake

  BUILD_PASSED = 0
  BUILD_FAILED = 1
  BUILD_ABORTED = 2
  
  module Blocks

    
    ALL_BLOCKS = {} # NEW
    ABORTED = false


    trap("INT") do
      ProcessHelper.killProcess
      ABORTED = true
      #Bake::IDEInterface.instance.set_abort(true)
    end
        
    class Block

      attr_reader :lib_elements, :projectDir, :library
  
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
        
        @library = nil
        @visited = false
        @config = config
        @referencedConfigs = referencedConfigs
        @projName = config.parent.name
        @configName = config.name
        @projectDir = config.get_project_dir
        @@block_counter = 0
        
        @lib_elements = Bake::LibElements.calcLibElements(@config)
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
      
      
      def block_counter
        @@block_counter += 1
      end
      
      def executeStep(step)
        result = false
        begin
          step.execute
          result = true
        rescue Bake::ExitHelperException
          raise
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
        
        if Bake.options.stopOnFirstError or ABORTED
          raise AbortException.new
        end
        
        return result
      end
      
      #def handle_error(ex1, isSysCmd)
      #  begin
          #FileUtils.rm(@name) if File.exists?(@name)
      #  rescue Exception => ex2
          #Bake.formatter.printError "Error: Could not delete #{@name}: #{ex2.message}"
      #  end
      #end
      

      
      
      def execute
        if (@visited)
          if Bake.options.verboseHigh
            Bake.formatter.printAdditionalInfo "Info: circular dependency found including project #{@projName} with config #{@configName}"
          end
          return true
        end
        @visited = true
   
        depResult = true
        dependencies.each do |dep|
          depResult = ALL_BLOCKS[dep].execute and depResult
        end
        
        if not Bake.options.verboseLow
          Bake.formatter.printAdditionalInfo "**** Building #{block_counter} of #{ALL_BLOCKS.size}: #{@projName} (#{@configName}) ****"     
        end
        
        result = true
        preSteps.each do |step|
          result = executeStep(step) if result
        end

        mainSteps.each do |step|
          result = executeStep(step) if result
        end

        postSteps.each do |step|
          result = executeStep(step) if result
        end
        
        return (depResult && result)
                
      end
      
    end
    
    
  end
  
  
end