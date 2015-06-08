module Bake
  class Doc
    def self.show

      link = File.expand_path(File.dirname(__FILE__)+"/../../../doc/index.html")
      if RUBY_PLATFORM =~ /mswin|mingw|cygwin/
        system "start #{link}"
      elsif RUBY_PLATFORM =~ /darwin/
        system "open #{link}"
      elsif RUBY_PLATFORM =~ /linux|bsd/
        system "xdg-open #{link}"
      else
        puts "Please open #{link} manually in your browser."
      end
      
      ExitHelper.exit(0)
    end
    
    def self.deprecated
      puts "Option \"--doc\" not supported anymore. Please use"
      puts "\"--show_doc\" to open the documentation in the browser OR"
      puts "\"--docu\" for building the documentation of a project."
      ExitHelper.exit(1)
    end
    
  end
end
