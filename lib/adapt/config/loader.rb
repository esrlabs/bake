require 'bake/model/loader'
require 'bake/config/checks'

module Bake

  class AdaptConfig
    attr_reader :referencedConfigs
    
    @@filenames = []
    
    def self.filenames
      @@filenames
    end 
    
    def loadProjMeta(filename, filenum)
      
      Bake::Configs::Checks.symlinkCheck(filename)
      
      f = @loader.load(filename)
    
      if f.root_elements.length != 1 or not Metamodel::Adapt === f.root_elements[0]
        Bake.formatter.printError("Config file must have exactly one 'Adapt' element as root element", filename)
        ExitHelper.exit(1)
      end
      
      adapt = f.root_elements[0]
      configs = adapt.getConfig
      
      Bake::Configs::Checks::commonMetamodelCheck(configs, filename)
      
      configs.each do |c|
        if not c.extends.empty?
          Bake.formatter.printError("Attribute 'extends' must not be used in adapt config.",c) 
          ExitHelper.exit(1)
        end
        if c.name.empty?
          Bake.formatter.printError("Configs must be named.",c) 
          ExitHelper.exit(1)
        end
        if c.project.empty?
          Bake.formatter.printError("The corresponding project must be specified.",c) 
          ExitHelper.exit(1)
        end
        if not ["replace", "remove", "extend"].include?c.type
          Bake.formatter.printError("Allowed types are 'replace', 'remove' and 'extend'.",c) 
          ExitHelper.exit(1)
        end
      end
      
      configs.each do |c|
        [:exLib, :exLibSearchPath, :userLibrary].each do |name|
          c.method(name).call().each { |l| l.line_number += (1000000*filenum)  }
        end        
      end
      
      configs
    end    
    
    def getPotentialAdaptionProjects()
      potentialAdapts = []
      Bake.options.roots.each do |r|
        if (r.length == 3 && r.include?(":/"))
          r = r + Bake.options.main_project_name # glob would not work otherwise on windows (ruby bug?)
        end        
        Bake.options.adapt.each do |a|
          fn = r+"/**{,/*/**}/#{a}/Adapt.meta"
          potentialAdapts.concat(Dir.glob(fn).sort)
        end
      end
      
      potentialAdapts.uniq
    end    
    
    def chooseProjectFilenames(potentialAdapts)      
      @@filenames = []
        
      Bake.options.adapt.each do |a|        
        adapts = potentialAdapts.find_all { |p| p.include?(a+"/Adapt.meta") }        
        if adapts.empty?
          Bake.formatter.printError("Adaption project #{a} not found")
          ExitHelper.exit(1)
        else
          @@filenames << adapts[0]
          if (adapts.length > 1)
            Bake.formatter.printWarning("Adaption project #{a} exists more than once")
            chosen = " (chosen)"
            adapts.each do |f|
              Bake.formatter.printWarning("  #{File.dirname(f)}#{chosen}")
              chosen = ""
            end
          end
        end
      end
       
    end
    
    def load()
      @@filenames = []
      return [] if Bake.options.adapt.empty?
      
      @loader = Loader.new
      
      potentialProjects = getPotentialAdaptionProjects()
      chooseProjectFilenames(potentialProjects)
      
      configs = []
      @@filenames.each_with_index do |f,i|
        configs.concat(loadProjMeta(f, i+1))
      end
      
      return configs        
    end
    
    
  end

end
