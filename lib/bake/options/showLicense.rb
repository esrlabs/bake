module Bake
  class License
    def self.show
      licenseFile = File.join(__FILE__, "../../../../license.txt")
      puts "\n" + File.read(licenseFile)
      ExitHelper.exit(0)
    end
  end
end
