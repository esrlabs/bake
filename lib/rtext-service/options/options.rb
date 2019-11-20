require_relative '../../common/options/parser'
require_relative '../../common/version'

module Bake
  class BakeRtextServiceOptions < Parser
    attr_reader :loglevel # String
    attr_reader :patterns
    attr_reader :timeout # Number

    def initialize(argv)
      super(argv)

      @loglevel = 'info'
      @patterns = []
      @timeout = 3600

      add_option([""                 ], lambda { |x| @patterns.push(x)                                    })
      add_option(["-l", "--loglevel" ], lambda { |x| set_loglevel(x)                                      })
      add_option(["-t", "--timeout"  ], lambda { |x| @timeout = x.to_i                                    })
      add_option(["-h", "--help"     ], lambda { usage; ExitHelper.exit(0)                                })
      add_option(["--version"        ], lambda { Bake::Version.printBakeFormatVersion; ExitHelper.exit(0) })
    end

    def usage
      puts [
        "Usage: #{__FILE__} [options] <dir patterns>",
        "  -l, --loglevel [string], log level is one of [debug, info, warn, error, fatal].",
        "  -t, --timeout [number], idle timeout in seconds after which the service will shutdown. Default is 3600.",
        "  dir patterns, glob patterns."
      ].join("\n")
    end

    def parse_options()
      parse_internal(true)
      @patterns = ['./**'] unless @patterns.any?
    end
  end
end

def set_loglevel(level)
  unless level.match(/^debug|info|warn|error|fatal$/)
    Bake.formatter.printError("Error: \"#{level}\" is wrong log level type")
    Bake::ExitHelper.exit(1)
  end

  @loglevel = level
end
