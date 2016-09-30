module Bake

  module Utils

    def self.flagSplit(str, removeQuotes)
      return [] if str == ""
      return [str] unless str.include?" "

      hasQuote = false
      hasDoubleQuote = false
      hadQuote = false
      ar = []
      s = ""

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

    end

    def self.deep_copy(x)
      Marshal.load(Marshal.dump(x))
    end

  end
end
