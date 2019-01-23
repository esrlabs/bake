module Bake

  class ErrorDesc
    def initialize
      @severity = 255
    end
    attr_accessor :severity
    attr_accessor :line_number
    attr_accessor :message
    attr_accessor :file_name
  end

  class ErrorParser

    SEVERITY_INFO = 0
    SEVERITY_WARNING = 1
    SEVERITY_ERROR = 2
    SEVERITY_OK = 255

    def scan(consoleOutput, proj_dir)
      raise "Use specialized classes only"
    end

    def get_severity(str)
      if str.downcase == "info" || str.downcase == "note" || str.downcase == "remark"
        SEVERITY_INFO
      elsif str.downcase == "warning"
        SEVERITY_WARNING
      else
        SEVERITY_ERROR
      end
    end

    def get_tasking_severity(str)
      return SEVERITY_INFO if str.start_with?"R"
      return SEVERITY_WARNING if str.start_with?"W"
      return SEVERITY_ERROR  # F,E and S
    end

    def inv_severity(s)
      if s == SEVERITY_INFO
        "info"
      elsif s == SEVERITY_WARNING
        "warning"
      elsif s == SEVERITY_ERROR
        "error"
      else
        raise "Unknown severity: #{s}"
      end
    end

    # scan the output from the console line by line and return a list of ErrorDesc objects.
    # for none-error/warning lines the description object will indicate that as severity 255
    # for single line errors/warnings: description will contain severity, line-number, message and file-name
    #
    # for multi-line errors/warnings:
    #   one description object for each line, first one will contain all single line error information,
    #   all following desc.objects will just repeat the severity and include the message
    #
    def scan_lines(consoleOutput, proj_dir)
      raise "Use specialized classes only"
    end

    def makeVsError(line, d)
      if d.file_name == nil
        return line
      end

      ret = d.file_name
      ret = ret + "(" + d.line_number.to_s + ")" if (d.line_number and d.line_number > 0)
      ret = ret + ": " + inv_severity(d.severity) + ": " + d.message
      return ret
    end

  end

end
