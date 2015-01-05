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
          Bake.formatter.printInfo "Info: no documentation command specified"
        else
          executeCommand(@commandLine)
        end
      end
      
      def clean
        # nothing to do here
      end
      
    end
  end
end
