require 'common/options/parser'
require 'common/version'

module Bake

  class BakecleanOptions < Parser
    attr_reader :preview # Boolean

    def initialize(argv)
      super(argv)

      @preview = false

      add_option(["--preview"    ], lambda { @preview = true                                         })
      add_option(["-h", "--help" ], lambda { usage; ExitHelper.exit(0)                               })
      add_option(["--version"    ], lambda { Bake::Version.printBakecleanVersion; ExitHelper.exit(0) })
    end

    def usage
      puts "\nUsage: bakeclean [options]"
      puts " --preview        Only shows the folder which would be deleted."
      puts " --version        Print version."
      puts " -h, --help       Print this help."
    end

    def parse_options()
      parse_internal(false)
    end

  end

end
