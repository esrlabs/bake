module Bake
  class License
    def self.show
      licenseFile = File.join(File.dirname(File.dirname(File.dirname(__FILE__))), "license.txt")
      puts File.read(licenseFile)
      ExitHelper.exit(0)
    end
  end
end
