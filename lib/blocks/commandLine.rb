require 'blocks/has_execute_command'

module Bake
  module Blocks
    
    class CommandLine
      include HasExecuteCommand
      
      def initialize(config)
        @config = config # Bake::Metamodel::CommandLine
        @commandLine = config.name
        @projectDir = config.get_project_dir
      end
      
      def execute
        executeCommand(@commandLine)
      end
      def clean
        # nothing to do here
      end
      
    end
    
  end
end
