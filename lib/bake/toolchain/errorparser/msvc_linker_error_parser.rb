require 'bake/toolchain/errorparser/error_parser'

module Bake
  class MSVCLinkerErrorParser < ErrorParser

    def initialize()
      # todo: is every line an error?
    end

    def scan_lines(consoleOutput, proj_dir)
      res = []
      consoleOutputFiltered = ""
      filterLine = 0

      consoleOutput[0].each_line do |l|
      filterLine = filterLine + 1
        next if (filterLine == 1 and l.include?"Microsoft (R)")
        next if (filterLine == 2 and l.include?"Copyright (C)")
        next if (filterLine == 3 and l.strip.empty?)

        l.rstrip!
        d = ErrorDesc.new
        d.file_name = proj_dir
        d.line_number = 0
        d.message = l
        if l.length == 0
          d.severity = SEVERITY_OK
        elsif l.include?" Warning:"
          d.severity = SEVERITY_WARNING
        else
          d.severity = SEVERITY_ERROR
        end
        consoleOutputFiltered << l
        res << d
      end
      consoleOutput[0] = consoleOutputFiltered
      [res, consoleOutput[0]]
    end


  end
end
