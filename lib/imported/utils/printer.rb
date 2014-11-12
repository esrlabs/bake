require 'imported/toolchain/colorizing_formatter'

module Bake
  
  class Printer
    @@cf = ColorizingFormatter.new
    
    def self.printInfo(str)
      if @@cf.enabled?
        puts @@cf.printInfo(str)
      else
        puts str
      end
    end
    
    def self.printAdditionalInfo(str)
      if @@cf.enabled?
        puts @@cf.printAdditionalInfo(str)
      else
        puts str
      end
    end
    
    def self.printWarning(str)
      if @@cf.enabled?
        puts @@cf.printWarning(str)
      else
        puts str
      end
    end

    def self.printError(str)
      if @@cf.enabled?
        puts @@cf.printError(str)
      else
        puts str
      end
    end

    def self.printSuccess(str)
      if @@cf.enabled?
        puts @@cf.printSuccess(str)
      else
        puts str
      end
    end
   
  end
  
end
