require 'bake/model/loader'

module Bake

  class Config
    attr_reader :project2config
    attr_reader :defaultToolchain
    attr_reader :defaultToolchainTime
    
    def getFullProject(configs, configname, filename)
      config = nil
      configs.each do |c|
        if c.name == configname
          if config
            Bake.formatter.printError "Error: Config '#{configname}' found more than once in '#{filename}'"
            ExitHelper.exit(1)
          end
          config = c
        end
      end 
      
      if not config
        Bake.formatter.printError "Error: Config '#{configname}' not found in '#{filename}'"
        ExitHelper.exit(1)
      end
      
      if config.extends != ""
        parent = getFullProject(configs, config.extends, filename)
        MergeConfig.new(config, parent).merge()
      end
      
      config
    end
    
    def loadProjMeta(filename, configname)
      @project_files << filename
      f = @loader.load(filename)

      config = nil
      
      if f.root_elements.length != 1 or not Metamodel::Project === f.root_elements[0]
        Bake.formatter.printError "Error: '#{filename}' must have exactly one 'Project' element as root element"
        ExitHelper.exit(1)
      end
      
      f.root_elements.each do |e|
        x = e.getConfig
        config = getFullProject(x,configname,filename)
        
        x.each do |y|
          if y != config
            e.removeGeneric("Config", y)
          end
        end
      end
      f.mark_changed
      f.build_index
      
      # todo:extra methods for all steps here
      if config.respond_to?("toolchain") and config.toolchain
        config.toolchain.compiler.each do |c|
          if not c.internalDefines.nil? and c.internalDefines != ""
            Bake.formatter.printError "Error: #{c.file_name}(#{c.internalDefines.line_number}): InternalDefines only allowed in DefaultToolchain'"
            ExitHelper.exit(1)
          end
        end
      end
      
      config
    end
    

    def loadMeta(dep)

      # todo: allowed different configs
      if @project2config.include?dep.name
        if @project2config[dep.name].name != dep.config
          # todo: better error desc
          Bake.formatter.printError "Error: Different dependencies found to '#{dep.name}'"
          ExitHelper.exit(1)
        end
        return
      end
      
      # check if file is in more than one root
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
      

      config = loadProjMeta(pmeta_filenames[0], dep.config)
      

      
      @project2config[dep.name] = config
      
      @depsPending += config.dependency

    end
    
    def loadMainMeta()
      @mainProjectName = File::basename(Bake.options.main_dir)
     mainMeta = Bake.options.main_dir+"/Project.meta"
      if not File.exist?(mainMeta)
        Bake.formatter.printError "Error: #{mainMeta} not found"
        ExitHelper.exit(1)
      end
        
      @project_files = []
      @mainConfig = loadProjMeta(mainMeta, Bake.options.build_config)
        
      @project2config = {}
      @project2config[@mainProjectName] = @mainConfig
      
      
        
      if @mainConfig.defaultToolchain == nil
        Bake.formatter.printError "Error: Main project configuration must contain DefaultToolchain"
        ExitHelper.exit(1)
      end
      
      # todo: move to other class
      basedOn = @mainConfig.defaultToolchain.basedOn
      basedOn = "GCC_Lint" if Bake.options.lint # todo: no GCC_Lint
      @basedOnToolchain = Bake::Toolchain::Provider[basedOn]
      if @basedOnToolchain.nil?
        Bake.formatter.printError "Error: DefaultToolchain based on unknown compiler '#{basedOn}'"
        ExitHelper.exit(1)
      end
      @defaultToolchain = Utils.deep_copy(@basedOnToolchain)
      integrateToolchain(@defaultToolchain, @mainConfig.defaultToolchain)
      @defaultToolchainTime = File.mtime(mainMeta)
      
      @depsPending = @mainConfig.dependency

    end
    

            
    def checkRoots()
      @potentialProjs = []
      Bake.options.roots.each do |r|
        if (r.length == 3 && r.include?(":/"))
          r = r + @mainProjectName # glob would not work otherwise on windows (ruby bug?)
        end
        r = r+"/**{,/*/**}/Project.meta"  
        @potentialProjs.concat(Dir.glob(r))
      end
      
      @potentialProjs = @potentialProjs.uniq.sort
    end
    
    def checkDefaultToolchain(cache)
      @defaultToolchain = Utils.deep_copy(@basedOnToolchain)
      integrateToolchain(@defaultToolchain, @mainConfig.defaultToolchain)
      
      if (cache.defaultToolchain)
        unless @defaultToolchain[:LINKER][:FLAGS]               == @defaultToolchainCached[:LINKER][:FLAGS] and
          @defaultToolchain[:LINKER][:LIB_PREFIX_FLAGS]         == @defaultToolchainCached[:LINKER][:LIB_PREFIX_FLAGS] and
          @defaultToolchain[:LINKER][:LIB_POSTFIX_FLAGS]        == @defaultToolchainCached[:LINKER][:LIB_POSTFIX_FLAGS] and
          @defaultToolchain[:ARCHIVER][:FLAGS]                  == @defaultToolchainCached[:ARCHIVER][:FLAGS] and
          @defaultToolchain[:COMPILER][:CPP][:FLAGS]            == @defaultToolchainCached[:COMPILER][:CPP][:FLAGS] and
          @defaultToolchain[:COMPILER][:CPP][:DEFINES].join("") == @defaultToolchainCached[:COMPILER][:CPP][:DEFINES].join("") and
          @defaultToolchain[:COMPILER][:C][:FLAGS]              == @defaultToolchainCached[:COMPILER][:C][:FLAGS] and
          @defaultToolchain[:COMPILER][:C][:DEFINES].join("")   == @defaultToolchainCached[:COMPILER][:C][:DEFINES].join("") and
          @defaultToolchain[:COMPILER][:ASM][:FLAGS]            == @defaultToolchainCached[:COMPILER][:ASM][:FLAGS] and
          @defaultToolchain[:COMPILER][:ASM][:DEFINES].join("") == @defaultToolchainCached[:COMPILER][:ASM][:DEFINES].join("") and
          @defaultToolchain[:LINT_POLICY].join("")              == @defaultToolchainCached[:LINT_POLICY].join("")
          @defaultToolchainTime = @mainMetaTime
        end
      end
      
    end
    
    def load()
      @loader = Loader.new
      cache = CacheAccess.new()
      @project2config = cache.load_cache unless Bake.options.nocache

      # cache invalid or forced to reload
      if @project2config.nil?
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
            @defaultToolchainTime = cache.defaultToolchainTime
          end
        end
        
        cache.write_cache(@project_files, @project2config, @defaultToolchain, @defaultToolchainTime)
      else
        @defaultToolchain = cache.defaultToolchain
        @defaultToolchainTime = cache.defaultToolchainTime
      end
    end
    
    
  end

end
