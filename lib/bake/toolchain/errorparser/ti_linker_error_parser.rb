require_relative 'error_parser'

module Bake
  class TILinkerErrorParser < ErrorParser

    def initialize()
      # todo: is every line an error?
      # todo: some linker errors look like simple text, dunno how to parse properly...
      # @error_expression1 = /(.*:\(\..*\)): (.*)/  # e.g. /c/Tool/Temp/ccAlar4R.o:x.cpp:(.text+0x17): undefined reference to `_a'
      # @error_expression2 = /(.*):([0-9]+): (.*)/  # e.g. /usr/lib/gcc/i686-pc-cygwin/4.3.4/../../../../i686-pc-cygwin/bin/ld:roodi.yml.a:1: syntax error
    end

    def scan_lines(consoleOutput, proj_dir)
      res = []
      consoleOutput[0].each_line do |l|
        l.rstrip!
        d = ErrorDesc.new
        if l != "<Linking>" then
          d.file_name = proj_dir
          d.line_number = 0
          d.message = l
          d.severity = SEVERITY_ERROR
        end
        res << d
      end
      [res, consoleOutput]
    end

  end
end
