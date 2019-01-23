require_relative 'error_parser'

module Bake
  class IARCompilerErrorParser < ErrorParser

    def initialize()
      @error_expression_start = /\"(.+)\",([0-9]+)\s+(internal |fatal )*([A-Za-z]+)([^:]*):\s*(.*)/
    end

    def scan_lines(consoleOutput, proj_dir)
      res = []
      error_severity = 255
      consoleOutputFullnames = ""
      lastValidErrorDesc = nil

      consoleOutput[0].each_line do |l|
        d = ErrorDesc.new
        lstripped = l.rstrip
        scan_res = lstripped.scan(@error_expression_start)
        if scan_res.length == 0
          if lastValidErrorDesc
            lastValidErrorDesc.message += l
            d.severity = lastValidErrorDesc.severity
          else
            d.severity = SEVERITY_OK
            d.message = lstripped
          end
          if lstripped == ""
            lastValidErrorDesc = nil
          end
        else
          d.file_name = File.expand_path(scan_res[0][0], proj_dir)
          d.line_number = scan_res[0][1].to_i
          d.message = scan_res[0][5]
          d.severity = get_severity(scan_res[0][3])
          error_severity = d.severity
          l.gsub!(scan_res[0][0],d.file_name)
          lastValidErrorDesc = d
        end
        res << d
        consoleOutputFullnames << l
      end
      [res, consoleOutputFullnames]
    end

  end
end
