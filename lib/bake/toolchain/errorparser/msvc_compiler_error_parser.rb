require 'bake/toolchain/errorparser/error_parser'

module Bake
  class MSVCCompilerErrorParser < ErrorParser

    def initialize()
      @error_expression = /(.+)\(([0-9]+)\) : ([A-Za-z\._]+) (C[\d]+: .+)/
      @incEng = "Note: including file: "
      @incGer = "Hinweis: Einlesen der Datei: "
    end

    def scan_lines(consoleOutput, proj_dir)
      includeList = []
      res = []
      consoleOutputFiltered = ""
      consoleOutputFullnames = ""
      filterLine = 0
      consoleOutput[0].each_line do |l|
        filterLine = filterLine + 1
        next if (filterLine == 1 and l.include?"Assembling: ")
        if (filterLine <= 2 and l.include?"Microsoft (R)")
          filterLine = 1
          next 
        end
        next if (filterLine == 2 and l.include?"Copyright (C)")
        next if (filterLine == 3 and l.strip.empty?)
        next if (filterLine == 4 and not l.include?" : " and l.include?".") # the source file
        filterLine = 100
        
        if l.include?@incEng
          includeList << l[@incEng.length..-1].strip
          next
        end
        if l.include?@incGer
          includeList << l[@incGer.length..-1].strip
          next
        end
        
        d = ErrorDesc.new
        scan_res = l.gsub(/\r\n?/, "").scan(@error_expression)
        lFull = l
        if scan_res.length > 0
          d.file_name = File.expand_path(scan_res[0][0])
          d.line_number = scan_res[0][1].to_i
          d.message = scan_res[0][3]
          if (scan_res[0][2].include?".")
            d.severity = SEVERITY_ERROR
            d.message = scan_res[0][2] + ": " + d.message
          else
            d.severity = get_severity(scan_res[0][2])
          end
          lFull = l.gsub(scan_res[0][0],d.file_name)
        end
        res << d
        consoleOutputFiltered << l
        consoleOutputFullnames << lFull
      end
      consoleOutput[0] = consoleOutputFiltered
      [res, consoleOutputFullnames, includeList.uniq]
    end

  end
end
