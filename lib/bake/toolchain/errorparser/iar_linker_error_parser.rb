require_relative 'error_parser'

module Bake
  class IARLinkerErrorParser < ErrorParser

    def initialize()
      @error_expression = /([A-Za-z]+)\[\w+\]:\s*(.+)/
    end

    def scan_lines(consoleOutput, proj_dir)
      res = []
      lastValidErrorDesc = nil
      consoleOutput[0].each_line do |l|
        l.rstrip!
        d = ErrorDesc.new
        scan_res = l.scan(@error_expression)
        if scan_res.length > 0
          d.file_name = proj_dir
          d.line_number = 0
          d.message = scan_res[0][1]
          d.severity = get_severity(scan_res[0][0])
          error_severity = d.severity
          lastValidErrorDesc = d
        else
          if lastValidErrorDesc
            lastValidErrorDesc.message += l.lstrip
            d.severity = lastValidErrorDesc.severity
          else
            d.severity = SEVERITY_ERROR
          end
        end
        res << d
      end
      [res, consoleOutput[0]]
    end

  end
end
