require 'bake/toolchain/errorparser/error_parser'

module Bake
  class GreenHillsLinkerErrorParser < ErrorParser

#    detect this:

#    C++ prelinker: recompiling "x/y.z"
#    "blah.h", line 1: warning #123-D: expression has no effect
#                    uiuiui
#                    ^
#              detected during:
#                instantiation of ...

#   dblink: WARNING: 10 problems were encountered while processing debug information, see "Debug/xy.dle" for details.

    def initialize()
      @error_expression = /ld: (.+)/
    end

    def scan_lines(consoleOutput, proj_dir)
      res = []
      error_severity = 255
      consoleOutput[0].each_line do |l|
        l.rstrip!
        d = ErrorDesc.new
        scan_res = l.scan(@error_expression)
        if scan_res.length == 0 # msg will end with the beginning of the next message
          d.severity = error_severity
          d.message = l
        elsif scan_res.length > 0
          d.file_name = proj_dir
          d.line_number = 0
          d.message = scan_res[0][0]
          d.severity = SEVERITY_ERROR
          error_severity = d.severity
        end
        res << d
      end
      [res, consoleOutput[0]]
    end

  end
end
