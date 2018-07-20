require 'fileutils'

module Bake
  module Blocks

    class FileUtil

      def initialize(config, type, projectDir)
        @arg1 = config.name
        @arg2 = config.respond_to?(:to) ? config.to : nil
        @type = type
        @projectDir = projectDir
        @echo = (config.echo != "off")
      end

      def run
        Dir.chdir(@projectDir) do
          if @type == :touch
            puts "Touching #{@arg1}" if @echo
            FileUtils.touch(@arg1)
          elsif @type == :move
            puts "Moving #{@arg1} to #{@arg2}" if @echo
            FileUtils.mv(@arg1, @arg2)
          elsif @type == :copy
            puts "Copying #{@arg1} to #{@arg2}" if @echo
            FileUtils.cp_r(@arg1, @arg2)
          elsif @type == :remove
            puts "Removing #{@arg1}" if @echo
            FileUtils.rm_rf(@arg1)
          elsif @type == :makedir
            puts "Making #{@arg1}" if @echo
            FileUtils.mkdir_p(@arg1)
          end
        end
        return true
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
