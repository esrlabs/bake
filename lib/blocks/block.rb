module Bake
  
  module Blocks
    
    ALL_BLOCKS = {} # NEW
    
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
      
      def execute
        return true if (@visited)
        @visited = true
   
        dependencies.each do |dep|
          ALL_BLOCKS[dep].execute
        end
        
        if not Bake.options.verboseLow
          Bake.formatter.printAdditionalInfo "**** Building #{block_counter} of #{ALL_BLOCKS.size}: #{@projName} (#{@configName}) ****"     
        end
        
        preSteps.each do |step|
          step.execute
        end

        postSteps.each do |step|
          step.execute
        end
        
                
      end
      
    end
    
    
  end
  
  
end