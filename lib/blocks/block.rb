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
      #Rake.application.idei.set_abort(true)
    end
        
    class Block

      LIB = 1
      USERLIB = 2
      LIB_WITH_PATH = 3
      SEARCH_PATH = 4
      DEPENDENCY = 5
  
      def lib_elements
        @lib_elements ||= []
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

      def dependencies
        @dependencies ||= []
      end
      
      def initialize(projName, configName)
        @visited = false
        @projName = projName
        @configName = configName
        @@block_counter = 0
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
            Bake.formatter.printError(ex1.backtrace) if Bake.options.debug
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