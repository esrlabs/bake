require 'bake/model/loader'
require 'bake/options/options'

module Bake
  
  class ConfigNames
  
    def self.print(configs, default, filename)
      foundValidConfig = false
      configs.each do |c|
        next if c.defaultToolchain.nil?
        foundValidConfig = true
        Kernel.print "* #{c.name}"
        Kernel.print " (default)" if c.name ==  default
        Kernel.print ": #{c.description.text}" if c.description
        Kernel.print "\n"
      end
      Bake.formatter.printWarning("No configuration with a DefaultToolchain found", filename) unless foundValidConfig
      
      ExitHelper.exit(0)
    end
    
    def self.show
      loader = Loader.new
      filename = Bake.options.main_dir+"/Project.meta"
      f = loader.load(filename)
      
      if f.root_elements.length != 1 or not Metamodel::Project === f.root_elements[0]
        Bake.formatter.printError("Config file must have exactly one 'Project' element as root element", filename)
        ExitHelper.exit(1)
      end
      
      default = f.root_elements[0].default
      configs = f.root_elements[0].getConfig
 
      ConfigNames.print(configs, default, filename)
    end
  
  end

end