require "open-uri"
require "fileutils"

module Bake
  class Doc
    def self.show
      if File.exist?(File.dirname(__FILE__)+"/../../../doc/index.html")
        link = File.expand_path(File.dirname(__FILE__)+"/../../../doc/index.html")
      else
        link = "http://esrlabs.github.io/bake"
      end

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

    def self.install
      docuSource = "http://esrlabs.github.io/bake/"
      docuTarget = File.dirname(__FILE__)+"/../../../doc/"
      begin
        f = open(docuSource+"files.txt")
      rescue OpenURI::HTTPError => e
        puts "Could not open #{docuSource}files.txt"
        ExitHelper.exit(0)
      end
      f.each_line do |fileName|
        fileName = fileName[2..-1].strip
        begin
          sourceFile = open(docuSource+fileName)
        puts "[OK]     "+ docuSource+fileName
        rescue OpenURI::HTTPError => e
          puts "[FAILED] "+ docuSource+fileName
        next
        end
        FileUtils.mkdir_p(File.dirname(docuTarget+fileName))
        File.open(docuTarget+fileName, "wb") do |file|
        file.puts sourceFile.read
        end
      end
      ExitHelper.exit(0)
    end

  end
end
