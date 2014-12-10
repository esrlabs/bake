require 'bake/model/loader'

module Bake

  class Config
    attr_reader :referencedConfigs
    attr_reader :defaultToolchain
    
    @@defaultToolchainTime = nil
    
    def self.defaultToolchainTime
      @@defaultToolchainTime
    end
    
    def getFullProject(configs, configname)
      config = nil
      configs.each do |c|
        if c.name == configname
          if config
            Bake.formatter.printError "Error: Config '#{configname}' found more than once in '#{config.file_name}'"
            ExitHelper.exit(1)
          end
          config = c
        end
      end 
      
      if not config
        Bake.formatter.printError "Error: Config '#{configname}' not found in '#{configs[0].file_name}'"
        ExitHelper.exit(1)
      end
      
      if config.extends != ""
        parent = getFullProject(configs, config.extends)
        MergeConfig.new(config, parent).merge()
      end
      
      config
    end

    def symlinkCheck(filename)
      dirOfProjMeta = File.dirname(filename)
      Dir.chdir(dirOfProjMeta) do
        if Dir.pwd != dirOfProjMeta and File.dirname(Dir.pwd) != File.dirname(dirOfProjMeta)
          isSym = false
          begin
            isSym = File.symlink?(dirOfProjMeta)
          rescue
          end
          if isSym
            message = "Error: symlinks only allowed with the same parent dir as the target: #{dirOfProjMeta} --> #{Dir.pwd}"
            res = Bake::ErrorDesc.new
            res.file_name = dirOfProjMeta
            res.line_number = 0
            res.severity = Bake::ErrorParser::SEVERITY_ERROR
            res.message = message
            Bake::IDEInterface.instance.set_errors([res])
            Bake.formatter.printError message
            ExitHelper.exit(1)
          end
        end
      end
    end
        
    
    def loadProjMeta(filename)
      
      symlinkCheck(filename)
      
      @project_files << filename
      f = @loader.load(filename)

      config = nil
      
      if f.root_elements.length != 1 or not Metamodel::Project === f.root_elements[0]
        Bake.formatter.printError "Error: '#{filename}' must have exactly one 'Project' element as root element"
        ExitHelper.exit(1)
      end
      
      configs = f.root_elements[0].getConfig
      
      if configs.length == 0
        Bake.formatter.printError "Error: #{c.file_name}: No config found"
        ExitHelper.exit(1)
      end
      
      configs.each do |config|
        # todo:extra methods for all steps here
        if config.respond_to?("toolchain") and config.toolchain
          config.toolchain.compiler.each do |c|
            if not c.internalDefines.nil? and c.internalDefines != ""
              Bake.formatter.printError "Error: #{c.file_name}(#{c.internalDefines.line_number}): InternalDefines only allowed in DefaultToolchain"
              ExitHelper.exit(1)
            end
          end
        end
      end
        
        
        ####config = getFullProject(x,configname,filename)
        
        #x.each do |y|
        #  if y != config
        #    e.removeGeneric("Config", y)
        #  end
        #end
      #end
      #f.mark_changed
      #f.build_index
      


      
      configs
    end
    
    
    def validateDependencies(config)
      config.dependency.each do |dep|
        if dep.name.include?"$" or dep.config.include?"$"
          Bake.formatter.printError "Error: #{dep.file_name}(#{dep.line_number}): No variables allowed in Dependency definition"
          ExitHelper.exit(1)
        end
        dep.name = config.parent.name if dep.name == ""
      end
    end

    def loadMeta(dep)

      # file not loaded yet
      if not @loadedConfigs.include?dep.name
        
        pmeta_filenames = []
          
        @potentialProjs.each do |pp|
          if pp.include?("/" + dep.name + "/Project.meta") or pp == (dep.name + "/Project.meta") 
            pmeta_filenames << pp
          end
        end
  
        if pmeta_filenames.empty?
          Bake.formatter.printError "Error: #{dep.name}/Project.meta not found"
          ExitHelper.exit(1)
        end
        
        if pmeta_filenames.length > 1
          Bake.formatter.printWarning "Warning: #{dep.name} exists more than once:"
          chosen = " (chosen)"
          pmeta_filenames.each do |f|
            Bake.formatter.printWarning "  #{f}#{chosen}"
            chosen = ""
          end
        end
        
        @loadedConfigs[dep.name] = loadProjMeta(pmeta_filenames[0])
      end
      
      # get config
      config = getFullProject(@loadedConfigs[dep.name],dep.config)
      
      # config not referenced yet
      if not @referencedConfigs.include?dep.name
        @referencedConfigs[dep.name] = [config] 
      elsif @referencedConfigs[dep.name].index { |c| c.name == dep.config } == nil
        @referencedConfigs[dep.name] << config
      else
        return
      end
      
      validateDependencies(config)
      @depsPending += config.dependency

      
      
            
#      # todo: allowed different configs
#      if @project2config.include?dep.name
#        if @project2config[dep.name].name != dep.config
#          # todo: better error desc
#          Bake.formatter.printError "Error: Different dependencies found to '#{dep.name}'"
#          ExitHelper.exit(1)
#        end
#        return
#      end
      
      # check if file is in more than one root


      

      
#      @project2config[dep.name] = config
      

    end
    
    def loadMainMeta()
      mainMeta = Bake.options.main_dir+"/Project.meta"
      if not File.exist?(mainMeta)
        Bake.formatter.printError "Error: #{mainMeta} not found"
        ExitHelper.exit(1)
      end
        
      @project_files = []
      
      configs = loadProjMeta(mainMeta)
      @loadedConfigs = {}
      @loadedConfigs[Bake.options.main_project_name] = configs
      
      config = getFullProject(configs,Bake.options.build_config)
      @referencedConfigs = {}
      @referencedConfigs[Bake.options.main_project_name] = [config]
        
      if config.defaultToolchain == nil
        Bake.formatter.printError "Error: Main project configuration must contain DefaultToolchain"
        ExitHelper.exit(1)
      end
      
      # todo: move to other class
      basedOn = config.defaultToolchain.basedOn
      @basedOnToolchain = Bake::Toolchain::Provider[basedOn]
      if @basedOnToolchain.nil?
        Bake.formatter.printError "Error: DefaultToolchain based on unknown compiler '#{basedOn}'"
        ExitHelper.exit(1)
      end
      @defaultToolchain = Utils.deep_copy(@basedOnToolchain)
      integrateToolchain(@defaultToolchain, config.defaultToolchain)
      @@defaultToolchainTime = File.mtime(mainMeta)
      
      validateDependencies(config)
      @depsPending = config.dependency
    end
    
    def checkRoots()
      @potentialProjs = []
      Bake.options.roots.each do |r|
        if (r.length == 3 && r.include?(":/"))
          r = r + Bake.options.main_project_name # glob would not work otherwise on windows (ruby bug?)
        end
        r = r+"/**{,/*/**}/Project.meta"  
        @potentialProjs.concat(Dir.glob(r))
      end
      
      @potentialProjs = @potentialProjs.uniq.sort
    end
    
    
    def filterStep(step, globalFilterStr)
      
      # 1st prio: explicit single filter
      if step.filter != "" 
        return true if  Bake.options.exclude_filter.include?step.filter
        return false if Bake.options.include_filter.include?step.filter
      end 

      # 2nd prio: explicit global filter
      if globalFilterStr != nil
        return true if  Bake.options.exclude_filter.include?globalFilterStr
        return false if Bake.options.include_filter.include?globalFilterStr
      end      
      
      # 3nd prio: default
      return true if step.default == "off"
      false      
    end
        
    def filterSteps
      @referencedConfigs.each do |projName, configs|
        configs.each do |config|
          config.preSteps.step  = config.preSteps.step.delete_if  { |step| filterStep(step, "PRE") }  if config.preSteps
          config.postSteps.step = config.postSteps.step.delete_if { |step| filterStep(step, "POST") } if config.postSteps
        end
      end
    end

    def load()
      @loader = Loader.new
      cache = CacheAccess.new()
      @referencedConfigs = cache.load_cache unless Bake.options.nocache

      # cache invalid or forced to reload
      if @referencedConfigs.nil?
        loadMainMeta
        checkRoots
        while dep = @depsPending.shift
          loadMeta(dep)
        end

        if (cache.defaultToolchain)
          if @defaultToolchain[:LINKER][:FLAGS]                   == cache.defaultToolchain[:LINKER][:FLAGS] and
            @defaultToolchain[:LINKER][:LIB_PREFIX_FLAGS]         == cache.defaultToolchain[:LINKER][:LIB_PREFIX_FLAGS] and
            @defaultToolchain[:LINKER][:LIB_POSTFIX_FLAGS]        == cache.defaultToolchain[:LINKER][:LIB_POSTFIX_FLAGS] and
            @defaultToolchain[:ARCHIVER][:FLAGS]                  == cache.defaultToolchain[:ARCHIVER][:FLAGS] and
            @defaultToolchain[:COMPILER][:CPP][:FLAGS]            == cache.defaultToolchain[:COMPILER][:CPP][:FLAGS] and
            @defaultToolchain[:COMPILER][:CPP][:DEFINES].join("") == cache.defaultToolchain[:COMPILER][:CPP][:DEFINES].join("") and
            @defaultToolchain[:COMPILER][:C][:FLAGS]              == cache.defaultToolchain[:COMPILER][:C][:FLAGS] and
            @defaultToolchain[:COMPILER][:C][:DEFINES].join("")   == cache.defaultToolchain[:COMPILER][:C][:DEFINES].join("") and
            @defaultToolchain[:COMPILER][:ASM][:FLAGS]            == cache.defaultToolchain[:COMPILER][:ASM][:FLAGS] and
            @defaultToolchain[:COMPILER][:ASM][:DEFINES].join("") == cache.defaultToolchain[:COMPILER][:ASM][:DEFINES].join("") and
            @defaultToolchain[:LINT_POLICY].join("")              == cache.defaultToolchain[:LINT_POLICY].join("")
            @@defaultToolchainTime = cache.defaultToolchainTime
          end
        end
        
        filterSteps
        
        cache.write_cache(@project_files, @referencedConfigs, @defaultToolchain, @@defaultToolchainTime)
      else
        @defaultToolchain = cache.defaultToolchain
        @@defaultToolchainTime = cache.defaultToolchainTime
      end
      
    end
    
    
  end

end
