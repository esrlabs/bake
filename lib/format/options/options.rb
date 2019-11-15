require_relative '../../common/options/parser'
require_relative '../../common/version'

module Bake

  class BakeFormatOptions < Parser
    attr_reader :indent, :input, :output # String
    attr_reader :start_line, :end_line # Fixnum

    def initialize(argv)
      super(argv)

      @input = '-'
      @output = '-'
      @start_line = nil
      @end_line = nil
      @indent = '  '
      @index = 0

      add_option([""             ], lambda { |x| collect_args(x)                                      })
      add_option(["--indent"     ], lambda { |x| @indent = x                                          })
      add_option(["--lines"      ], lambda { |x| set_lines(x)                                         })
      add_option(["-h", "--help" ], lambda { usage; ExitHelper.exit(0)                                })
      add_option(["--version"    ], lambda { Bake::Version.printBakeFormatVersion; ExitHelper.exit(0) })
    end

    def usage
      puts [
        "Usage: #{__FILE__} [--indent=string] [--lines=string] input output",
        "  --indent=string, indent defaults to two spaces.",
        "    Note, you can escape a tab in bash by ctrl-vTAB with sourrounding \" e.g. \"--input=    \"",
        "  --lines=string, [start line]:[end line] - format a range of lines.",
        "  input, filename or '-' for stdin",
        "  output, filename, '-' for stdout, '--' for same as input file"
      ].join("\n")
    end

    def parse_options()
      parse_internal(true)
    end

  end

end

def collect_args(x)
  if @index == 0
    @input = x
  elsif @index == 1
    @output = x
  elsif
    Bake.formatter.printError("Error: wrong number of the arguments")
    ExitHelper.exit(1)
  end

  @index += 1
end

def set_lines(lines)
  m = lines.match(/(?<start_line>\d*):(?<end_line>\d*)/)

  if m == nil
    Bake.formatter.printError("Error: \"#{line}\" has invalid format")
    ExitHelper.exit(1)
  end

  @start_line = m[:start_line].to_i
  @end_line = m[:end_line].to_i

end