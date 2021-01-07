module Bake
  class Version
    def self.number
      "2.67.0"
    end

    def self.printBakeVersion(ry = "")
      puts "-- bake#{ry} #{Bake::Version.number}, ruby #{RUBY_VERSION}p#{RUBY_PATCHLEVEL}, platform #{RUBY_PLATFORM} --"
    end

    def self.printBakeryVersion()
      printBakeVersion("ry")
    end

    def self.printBakeqacVersion()
      printBakeVersion("qac")
    end

    def self.printBakecleanVersion()
      printBakeVersion("clean")
    end

    def self.printBakeRtextServiceVersion()
      printBakeVersion("-rtext-service")
    end

    def self.printBakeFormatVersion()
      printBakeVersion("-format")
    end
  end

  deps = [
    ["rgen", "0.8.2"],
    ["rtext", "0.9.0"],
    ["concurrent-ruby", "1.0.5"],
    ["highline", "1.7.8"],
    ["colored", "1.2"],
    ["thwait", "0.1.0"],
    ["e2mmap", "0.1.0"]]

  deps.each do |d|
    begin
      gem d[0], "=#{d[1]}"
    rescue Exception => e
      puts "Error: Failed to load gem #{d[0]} #{d[1]}, please reinstall bake-toolkit."
      exit -1
    end
  end

end
