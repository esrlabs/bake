require_relative 'error_parser'

module Bake
  class DiabLinkerErrorParser < ErrorParser

    def initialize()
      @error_expression = /dld: ([A-Za-z]+): (.+)/
      @error_expression_linkerscript = /dld: \"([^\"]+)\", line ([0-9]+): (.+)/
    end

    def scan_lines(consoleOutput, proj_dir)
      res = []
      error_severity = 255
      consoleOutput[0].each_line do |l|
        l.rstrip!
        d = ErrorDesc.new
        scan_res = l.scan(@error_expression)
        scan_res2 = l.scan(@error_expression_linkerscript)
        if scan_res.length == 0 and scan_res2.length == 0 # msg will end with the beginning of the next message
          d.severity = error_severity
          d.message = l
        elsif scan_res.length > 0
          d.file_name = proj_dir
          d.line_number = 0
          d.message = scan_res[0][1]
          d.severity = get_severity(scan_res[0][0])
          error_severity = d.severity
        else
          d.file_name = proj_dir+"/"+scan_res2[0][0]
          d.line_number = scan_res2[0][1].to_i
          d.message = scan_res2[0][2]
          d.severity = SEVERITY_ERROR
          error_severity = d.severity
        end
        res << d
      end
      [res, consoleOutput[0]]
    end

  end
end
