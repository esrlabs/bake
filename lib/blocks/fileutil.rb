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
        if !@arg1 || @arg1.empty?
          Bake.formatter.printError("Error: source of file-step must not be empty")
          ExitHelper.exit(1)
        elsif [:copy, :move].include?(@type) && (!@arg2 || @arg2.empty?)
          Bake.formatter.printError("Error: target of file-step must not be empty")
          ExitHelper.exit(1)
        end
      end

      def run
        Dir.chdir(@projectDir) do
          if @type == :touch
            puts "Touching #{@arg1}" if @echo
            FileUtils.touch(@arg1)
          elsif @type == :move
            puts "Moving #{@arg1} to #{@arg2}" if @echo
            Dir.glob(@arg1).each {|f| FileUtils.mv(f, @arg2)}
          elsif @type == :copy
            puts "Copying #{@arg1} to #{@arg2}" if @echo
            Dir.glob(@arg1).each {|f| FileUtils.cp_r(f, @arg2)}
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
