require 'bake/toolchain/errorparser/error_parser'

module Bake
  class TaskingLinkerErrorParser < ErrorParser

    def initialize()
      @error_expression = /.* (.+): (.*)/
    end

    def scan_lines(consoleOutput, proj_dir)
      res = []
      consoleOutput[0].each_line do |l|
        l.rstrip!
        d = ErrorDesc.new
        scan_res = l.scan(@error_expression)
        if scan_res.length > 0
          d.file_name = proj_dir
          d.line_number = 0
          d.message = scan_res[0][1]
          d.severity = get_tasking_severity(scan_res[0][0])
        end
        res << d
      end
      [res, consoleOutput[0]]
    end

  end
end
