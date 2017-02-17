require 'bake/toolchain/errorparser/error_parser'

module Bake
  class TaskingCompilerErrorParser < ErrorParser

    def initialize()
      @error_expression = /.* (.+): \[\"(.+)\" ([0-9]+)\] (.*)/
    end

    def scan_lines(consoleOutput, proj_dir)
      res = []
      consoleOutputFullnames = ""
      consoleOutput[0].each_line do |l|
        d = ErrorDesc.new
        lstripped = l.rstrip
        scan_res = lstripped.scan(@error_expression)
        if scan_res.length > 0
          d.file_name = File.expand_path(scan_res[0][1])
          d.line_number = scan_res[0][2].to_i
          d.message = scan_res[0][3]
          d.severity = get_tasking_severity(scan_res[0][0])
          l.gsub!(scan_res[0][0],d.file_name)
        end
        res << d
        consoleOutputFullnames << l
      end
      [res, consoleOutputFullnames]
    end

  end
end
