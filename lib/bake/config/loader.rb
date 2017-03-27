require 'bake/model/loader'
require 'bake/config/checks'
require 'adapt/config/loader'

module Bake

  class Config
    attr_reader :referencedConfigs

    def initialize()
      @fullProjects = {}
      @defaultToolchainName = ""
      @mainProjectName = ""
      @mainConfigName = ""
    end

    def resolveConfigName(configs, configname)
      if (configname == "")
        if configs[0].parent.default != ""
          configname = configs[0].parent.default
        else
          Bake.formatter.printError("No default config specified", configs[0].file_name)
          ExitHelper.exit(1)
        end
      end
      return configname
    end

    def getFullProjectInternal(configs, configname, isMain) # note: configs is never empty

      configname = resolveConfigName(configs, configname)

      if isMain
        if Bake.options.qac
          configs.each do |c|
            if c.name == (configname + "Qac")
              configname = configname + "Qac"
              break
            end
          end
        end
      end

      config = nil
      configs.each do |c|
        if c.name == configname
          if config
            Bake.formatter.printError("Config '#{configname}' found more than once",config.file_name)
            ExitHelper.exit(1)
          end
          config = c
        end
      end

      if not config
        Bake.formatter.printError("Config '#{configname}' not found", configs[0].file_name)
        ExitHelper.exit(1)
      end

      if config.extends != ""
        config.extends.split(",").map {|ex| ex.strip}.reverse.each do |ex|
          if (ex != "")
            parent,parentConfigName = getFullProjectInternal(configs, ex, isMain)
            MergeConfig.new(config, parent).merge(:merge)
          end
        end
      end

      [config, configname]
    end

    def getFullProject(projName, configs, configname, isMain)

      configname = resolveConfigName(configs, configname)

      if @fullProjects.has_key?(projName + "," + configname)
        return @fullProjects[projName + "," + configname]
      end

      config, configname = getFullProjectInternal(configs, configname, isMain)

      if isMain
        @defaultToolchainName = config.defaultToolchain.basedOn unless config.defaultToolchain.nil?
        @mainProjectName = config.parent.name
        @mainConfigName = config.name
      end

      # check if config has to be manipulated
      @adaptConfigs.each do |c|

      if isMain
        @defaultToolchainName = config.defaultToolchain.basedOn unless config.defaultToolchain.nil?
        @mainProjectName = config.parent.name
        @mainConfigName = config.name
      end

      projPattern = /\A#{c.project.gsub("*", "(\\w*)")}\z/
      confPattern = /\A#{c.name.gsub("*", "(\\w*)")}\z/

       if projPattern.match(config.parent.name) or (isMain and c.project == "__MAIN__") or c.project == "__ALL__"
          if confPattern.match(config.name) or (isMain and c.name == "__MAIN__") or c.name == "__ALL__"

            conditionProjPattern = /\A#{c.parent.mainProject.gsub("*", "(\\w*)")}\z/
            conditionConfPattern = /\A#{c.parent.mainConfig.gsub("*", "(\\w*)")}\z/

            adaptCondition = (c.parent.toolchain == ""   || c.parent.toolchain == @defaultToolchainName) &&
              (c.parent.os == ""          || c.parent.os == Utils::OS.name) &&
              (c.parent.mainProject == "" || !conditionProjPattern.match(@mainProjectName).nil?) &&
              (c.parent.mainConfig ==  "" || !conditionConfPattern.match(@mainConfigName).nil?)

            invertLogic = (Bake::Metamodel::Unless === c.parent)
            next if (adaptCondition && invertLogic) || (!adaptCondition && !invertLogic)

            MergeConfig.new(c, config).merge(c.type.to_sym)

            if isMain # can be changed after adapt
              @defaultToolchainName = config.defaultToolchain.basedOn unless config.defaultToolchain.nil?
            end

          end
        end
      end

      @fullProjects[projName + "," + configname] = [config, configname]
      [config, configname]
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
            Bake.formatter.printError("Symlinks only allowed with the same parent dir as the target: #{dirOfProjMeta} --> #{Dir.pwd}", filename)
            ExitHelper.exit(1)
          end
        end
      end
    end

    def checkVerFormat(ver)
      return true if ver.empty?
      return false if ver.length > 3
      ver.each do |v|
        return false if not /\A\d+\z/.match(v)
      end
      true
    end

    def bailOutVer(reqVersion)
      text1 = (reqVersion.minimum.empty? ? "" : "minimum = #{reqVersion.minimum}")
      text2 = ((reqVersion.minimum.empty? or reqVersion.maximum.empty?) ? "" : ", ")
      text3 = (reqVersion.maximum.empty? ? "" : "maximum = #{reqVersion.maximum}")
      Bake.formatter.printError("Not compatible with installed bake version: #{text1 + text2 + text3}", reqVersion)
      ExitHelper.exit(1)
    end

    def checkVer(reqVersion)
      return if reqVersion.nil?
      min = reqVersion.minimum.split(".")
      max = reqVersion.maximum.split(".")
      cur = Bake::Version.number.split(".")

      if !checkVerFormat(min) or !checkVerFormat(max)
        Bake.formatter.printError("Version must be <major>.<minor>.<patch> whereas minor and patch are optional and all numbers >= 0.", reqVersion)
        ExitHelper.exit(1)
      end

      [min,max,cur].each { |arr| arr.map! {|x| x.to_i} }
      min.each_with_index do |v,i|
        break if v < cur[i]
        bailOutVer(reqVersion) if v > cur[i]
      end
      max.each_with_index do |v,i|
        break if v > cur[i]
        bailOutVer(reqVersion) if v < cur[i]
      end
    end

    def loadProjMeta(filename)

      Bake::Configs::Checks.symlinkCheck(filename)

      f = @loader.load(filename)

      config = nil

      projRoots = f.root_elements.select { |re| Metamodel::Project === re }
      if projRoots.length != 1
        Bake.formatter.printError("Config file must have exactly one 'Project' element as root element", filename)
        ExitHelper.exit(1)
      end
      proj = projRoots[0]

      reqVersion = proj.getRequiredBakeVersion
      checkVer(reqVersion)

      configs = proj.getConfig
      Bake::Configs::Checks::commonMetamodelCheck(configs, filename)

      configs.each do |c|
        if not c.project.empty?
          Bake.formatter.printError("Attribute 'project' must only be used in adapt config.",c)
          ExitHelper.exit(1)
        end
        if not c.type.empty?
          Bake.formatter.printError("Attribute 'type' must only be used in adapt config.",c)
          ExitHelper.exit(1)
        end
      end

      adaptRoots = f.root_elements.select { |re| Metamodel::Adapt === re }
      if adaptRoots.length > 0
        adaptRoots.each do |adapt|
          adapt.mainProject = @mainProjectName if adapt.mainProject == "__THIS__"
          adaptConfigs = adapt.getConfig
          AdaptConfig.checkSyntax(adaptConfigs, filename, true)
          adaptConfigs.each do |ac|
            ac.project = proj.name if ac.project == "__THIS__" || ac.project == ""
          end
          @adaptConfigs.concat(adaptConfigs)
        end
      end

      configs
    end


    def validateDependencies(config)
      config.dependency.each do |dep|
        if dep.name.include?"$" or dep.config.include?"$"
          Bake.formatter.printError("No variables allowed in Dependency definition", dep)
          ExitHelper.exit(1)
        end
        dep.name = config.parent.name if dep.name == ""
      end
    end

    def loadMeta(dep)
      dep_subbed = dep.name.gsub(/\\/,"/")
      if dep_subbed.include?":" or dep_subbed.include?"../" or dep_subbed.start_with?"/" or dep_subbed.end_with?"/"
        Bake.formatter.printError("#{dep.name}  is invalid", dep)
        ExitHelper.exit(1)
      end
      dep_path, dismiss, dep_name = dep_subbed.rpartition("/")

      # file not loaded yet
      if not @loadedConfigs.include?dep_name

        if Bake.options.verbose >= 3
          puts "First referenced by #{dep.parent.parent.name} (#{dep.parent.name}):"
        end

        pmeta_filenames = []

        @potentialProjs.each do |pp|
          if pp.include?("/" + dep_subbed + "/Project.meta") or pp == (dep_subbed + "/Project.meta")
            pmeta_filenames << pp
          end
        end

        if pmeta_filenames.empty?
          Bake.formatter.printError("#{dep.name}/Project.meta not found", dep)
          ExitHelper.exit(1)
        end

        if pmeta_filenames.length > 1
          Bake.formatter.printWarning("Project #{dep.name} exists more than once", dep)
          chosen = " (chosen)"
          pmeta_filenames.each do |f|
            Bake.formatter.printWarning("  #{File.dirname(f)}#{chosen}")
            chosen = ""
          end
        end

        @loadedConfigs[dep_name] = loadProjMeta(pmeta_filenames[0])
      else
        folder = @loadedConfigs[dep_name][0].get_project_dir
        if not folder.include?dep_subbed
          Bake.formatter.printError("Cannot load #{dep.name}, because #{folder} already loaded", dep)
          ExitHelper.exit(1)
        end

      end
      # get config
      if Bake.options.verbose >= 3
        puts "  #{dep_name} #{dep.config.empty? ? "<default>" : "("+dep.config+")"} referenced by #{dep.parent.parent.name} (#{dep.parent.name})"
      end
      config, dep.config = getFullProject(dep_name, @loadedConfigs[dep_name], dep.config, false)
      dep.name = dep_name

      # config not referenced yet
      if not @referencedConfigs.include?dep_name
        @referencedConfigs[dep_name] = [config]
      elsif @referencedConfigs[dep_name].index { |c| c.name == dep.config } == nil
        @referencedConfigs[dep_name] << config
      else
        return
      end

      validateDependencies(config)
      @depsPending += config.dependency
    end

    def loadMainMeta()
      mainMeta = Bake.options.main_dir+"/Project.meta"
      configs = loadProjMeta(mainMeta)
      @loadedConfigs = {}
      @loadedConfigs[Bake.options.main_project_name] = configs

      if not showConfigNames?
        config, Bake.options.build_config = getFullProject(Bake.options.main_project_name, configs,Bake.options.build_config, true)

        @referencedConfigs = {}
        @referencedConfigs[Bake.options.main_project_name] = [config]

        validateDependencies(config)
        @depsPending = config.dependency

        if Bake.options.build_config != "" and config.defaultToolchain == nil
          Bake.formatter.printError("Main project configuration must contain DefaultToolchain", config)
          ExitHelper.exit(1)
        end
      end

    end

    def checkRoots()
      @potentialProjs = []
      Bake.options.roots.each do |root|
        r = root.dir
        if (r.length == 3 && r.include?(":/"))
          r = r + Bake.options.main_project_name # glob would not work otherwise on windows (ruby bug?)
        end
        depthStr = root.depth.nil? ? "max" : root.depth.to_s
        puts "Checking root #{r} (depth: #{depthStr})" if Bake.options.verbose >= 1
        @potentialProjs.concat(Root.search_to_depth(r, "Project.meta", root.depth))
      end
      @potentialProjs.uniq!
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
          config.startupSteps.step  = config.startupSteps.step.delete_if  { |step| filterStep(step, "STARTUP") }  if config.startupSteps
          config.preSteps.step      = config.preSteps.step.delete_if      { |step| filterStep(step, "PRE") }      if config.preSteps
          config.postSteps.step     = config.postSteps.step.delete_if     { |step| filterStep(step, "POST") }     if config.postSteps
          config.exitSteps.step     = config.exitSteps.step.delete_if     { |step| filterStep(step, "EXIT") }     if config.exitSteps
          config.cleanSteps.step    = config.cleanSteps.step.delete_if    { |step| filterStep(step, "CLEAN") }    if config.cleanSteps
          if Metamodel::CustomConfig === config and config.step
            config.step = nil if filterStep(config.step, nil)
          end
        end
      end
    end

    def defaultConfigName
      @loadedConfigs[Bake.options.main_project_name].first.parent.default
    end

    def showConfigNames?
      Bake.options.showConfigs or (Bake.options.build_config == "" and defaultConfigName == "")
    end

    def printConfigNames
      mainConfigName = Bake.options.build_config != "" ? Bake.options.build_config : defaultConfigName
      configs = @loadedConfigs[Bake.options.main_project_name]
      foundValidConfig = false
      configs.each do |c|
        config, tmp = getFullProject(Bake.options.main_project_name, configs, c.name, c.name == mainConfigName)
        next if config.defaultToolchain.nil?
        Kernel.print "* #{config.name}"
        Kernel.print " (default)" if config.name == defaultConfigName
        Kernel.print ": #{config.description.text}" if config.description
        Kernel.print "\n"
        foundValidConfig = true
      end

      Bake.formatter.printWarning("No configuration with a DefaultToolchain found", Bake.options.main_dir+"/Project.meta") unless foundValidConfig
      ExitHelper.exit(0)
    end

    def printConfigs(adaptConfigs)
      @adaptConfigs = adaptConfigs
      @loader = Loader.new
      loadMainMeta # note.in cache only needed configs are stored
      printConfigNames
    end

    def load(adaptConfigs)
      @adaptConfigs = adaptConfigs
      @loader = Loader.new
      loadMainMeta
      printConfigNames if showConfigNames? # if neither config name nor default is set, list the configs with DefaultToolchain
      checkRoots
      while dep = @depsPending.shift
        loadMeta(dep)
      end

      filterSteps
      return @referencedConfigs
    end

  end
end
