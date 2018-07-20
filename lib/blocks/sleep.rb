module Bake
  module Blocks

    class Sleep

      def initialize(config)
        @echo = (config.echo != "off")
        @time = config.name.to_f
      end

      def run
        puts "Sleeping #{@time}s" if @echo
        sleep @time
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
