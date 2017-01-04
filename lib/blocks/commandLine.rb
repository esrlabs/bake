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

      def run
        return true if Bake.options.linkOnly
        return executeCommand(@commandLine, nil, @config.validExitCodes, @config.echo)
      end

      def execute
        return run()
      end

      def startupStep
        return run()
      end

      def exitStep
        return run()
      end

      def cleanStep
        return run()
      end

      def clean
        # nothing to do here
        return true
      end

    end

  end
end
