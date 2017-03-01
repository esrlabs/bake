require 'bake/toolchain/errorparser/error_parser'

module Bake
  class GreenHillsCompilerErrorParser < ErrorParser

    def initialize()
      # example:
      # "test.c", line 1: warning #123-D: blah blub
      @error_expression = /"([^"]+)", line ([0-9]+)[:0-9]* (catastrophic |fatal )*([A-Za-z\._]+) (.+)/
    end

    def scan_lines(consoleOutput, proj_dir)
      res = []
      consoleOutputFullnames = ""
      consoleOutput[0].each_line do |l|
        d = ErrorDesc.new
        scan_res = l.gsub(/\r\n?/, "").scan(@error_expression)
        if scan_res.length > 0
          d.file_name = File.expand_path(scan_res[0][0], proj_dir)
          d.line_number = scan_res[0][1].to_i
          d.message = scan_res[0][4]
          d.severity = get_severity(scan_res[0][3])
          l.gsub!(scan_res[0][0],d.file_name)
        end
        res << d
        consoleOutputFullnames << l
      end
      [res, consoleOutputFullnames]
    end

  end
end
