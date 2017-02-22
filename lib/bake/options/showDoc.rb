require "open-uri"
require "fileutils"
require "common/version"
require "openssl"

module Bake
  class Doc
    def self.show
      if File.exist?(File.dirname(__FILE__)+"/../../../docs/index.html")
        link = File.expand_path(File.dirname(__FILE__)+"/../../../docs/index.html")
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

      docuSource = "https://raw.githubusercontent.com/esrlabs/bake/$(Bake::Version.number)/docs/"
      docuTarget = File.dirname(__FILE__)+"/../../../doc/"
      begin
        f = open(docuSource+"files.txt", {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE})
      rescue OpenURI::HTTPError => e
        puts "Could not open #{docuSource}files.txt"
        ExitHelper.exit(0)
      end
      f.each_line do |fileName|
        fileName = fileName[2..-1].strip
        begin
          sourceFile = open(docuSource+fileName, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE})
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
