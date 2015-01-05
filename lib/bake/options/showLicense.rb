module Bake
  class License
    def self.show
      licenseFile = File.join(File.dirname(__FILE__), "../../../license.txt")
      puts "\n" + File.read(licenseFile)
      ExitHelper.exit(0)
    end
  end
end
