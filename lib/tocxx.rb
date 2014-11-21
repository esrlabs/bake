#!/usr/bin/env ruby

gem 'rake', '>= 0.7.3'

require 'rake'
require 'rake/clean'
require 'bake/model/metamodel_ext'
require 'bake/util'
require 'bake/cache'
require 'bake/subst'
require 'bake/mergeConfig'
require 'bake/model/loader'
require 'imported/buildingblocks/module'
require 'imported/buildingblocks/makefile'
require 'imported/buildingblocks/executable'
require 'imported/buildingblocks/lint'
require 'imported/buildingblocks/binary_library'
require 'imported/buildingblocks/custom_building_block'
require 'imported/buildingblocks/command_line'
require 'imported/buildingblocks/single_source'
require 'imported/utils/exit_helper'
require 'imported/ide_interface'
require 'imported/ext/file'
require 'imported/toolchain/provider'
require 'imported/ext/stdout'
require 'imported/ext/rake'
require 'imported/utils/utils'
require 'imported/toolchain/colorizing_formatter'

require 'set'
require 'socket'

#require 'ruby-prof'

module Bake

  class ToCxx

    def initialize
      @configTcMap = {}
    end
    
    def set_output_taskname(bb)
      return if not bb.instance_of?ModuleBuildingBlock
      outputTaskname = task "Print #{bb.get_task_name}" do
        num = Rake.application.idei.get_number_of_projects
        @numCurrent ||= 0
        @numCurrent += 1
        
        if not Bake.options.verboseLow
          Bake.formatter.printAdditionalInfo "**** Building #{@numCurrent} of #{num}: #{bb.name.gsub("Project ","")} (#{bb.config_name}) ****"
        end
        
        Rake.application.idei.set_build_info(bb.name.gsub("Project ",""), bb.config_name)
      end
      outputTaskname.type = Rake::Task::UTIL
      outputTaskname.transparent_timestamp = true
      insertAt = 0
      t = Rake.application[bb.last_content.get_task_name]
      t.prerequisites.each do |p|
        pname = String === p ? p : p.name 
        if pname.index("Project ") == 0
          insertAt = insertAt + 1
        else
          break
        end
      end
      t.prerequisites.insert(insertAt, outputTaskname)
    end


    def calc_needed_bbs(bbChildName, needed_bbs)
      bbChild = ALL_BUILDING_BLOCKS[bbChildName]
      isModule = (ModuleBuildingBlock === bbChild ? 1 : 0) 
      return 0 if needed_bbs.include?bbChild
      needed_bbs << bbChild
      bbChild.dependencies.each { |d| isModule += calc_needed_bbs(d, needed_bbs) }
      return isModule
    end

    # PRE and POST CONDITIONS
    def addSteps(steps, bbModule, projDir, globalFilterStr, tcs)
      if steps
        array = (Metamodel::Step === steps ? [steps] : steps.step)
        array.reverse.each do |m|

          checkDefault = true          
          if m.filter != "" # explicit filter = 1. prio
            next if Bake.options.exclude_filter.include?m.filter
            checkDefault = false if Bake.options.include_filter.include?m.filter
          end

          if globalFilterStr != nil
            if checkDefault == true # global filter = 2. prio
              next if Bake.options.exclude_filter.include?globalFilterStr
              checkDefault = false if Bake.options.include_filter.include?globalFilterStr
            end
          end
          
          if checkDefault # default = 3. prio
            next if m.default == "off"
          end
        
          if Bake::Metamodel::Makefile === m
            nameOfBB = m.name+"_"+m.target
            bb = Makefile.new(m.name, m.target)
            if m.pathTo != ""
              pathHash = {}
              m.pathTo.split(",").each do |p|
                nameOfP = p.strip
                dirOfP = nil
                if not @project2config.include?nameOfP
                  Bake.options.roots.each do |r|
                    absIncDir = r+"/"+nameOfP
                    if File.exists?(absIncDir)
                      dirOfP = absIncDir
                      break
                    end
                  end
                else
                  dirOfP = @project2config[nameOfP].parent.get_project_dir
                end
                if dirOfP == nil
                  Bake.formatter.printError "Error: Project '#{nameOfP}' not found for makefile #{projDir}/#{m.name}"
                  ExitHelper.exit(1)
                end
                pathHash[nameOfP] = File.rel_from_to_project(File.dirname(projDir),File.dirname(dirOfP))
              end
              bb.set_path_to(pathHash)
              bb.pre_step = true if globalFilterStr
            end 
            bb.set_flags(adjustFlags(tcs[:MAKE][:FLAGS],m.flags)) if m.flags
            
            @lib_elements[m.line_number] = [HasLibraries::LIB_WITH_PATH, m.lib] if m.lib != ""
          elsif Bake::Metamodel::CommandLine === m
            nameOfBB = m.name
            bb = CommandLine.new(nameOfBB)
            bb.set_defined_in_file(m.file_name.to_s)
            bb.set_defined_in_line(m.line_number)
            bb.pre_step  = true if globalFilterStr
          else
            next
          end
          bbModule.last_content.dependencies << bb.name
          bbModule.contents << bb
          bbModule.last_content = bb
        end
      end
    end

    def convPath(dir, config, exe = nil)
      projName = config.parent.name
      projDir = config.parent.get_project_dir
    
      d = dir.respond_to?("name") ? dir.name : dir
      return d if Bake.options.no_autodir
      
      inc = d.split("/")
      if (inc[0] == projName)
        res = inc[1..-1].join("/") # within self
        res = "." if res == "" 
      elsif @project2config.include?(inc[0])
        dirOther = @project2config[inc[0]].parent.get_project_dir
        res = File.rel_from_to_project(projDir, dirOther)
        postfix = inc[1..-1].join("/")
        res = res + postfix if postfix != ""
      else
        if (inc[0] != "..")
          return d if File.exists?(projDir + "/" + d) # e.g. "include"
        
          # check if dir exists without Project.meta entry
          Bake.options.roots.each do |r|
            absIncDir = r+"/"+d
            if File.exists?(absIncDir)
              res = File.rel_from_to_project(projDir,absIncDir)
              if not res.nil?
                return res
              end 
            end
          end
        else
          Bake.formatter.printInfo "Info: #{projName} uses \"..\" in path name #{d}" if Bake.options.verboseHigh
        end
        
        res = d # relative from self as last resort
      end
      res
    end

    
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
    
    
    def loadProjMeta(loader, filename, configname)
      @project_files << filename
      f = loader.load(filename)

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

      if not config
        Bake.formatter.printError "Error: Config '#{configname}' not found in '#{filename}'"
        ExitHelper.exit(1)
      end
      
      config
    end

    def load_meta 
    
      loader = Loader.new
      @project_files = []
      
      @project2config = {}

      project2config_pending = {}
      project2config_pending[@mainProjectName] = Bake.options.build_config
      
      if not File.exist?(Bake.options.main_dir+"/Project.meta")
        Bake.formatter.printError "Error: #{Bake.options.main_dir}/Project.meta not found"
        ExitHelper.exit(1)
      end
        
      potentialProjs = []
      Bake.options.roots.each do |r|
        if (r.length == 3 && r.include?(":/"))
          r = r + @mainProjectName # glob would not work otherwise on windows (ruby bug?)
        end
        r = r+"/**{,/*/**}/Project.meta"  
        potentialProjs.concat(Dir.glob(r))
      end
      
      potentialProjs = potentialProjs.uniq.sort unless potentialProjs.empty?
      
      while project2config_pending.length > 0
      
        pname_toload = project2config_pending.keys[0]
        cname_toload = project2config_pending[pname_toload]
        project2config_pending.delete(pname_toload)
        
        # check if file is in more than one root
        pmeta_filenames = []

        potentialProjs.each do |pp|
          if pp.include?("/" + pname_toload + "/Project.meta") or pp == pname_toload + "/Project.meta" 
            pmeta_filenames << pp
          end
        end

        if pmeta_filenames.empty?
          Bake.formatter.printError "Error: #{pname_toload}/Project.meta not found"
          ExitHelper.exit(1)
        end
        
        if pmeta_filenames.length > 1
          Bake.formatter.printWarning "Warning: #{pname_toload} exists more than once:"
          chosen = " (chosen)"
          pmeta_filenames.each do |f|
            Bake.formatter.printWarning "  #{f}#{chosen}"
            chosen = ""
          end
        end
        

        config = loadProjMeta(loader, pmeta_filenames[0], cname_toload)
        
        @project2config[pname_toload] = config
      
        project2configLocal = {}
        
        if @project2config.length == 1
          if config.defaultToolchain == nil
            Bake.formatter.printError "Error: Main project configuration must contain DefaultToolchain"
            ExitHelper.exit(1)
          else
            basedOn = config.defaultToolchain.basedOn
            basedOn = "GCC_Lint" if Bake.options.lint
            basedOnToolchain = Bake::Toolchain::Provider[basedOn]
            if basedOnToolchain == nil
              Bake.formatter.printError "Error: DefaultToolchain based on unknown compiler '#{basedOn}'"
              ExitHelper.exit(1)
            end
            @defaultToolchain = Utils.deep_copy(basedOnToolchain)
            integrateToolchain(@defaultToolchain, config.defaultToolchain)
            
            if @defaultToolchainCached
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
        end
        
        if config.respond_to?("toolchain") and config.toolchain
          config.toolchain.compiler.each do |c|
            if not c.internalDefines.nil? and c.internalDefines != ""
              Bake.formatter.printError "Error: #{c.file_name}(#{c.internalDefines.line_number}): InternalDefines only allowed in DefaultToolchain'"
              ExitHelper.exit(1)
            end
          end
        end
        
        config.dependency.each do |d|
          pname = d.name
          cname = d.config
        
          # check that a project is not dependent twice
          if project2configLocal.include?pname
            Bake.formatter.printError "Error: More than one dependencies found to '#{pname}' in config '#{config.name}'"
            ExitHelper.exit(1)
          end
          project2configLocal[pname] = cname
      
          # check pending loads
          inconsistentConfigs = nil
          if @project2config.include?pname
            inconsistentConfigs = @project2config[pname].name if @project2config[pname].name != cname
          else
            if project2config_pending.include?pname
              if project2config_pending[pname] != cname
                inconsistentConfigs = project2config_pending[pname]
              end
            else
              project2config_pending[pname] = cname
            end
          end
          if inconsistentConfigs
            Bake.formatter.printError "Error: dependency to config '#{cname}' of project '#{pname}' found (line #{d.line_number}), but config #{inconsistentConfigs} was requested earlier"
            ExitHelper.exit(1)
          end
        end
      end

    end

    def writeCMake
      Bake.formatter.printError "Error: --cmake not supported by this version."
    end

    def getTc(config)
      tcs = nil
      if not Metamodel::CustomConfig === config
        tcs = Utils.deep_copy(@defaultToolchain)
        integrateToolchain(tcs, config.toolchain)
      else
        tcs = Utils.deep_copy(Bake::Toolchain::Provider.default)
      end    
      @configTcMap[config] = tcs
    end
    
    def substVars
      @mainConfig = @project2config[@mainProjectName]

      basedOn = @mainConfig.defaultToolchain.basedOn
      basedOn = "GCC_Lint" if Bake.options.lint

      basedOnToolchain = Bake::Toolchain::Provider[basedOn]
      @defaultToolchain = Utils.deep_copy(basedOnToolchain)
      integrateToolchain(@defaultToolchain, @mainConfig.defaultToolchain)      

      Subst.itute(@mainConfig, @mainProjectName, true, getTc(@mainConfig))
      @project2config.each do |projName, config|
        Subst.itute(config, projName, false, getTc(config)) if projName != @mainProjectName  
      end
    end
    
    def convert2bb
      @project2config.each do |projName, config|

        projDir = config.parent.get_project_dir
        @lib_elements = {}

        bbModule = ModuleBuildingBlock.new("Project "+projName)
        bbModule.contents = []
        
        tcs = @configTcMap[config]       
          
        addSteps(config.postSteps, bbModule, projDir, "POST", tcs) if not Bake.options.linkOnly

        if Metamodel::CustomConfig === config
          if config.step
            if config.step.filter != ""
              Bake.formatter.printError "Error: #{config.file_name}(#{config.step.line_number}): attribute filter not allowed here"
              ExitHelper.exit(1)
            end
            if config.step.default != "on"
              Bake.formatter.printError "Error: #{config.file_name}(#{config.step.line_number}): attribute default not allowed here"
              ExitHelper.exit(1)
            end
            addSteps(config.step, bbModule, projDir, nil, tcs)
          end 
          bbModule.main_content = BinaryLibrary.new(projName, false)
        elsif Bake.options.lint
          bbModule.main_content = Lint.new(projName)
          bbModule.main_content.set_lint_min(Bake.options.lint_min).set_lint_max(Bake.options.lint_max)
        elsif Metamodel::LibraryConfig === config
          bbModule.main_content = SourceLibrary.new(projName)
        elsif Metamodel::ExecutableConfig === config
          bbModule.main_content = Executable.new(projName)
          if not config.artifactName.nil?
            x = Bake.options.build_config + "/" + config.artifactName.name
            bbModule.main_content.set_executable_name(x)
          end 
          bbModule.main_content.set_linker_script(convPath(config.linkerScript, config)) unless config.linkerScript.nil?
        end
        bbModule.last_content.dependencies << bbModule.main_content.name
        bbModule.last_content = bbModule.main_content
        bbModule.contents << bbModule.main_content
        
        # PRE CONDITIONS
        addSteps(config.preSteps, bbModule, projDir, "PRE", tcs) if not Bake.options.linkOnly       
        
        ([bbModule] + bbModule.contents).each do |c|
          c.set_tcs(tcs)
          if (@defaultToolchainTime <= File.mtime(config.file_name))
            c.set_config_files([config.file_name])
          else
            xxx = file "ssss"
            $defaultToolchainTime = @defaultToolchainTime
            def xxx.timestamp
              $defaultToolchainTime
            end
            def xxx.needed?
              true
            end
            @defaultToolchainTime
          
            c.set_config_files([config.file_name, "ssss"])
          end
          c.set_project_dir(projDir)
          
          if tcs[:OUTPUT_DIR] != nil
            p = convPath(tcs[:OUTPUT_DIR], config)
            c.set_output_dir(p)
          elsif projName == @mainProjectName
            c.set_output_dir(Bake.options.build_config)
          else
            c.set_output_dir(Bake.options.build_config + "_" + @mainProjectName)
          end
          c.set_config_name(config.name)
        end
                  
        if HasLibraries === bbModule.main_content
          config.userLibrary.each do |l|
            ln = l.lib
            ls = nil
            if l.lib.include?("/")
              pos = l.lib.rindex("/")
              ls = convPath(l.lib[0..pos-1], config)
              ln = l.lib[pos+1..-1]
            end
            @lib_elements[l.line_number] = ls.nil? ? [] : [HasLibraries::SEARCH_PATH, ls] 
            @lib_elements[l.line_number].concat [HasLibraries::USERLIB, ln]
          end
          
          config.exLib.each do |exLib|
            ln = exLib.name
            ls = nil
            if exLib.name.include?("/")
              pos = exLib.name.rindex("/")
              ls = convPath(exLib.name[0..pos-1], config)
              ln = exLib.name[pos+1..-1]
            end
            if exLib.search
              @lib_elements[exLib.line_number] = ls.nil? ? [] : [HasLibraries::SEARCH_PATH, ls] 
              @lib_elements[exLib.line_number].concat [HasLibraries::LIB, ln]
            else
              @lib_elements[exLib.line_number] = [HasLibraries::LIB_WITH_PATH, (ls.nil? ? ln : (ls + "/" + ln))]
            end
          end
          
          config.exLibSearchPath.each do |exLibSP|
            @lib_elements[exLibSP.line_number] = [HasLibraries::SEARCH_PATH, convPath(exLibSP, config)] 
          end
        end

        if HasSources === bbModule.main_content
          srcs = config.files.map do |f|
            f.name
          end
          ex_srcs = config.excludeFiles.map {|f| f.name}        
        
          bbModule.main_content.set_local_includes(
            config.includeDir.map do |dir|
              (dir.name == "___ROOTS___") ? (Bake.options.roots.map { |r| File.rel_from_to_project(projDir,r,false) }) : convPath(dir, config)
            end.flatten
          )
          
          bbModule.main_content.set_source_patterns(srcs)
          bbModule.main_content.set_exclude_sources(ex_srcs)
          
          tcsMapConverted = {}
          srcs = config.files.each do |f|
            if (f.define.length > 0 or f.flags.length > 0)
              if f.name.include?"*"
                Bake.formatter.printWarning "Warning: #{config.file_name}(#{f.line_number}): toolchain settings not allowed for file pattern #{f.name}"
                err_res = ErrorDesc.new
                err_res.file_name = config.file_name
                err_res.line_number = f.line_number
                err_res.severity = ErrorParser::SEVERITY_WARNING
                err_res.message = "Toolchain settings not allowed for file patterns"
                Rake.application.idei.set_errors([err_res])                
              else
                tcsMapConverted[f.name] = integrateCompilerFile(Utils.deep_copy(tcs),f)
              end
            end
          end
          bbModule.main_content.set_tcs4source(tcsMapConverted)
          
        end

        # special exe stuff
        if Metamodel::ExecutableConfig === config and not Bake.options.lint
          if not config.mapFile.nil?
            if config.mapFile.name == ""
              exeName = bbModule.main_content.get_executable_name
              mapfileName = exeName.chomp(File.extname(exeName)) + ".map"
            else
              mapfileName = config.mapFile.name 
            end
             
            bbModule.main_content.set_mapfile(mapfileName)
          end
        end
        
        bbModule.contents.each do |c|
          if Bake::CommandLine === c
            cmdLine = convPath(c.get_command_line, config, bbModule.main_content)
            c.set_command_line(cmdLine)
          end
        end 

        # DEPS
        projDeps = config.dependency.map { |dd| "Project "+dd.name }
        projDeps.concat(bbModule.main_content.dependencies)
        bbModule.main_content.set_dependencies(projDeps)
        config.dependency.each { |dd| @lib_elements[dd.line_number] = [HasLibraries::DEPENDENCY, dd.name] } 
        

        @lib_elements.sort.each do |x|
          v = x[1]
          elem = 0
          while elem < v.length do 
            bbModule.main_content.add_lib_elements([v[elem..elem+1]])
            elem = elem + 2
          end
        end

      end
      
      ALL_BUILDING_BLOCKS.each do |bbname,bb|
        bb.complete_init
      end
      
    end

    def doit()
      CLEAN.clear
      CLOBBER.clear
      parsingOk = false
      ex = nil
      begin
        parsingOk = doit_internal
      rescue Exception => e
        ex = e
      end
      if not parsingOk and Rake.application.idei
        Rake.application.idei.set_build_info(@mainProjectName, Bake.options.build_config.nil? ? "Not set" : Bake.options.build_config, 0)
        err_res = ErrorDesc.new
        err_res.file_name = Bake.options.main_dir
        err_res.line_number = 0
        err_res.severity = ErrorParser::SEVERITY_ERROR
        err_res.message = "Parsing configurations failed, see log output."
        Rake.application.idei.set_errors([err_res])
      end
      
      raise ex if ex
      parsingOk
    end

    def doit_internal()
      
      @mainProjectName = File::basename(Bake.options.main_dir)

      @startupFilename = Bake.options.filename

      @mainMeta = Bake.options.main_dir + "/Project.meta"

      cache = CacheAccess.new(@mainMeta, Bake.options.build_config, Bake.options)
      
      if File.exists? @mainMeta
        @defaultToolchainTime = File.mtime(@mainMeta)
        @mainMetaTime = @defaultToolchainTime 
      else
        @defaultToolchainTime = Time.now
      end
      
      forceLoadMeta = Bake.options.nocache
      
      @defaultToolchainCached = nil
      
      if not forceLoadMeta
        @project2config = cache.load_cache
        @defaultToolchainCached = cache.defaultToolchain
        @defaultToolchainTime = cache.defaultToolchainTime unless cache.defaultToolchainTime.nil? 
        if @project2config.nil?
          forceLoadMeta = true
        else
          @defaultToolchain = @defaultToolchainCached
        end
      end

      if forceLoadMeta
        load_meta
        cache.write_cache(@project_files, @project2config, @defaultToolchain, @defaultToolchainTime)
      end
      
      substVars
      
      if (Bake.options.cmake)
        writeCMake
        ExitHelper.exit(0)
      end
      
      convert2bb
      
      #################################################

      startBBName = "Project "+Bake.options.project
      startBB = ALL_BUILDING_BLOCKS[startBBName]
      if startBB.nil?
        Bake.formatter.printError "Error: Project #{Bake.options.project} is not a dependency of #{@mainProjectName}"
        ExitHelper.exit(1)
      end 


      #################################################
      
      if Bake.options.single or @startupFilename
        content_names = startBB.contents.map { |c| c.name }
        startBB.main_content.set_helper_dependencies(startBB.main_content.dependencies.dup) if Executable === startBB.main_content
        startBB.main_content.dependencies.delete_if { |d| not content_names.include?d}
      end

      if @startupFilename
        startBB.contents.each do |c|
          if SourceLibrary === c or Executable === c
            
            # check that the file is REALLY included and glob if file does not exist and guess what file can be meant 
            Dir.chdir(startBB.project_dir) do
              
              theFile = []
              if not File.exists?(@startupFilename)
                Dir.chdir(startBB.project_dir) do
                  theFile = Dir.glob("**/#{@startupFilename}")
                  theFile.map! {|tf| startBB.project_dir + "/" + tf}
                end
                if theFile.length == 0
                  Bake.formatter.printError "Error: #{@startupFilename} not found in project #{Bake.options.project}"
                  ExitHelper.exit(1)
                end
              else
                if File.is_absolute?(@startupFilename)
                  theFile << @startupFilename
                else
                  theFile << startBB.project_dir + "/" + @startupFilename
                end
                  
              end
              
              exclude_files = []
              c.exclude_sources.each do |e|
                Dir.glob(e).each {|f| exclude_files << f} 
              end
              theFile.delete_if { |f| exclude_files.any? {|e| e==f} }
              if theFile.length == 0
                Bake.formatter.printError "Error: #{@startupFilename} excluded in config #{Bake.options.build_config} of project #{Bake.options.project}"
                ExitHelper.exit(1)
              end
              
              source_files = c.sources.dup
              c.source_patterns.each do |p|
                Dir.glob(p).each {|f| source_files << (startBB.project_dir + "/" + f)} 
              end
              
              theFile.delete_if { |f| source_files.all? {|e| e!=f} }
              if theFile.length == 0
                Bake.formatter.printError "Error: #{@startupFilename} is no source file in config #{Bake.options.build_config} of project #{Bake.options.project}"
                ExitHelper.exit(1)
              elsif theFile.length > 1
                Bake.formatter.printError "Error: #{@startupFilename} is ambiguous in project #{Bake.options.project}"
                ExitHelper.exit(1)
              else
                @startupFilename = theFile[0]
              end
            end
         
            c.set_sources([@startupFilename])
            c.set_source_patterns([])
            c.set_exclude_sources([])
            c.extend(SingleSourceModule) unless Bake.options.lint
            break
          else
            def c.needed?
              false
            end
          end
        end
      end
      
      
      Rake.application.check_unnecessary_includes = (@startupFilename == nil) if Bake.options.check_uninc
      

      #################################################


      startBB.contents.each do |b|
        if SourceLibrary === b or Executable === b or BinaryLibrary === b
          @parseBB = b
        end
      end


      @bbs = []
      @num_modules = 1
      if Bake.options.single or @startupFilename
        @bbs << startBB
        @bbs.concat(startBB.contents)
      else
        @num_modules = calc_needed_bbs(startBBName, @bbs)
      end

      begin # show incs and stuff
        if Bake.options.show_includes
          @bbs.each do |bb|
            if HasIncludes === bb
              print bb.name
              li = bb.local_includes
              li.each { |i| print "##{i}" }
              print "\n"
            end
          end
          ExitHelper.exit(0)
        end
        
        if Bake.options.show_includes_and_defines
          intIncs = []
          intDefs = {:CPP => [], :C => [], :ASM => []}
          Dir.chdir(Bake.options.main_dir) do
          
            if (@mainConfig.defaultToolchain.internalIncludes)
              iname = convPath(@mainConfig.defaultToolchain.internalIncludes.name, @mainConfig)
              if iname != ""
                if not File.exists?(iname)
                  Bake.formatter.printError "Error: InternalIncludes file #{iname} does not exist"
                  ExitHelper.exit(1)
                end
                IO.foreach(iname) {|x| add_line_if_no_comment(intIncs,x) }
              end
            end
            
            @mainConfig.defaultToolchain.compiler.each do |c|
              if (c.internalDefines)
                dname = convPath(c.internalDefines.name, @mainConfig)
                if dname != ""
                  if not File.exists?(dname)
                    Bake.formatter.printError "Error: InternalDefines file #{dname} does not exist"
                    ExitHelper.exit(1)
                  end
                  IO.foreach(dname) {|x| add_line_if_no_comment(intDefs[c.ctype],x)  }
                end
              end
            end
            
          end
          
          
          @bbs.each do |bb|
            if HasIncludes === bb
              puts bb.name
              
              puts " includes"
              (bb.local_includes + intIncs).each { |i| puts "  #{i}" }
  
              [:CPP, :C, :ASM].each do |type|
                puts " #{type} defines"
                (bb.tcs[:COMPILER][type][:DEFINES] + intDefs[type]).each { |d| puts "  #{d}" }
              end
              puts " done"
            end
          end
          ExitHelper.exit(0)
        end
      rescue Exception => e
        if (not SystemExit === e)
          puts e
          puts e.backtrace
          ExitHelper.exit(1)
        else
          raise e
        end
      end      
      
      
      theExeBB = nil
      @bbs.each do |bb|
        res = bb.convert_to_rake()
        theExeBB = res if Executable === bb
      end
      
      if Bake.options.linkOnly
        if theExeBB.nil?
          Bake.formatter.printError "Error: no executable to link"
          ExitHelper.exit(1)
        else
          theExeBB.prerequisites.delete_if {|p| Rake::Task::SOURCEMULTI == Rake.application[p].type}
        end
      end

      @bbs.each do |bb|
        set_output_taskname(bb)
      end
      
      if @startupFilename
        runTaskName = @parseBB.get_task_name
      else       
        runTaskName = startBB.get_task_name
      end
      
      
      @runTask = Rake.application[runTaskName]

      if @startupFilename
        @runTask.prerequisites.clear
      end

      return true
    end

    def start()
    
      if Bake.options.clean
        cleanTask = nil
        if @startupFilename
          Dir.chdir(@parseBB.project_dir) do
          
            if File.is_absolute?(@startupFilename)
              @startupFilename = File.rel_from_to_project(@parseBB.project_dir, @startupFilename, false)
            end
          
            of = @parseBB.get_object_file(@startupFilename)
            object = File.expand_path(of)

            FileUtils.rm object, :force => true
            FileUtils.rm @parseBB.get_dep_file(object), :force => true
          end 
        else
          if Bake.options.clobber
            cleanTask = Rake.application[:clobber]
            cleanType = "Clobber"
          else
            cleanTask = Rake.application[:clean]
            cleanType = "Clean"
          end
          cleanTask.invoke
        end
        
        if Rake.application.idei and Rake.application.idei.get_abort
          Bake.formatter.printError "\#{cleanType} aborted."
          return false          
        elsif cleanTask != nil and cleanTask.failure
          Bake.formatter.printError "\n#{cleanType} failed."
          return false
        elsif not Bake.options.rebuild
          Bake.formatter.printSuccess "\n#{cleanType} done."
          return true          
        end
          
      end
      Rake::application.idei.set_build_info(@parseBB.name, @parseBB.config_name, @num_modules)
        
      @runTask.invoke
          
      buildType = Bake.options.rebuild ? "Rebuild" : "Build"
          
      if Rake.application.idei and Rake.application.idei.get_abort
        Bake.formatter.printError "\n#{buildType} aborted."
        return false          
      elsif @runTask.failure
        if Rake::application.preproFlags
          Bake.formatter.printSuccess "\nPreprocessing done."
          return true
        else
          Bake.formatter.printError "\n#{buildType} failed."
          return false
        end
      else
        text = ""
        # this "fun part" shall not fail in any case!        
        begin
          #if Time.now.year == 2012 and Time.now.month == 1
          #  text = "  --  The munich software team wishes you a happy new year 2012!"
          #end
        rescue Exception
        end
        Bake.formatter.printSuccess("\n#{buildType} done." + text)
        return true          
      end
    end

    def connect()
      if Bake.options.socket != 0
        Rake.application.idei.connect(Bake.options.socket)
      end
    end

    def disconnect()
      if Bake.options.socket != 0
        Rake.application.idei.disconnect()
      end
    end


  end
end


# metamodel Files vs File vs Dir vs Make vs ... ? merge?

