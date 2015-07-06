require 'blocks/has_execute_command'

module Bake
  module Blocks
    
    class CommandLine
      include HasExecuteCommand
      
      def initialize(config, referencedConfigs)
        @config = config # Bake::Metamodel::CommandLine
        @commandLine = config.name
        @projectDir = config.get_project_dir
      end
      
      def execute
        return executeCommand(@commandLine, nil, @config.validExitCodes)
      end

      def startupStep
        return executeCommand(@commandLine, nil, @config.validExitCodes)
      end

      def exitStep
        return executeCommand(@commandLine, nil, @config.validExitCodes)
      end
            
      def clean
        # nothing to do here
        return true
      end
      
    end
    
  end
end
