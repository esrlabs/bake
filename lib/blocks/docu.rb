require 'blocks/compile'

module Bake
  module Blocks
    class Docu
      include HasExecuteCommand
      
      def initialize(config, tcs)
        @config = config # Bake::Metamodel::CommandLine
        @commandLine = tcs[:DOCU]
        @projectDir = config.get_project_dir
      end
      
      def execute
        if @commandLine.empty?
          Bake.formatter.printInfo("No documentation command specified", @config)
        else
          return executeCommand(@commandLine)
        end
        return true
      end
      
      def clean
        # nothing to do here
        return true
      end
      
    end
  end
end
