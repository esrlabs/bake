require 'bake/toolchain/errorparser/error_parser'

module Bake
  class KeilLinkerErrorParser < ErrorParser

    def initialize()
      @error_expression = /([^:]+): (L[0-9]+[A-Z]: .+)/
    end

    def scan_lines(consoleOutput, proj_dir)
      res = []
      consoleOutput.each_line do |l|
        l.rstrip!
        d = ErrorDesc.new
        scan_res = l.scan(@error_expression)
        if scan_res.length > 0
          d.file_name = proj_dir
          d.line_number = 0
          d.message = scan_res[0][1]
          d.severity = get_severity(scan_res[0][0])
          error_severity = d.severity
        end
        res << d
      end
      [res, consoleOutput]
    end


  end
end
