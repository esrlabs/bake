require 'bake/model/loader'
require 'bake/options/options'

module Bake
  
  class ConfigNames
  
    def self.show
      loader = Loader.new
      filename = Bake.options.main_dir+"/Project.meta"
      f = loader.load(filename)
      
      if f.root_elements.length != 1 or not Metamodel::Project === f.root_elements[0]
        Bake.formatter.printError("Config file must have exactly one 'Project' element as root element", filename)
        ExitHelper.exit(1)
      end
      
      default = f.root_elements[0].default
      
      validConfigs = []
      f.root_elements[0].getConfig.each do |c|
        validConfigs << c.name unless c.defaultToolchain.nil?
      end
      if validConfigs.length > 0
        validConfigs.each do |v|
          d = ""
          d = " (default)" if v == default
          puts "* " + v + d
        end 
      else
        Bake.formatter.printWarning("No configuration with a DefaultToolchain found", filename)
      end
      
      ExitHelper.exit(0)
    end
  
  end

end