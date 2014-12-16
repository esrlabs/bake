require 'bake/toolchain/errorparser/error_parser'

module Bake
  class LintErrorParser < ErrorParser

    def initialize()
      @error_expression = /([^:]*):([0-9]+): ([A-Za-z]+)(.+)/
    end

    def scan_lines(consoleOutput, proj_dir)
      res = []
      consoleOutputFullnames = ""
      consoleOutput.each_line do |l|
        d = ErrorDesc.new
        scan_res = l.gsub(/\r\n?/, "").scan(@error_expression)
        if scan_res.length > 0
          if (scan_res[0][0] == "")
            d.file_name = proj_dir
          else
            d.file_name = File.expand_path(scan_res[0][0])
          end
          d.line_number = scan_res[0][1].to_i
          d.severity = get_severity(scan_res[0][2])
          d.message = scan_res[0][3]
          l.gsub!(scan_res[0][0],d.file_name)
        end
        res << d
        consoleOutputFullnames << l
      end
      [res, consoleOutputFullnames]
    end

  end
end
