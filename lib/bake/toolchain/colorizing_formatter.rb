require 'colored'

module Bake
  #include Utils ????

  class ColorizingFormatter
    
    def initialize
      @scheme = :none
    end
  
    def setColorScheme(scheme)
      
      if (scheme != :black and scheme != :white and scheme != :none)
        Bake.formatter.printError "Error: color scheme must be 'black' or 'white'"
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
      puts (@scheme == :none ? str : [col,:bold].inject(str) {|m,x| m.send(x)})
    end
    
    def printError(str)
      printInternal(@error_color, str)
    end
  
    def printWarning(str)
      printInternal(@warning_color, str)
    end
  
    def printInfo(str)
      printInternal(@info_color, str)
    end
  
    def printAdditionalInfo(str)
      printInternal(@additional_info_color, str)
    end
  
    def printSuccess(str)
      printInternal(@success_color, str)
    end
  
    # formats several lines of usually compiler output
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
