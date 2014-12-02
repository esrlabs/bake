module Bake
  
  class AbortException < StandardError
  end
  
  module Utils
  
    def self.flagSplit(str, removeQuotes)
      hasQuote = false
      hasDoubleQuote = false
      hadQuote = false
      ar = []
      s = ""
  
      #puts str
      
      str.split("").each do |i|
        hasDoubleQuote = !hasDoubleQuote if !hasQuote and i == '"'
        hasQuote = !hasQuote if !hasDoubleQuote and i == '\''
        hadQuote = true if hasDoubleQuote
        if i == ' '
          if not hasDoubleQuote and not hasQuote
            if hadQuote and removeQuotes
              ar << s[1..-2] if s.length > 2
              hadQuote = false
            else
              ar << s if s.length > 0
            end
            s = ""
            next
          end
        end
        s << i
      end
      ar << s if s.length > 0
      ar
    end  
  
    # Simple helper query the operating system we are running in
    module OS

      # Is it windows
      def OS.windows?
        (RUBY_PLATFORM =~ /cygwin|mswin|mingw|bccwin|wince|emx/) != nil
      end

      # Is it osx
      def OS.mac?
        (RUBY_PLATFORM =~ /darwin/) != nil
      end

      # Is it kind of unix
      def OS.unix?
        !OS.windows?
      end

      # Is it linux
      def OS.linux?
        OS.unix? and not OS.mac?
      end

    end

    def self.deep_copy(x)
      Marshal.load(Marshal.dump(x))
    end

    def self.old_ruby?
      RUBY_VERSION[0..2] == "1.8"
    end

  end
end
