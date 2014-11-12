require 'imported/utils/optional'

module Bake
  include Utils

  class ColorizingFormatter
    class << self
      attr_accessor :enabled
    end
    def enabled?
      false
    end
  end

  define_colorizin_formatter = lambda do
    require 'colored'

    # simple class to colorize compiler output
    # the class depends on the rainbow gem
    class ColorizingFormatter
    
      # colors are not instance vars due to caching the building blocks
      def self.setColorScheme(scheme)
        if scheme == :black
          @@warning_color = :yellow
          @@error_color = :red
          @@info_color = :white
          @@additional_info_color = :cyan
          @@success_color = :green
        elsif scheme == :white
          @@warning_color = :magenta
          @@error_color = :red
          @@info_color = :black
          @@additional_info_color = :blue
          @@success_color = :green
        end
      end
      ColorizingFormatter.setColorScheme(:black) # default

      def printError(str)
        [@@error_color,:bold].inject(str) {|m,x| m.send(x)}
      end

      def printWarning(str)
        [@@warning_color,:bold].inject(str) {|m,x| m.send(x)}
      end

      def printInfo(str)
        [@@info_color,:bold].inject(str) {|m,x| m.send(x)}
      end

      def printAdditionalInfo(str)
        [@@additional_info_color,:bold].inject(str) {|m,x| m.send(x)}
      end

      def printSuccess(str)
        [@@success_color,:bold].inject(str) {|m,x| m.send(x)}
      end

      # formats several lines of usually compiler output
      def format(compiler_output, error_descs, error_parser)
        return compiler_output if not enabled?
        res = ""
        begin
          zipped = compiler_output.split($/).zip(error_descs)
          zipped.each do |l,desc|
            if desc.severity != 255
              coloring = {}
              if desc.severity == ErrorParser::SEVERITY_WARNING
                res << printWarning(l)
              elsif desc.severity == ErrorParser::SEVERITY_ERROR
                res << printError(l)
              else
                res << printInfo(l)
              end
            else
              res << l
            end
            res << "\n" 
          end
        rescue Exception => e
          puts "Error while parsing compiler output: #{e}"
          return compiler_output
        end
        res
      end

      # getter to access the static variable with an instance
      def enabled?
        return ColorizingFormatter.enabled
      end

    end

  end

  Utils.optional_package(define_colorizin_formatter, nil)

end
