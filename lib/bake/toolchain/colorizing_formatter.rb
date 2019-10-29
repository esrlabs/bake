require 'colored'

module Bake
  #include Utils ????

  class ColorizingFormatter

    def initialize
      @scheme = :none
    end

    def setColorScheme(scheme)

      if (scheme != :black and scheme != :white and scheme != :none)
        Bake.formatter.printError("Error: color scheme must be 'black', 'white' or 'none'")
        ExitHelper.exit(1)
      end
      @scheme = scheme

      if @scheme == :black
        @warning_color = :yellow
        @error_color = :red
        @info_color = :white
        @additional_info_color = :cyan
        @success_color = :green
      elsif @scheme == :white
        @warning_color = :magenta
        @error_color = :red
        @info_color = :black
        @additional_info_color = :blue
        @success_color = :green
      end
    end

    def printInternal(col, str)
      puts(@scheme == :none ? str : [col,:bold].inject(str) {|m,x| m.send(x)})
    end

    def createIdeError(str, file_name, line_number, severity)
      if (file_name)
        d = ErrorDesc.new
        d.file_name = file_name
        d.line_number = (line_number ? line_number : 0)
        d.message = str
        d.severity = severity
        Bake::IDEInterface.instance.set_errors([d])
      end
    end

    def processString(prefix, str, file_name_or_elem, line_num, severity)
      if file_name_or_elem.respond_to?("file_name")
        file_name = file_name_or_elem.file_name
        line_num = file_name_or_elem.line_number
      elsif String === file_name_or_elem
        file_name = file_name_or_elem
      else
        file_name = nil
      end

      createIdeError(str, file_name, line_num, severity)

      line = (line_num ? ":#{line_num}" : "")
      file = (file_name ? "#{file_name}#{line}: " : "")
      return file + prefix + ": " + str
    end

    def printError(str, file_name_or_elem=nil, line_num=nil)
      str = processString("Error", str, file_name_or_elem, line_num, Bake::ErrorParser::SEVERITY_ERROR) if file_name_or_elem
      printInternal(@error_color, str)
    end

    def printWarning(str, file_name=nil, line_num=nil)
      str = processString("Warning", str, file_name, line_num, Bake::ErrorParser::SEVERITY_WARNING) if file_name
      printInternal(@warning_color, str)
    end

    def printInfo(str, file_name=nil, line_num=nil)
      str = processString("Info", str, file_name, line_num, Bake::ErrorParser::SEVERITY_INFO) if file_name
      printInternal(@info_color, str)
    end

    def printAdditionalInfo(str)
      printInternal(@additional_info_color, str)
    end

    def printSuccess(str)
      printInternal(@success_color, str)
    end

    # formats several lines of compiler output
    def format(compiler_output, error_descs, error_parser)
      if @scheme == :none
        puts compiler_output
      else
        begin
          zipped = compiler_output.split($/).zip(error_descs)
          zipped.each do |l,desc|
            if desc.severity != 255
              coloring = {}
              if desc.severity == ErrorParser::SEVERITY_WARNING
                printWarning(l)
              elsif desc.severity == ErrorParser::SEVERITY_ERROR
                printError(l)
              else
                printInfo(l)
              end
            else
              puts l
            end
          end
        rescue Exception => e
          puts "Error while parsing output: #{e}"
          puts e.backtrace if Bake.options.debug
          puts compiler_output
        end
      end
    end
  end

def self.formatter
  @@formatter ||= ColorizingFormatter.new
end


end
