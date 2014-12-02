#!/usr/bin/env ruby

gem 'rake', '>= 0.7.3'

require 'rake'
require 'rake/clean'
require 'bake/model/metamodel_ext'
require 'bake/util'
require 'bake/cache'
require 'bake/subst'
require 'bake/mergeConfig'

require 'imported/buildingblocks/module'
require 'imported/buildingblocks/makefile'
require 'imported/buildingblocks/executable'
require 'imported/buildingblocks/lint'
require 'imported/buildingblocks/custom_config'
require 'imported/buildingblocks/command_line'
require 'imported/utils/exit_helper'
require 'imported/ide_interface'
require 'imported/ext/file'
require 'bake/toolchain/provider'
require 'imported/ext/stdout'
require 'imported/ext/rake'
require 'imported/utils/utils'
require 'bake/toolchain/colorizing_formatter'
require 'bake/config/loader'

require 'blocks/block'
require 'blocks/commandLine'
require 'blocks/makefile'

require 'set'
require 'socket'

#require 'ruby-prof'

module Bake

  class ToCxx

    
    def initialize
        
        
      @configTcMap = {}
    end
    
    def set_output_taskname(bb, ind)
      return if not bb.instance_of?ModuleBuildingBlock
      outputTaskname = task "Print #{bb.get_task_name}" do
        num = Rake.application.idei.get_number_of_projects
        @numCurrent ||= 0
        @numCurrent += 1
        
        if not Bake.options.verboseLow
          Bake.formatter.printAdditionalInfo "**** Building #{@numCurrent} of #{num}: #{bb.project_name} (#{bb.config_name}) ****"
        end
        
        Rake.application.idei.set_build_info(bb.project_name, bb.config_name)
      end
      outputTaskname.type = Rake::Task::UTIL
      outputTaskname.transparent_timestamp = true
      
      lastWithP = nil
      insertAt = 0
      
      # fuck ist das ne kacke!
      t = Rake.application[bb.last_content.get_task_name]
      if (Executable === bb.last_content or SourceLibrary == bb.last_content)  
        t = Rake.application[t.prerequisites[0]]
      end
      
      t.prerequisites.each do |p|
        pname = String === p ? p : p.name
        if pname.index("Project ") == 0
          insertAt = insertAt + 1
        else
          break
        end
      end

      Rake.application[t].prerequisites.insert(insertAt, outputTaskname)
    end


    def calc_needed_bbs(bbChildName, needed_bbs)
      bbChild = ALL_BUILDING_BLOCKS[bbChildName]
      isModule = (ModuleBuildingBlock === bbChild ? 1 : 0) 
      return 0 if needed_bbs.include?bbChild
      needed_bbs << bbChild
      bbChild.dependencies.each { |d| isModule += calc_needed_bbs(d, needed_bbs) }
      return isModule
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
      elsif @loadedConfig.referencedConfigs.include?(inc[0])
        dirOther = @loadedConfig.referencedConfigs[inc[0]].first.parent.get_project_dir
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

    


    def writeCMake
      Bake.formatter.printError "Error: --cmake not supported by this version."
    end

    def getTc(config)
      tcs = nil
      if not Metamodel::CustomConfig === config
        tcs = Utils.deep_copy(@loadedConfig.defaultToolchain)
        integrateToolchain(tcs, config.toolchain)
      else
        tcs = Utils.deep_copy(Bake::Toolchain::Provider.default)
      end    
      @configTcMap[config] = tcs
    end
    
    def substVars
      Subst.itute(@mainConfig, @mainProjectName, true, getTc(@mainConfig))
      @loadedConfig.referencedConfigs.each do |projName, configs|
        configs.each do |config|
          Subst.itute(config, projName, false, getTc(config)) if projName != @mainProjectName
        end  
      end
    end
    

    
    def addSteps(block, blockSteps, configSteps)
      Array(configSteps.step).each do |step|
        if Bake::Metamodel::Makefile === step
          blockSteps << Blocks::Makefile.new(step, @loadedConfig.referencedConfigs, block)
        elsif Bake::Metamodel::CommandLine === step
          blockSteps << Blocks::CommandLine.new(step)
        end
      end if configSteps
    end

    def addDependencies(block, configDeps)
      configDeps.each do |dep|
        @loadedConfig.referencedConfigs[dep.name].each do |config|
          if config.name == dep.config
            block.dependencies << config.qname
            break
          end  
        end
      end
    end    
    
    def convert2bb2
      @loadedConfig.referencedConfigs.each do |projName, configs|
        configs.each do |config|
          
          block = Blocks::Block.new(projName, config.name)
          
          @startBlock = block if Blocks::ALL_BLOCKS.empty?
          Blocks::ALL_BLOCKS[config.qname] = block
          
          if not Bake.options.linkOnly
            addSteps(block, block.preSteps,  config.preSteps)
            addSteps(block, block.postSteps, config.postSteps)
          end
          
          if Metamodel::CustomConfig === config
            addSteps(block, block.mainSteps, config) if config.step 
          end
          
          
          # todo: überprüfung auch bei convertBBs
          if not Bake.options.single and not Bake.options.filename
            addDependencies(block, config.dependency)
          end
                    
        end
      end      
    end

    def convert2bb
      @loadedConfig.referencedConfigs.each do |projName, configs|
        configs.each do |config|
  
          projDir = config.parent.get_project_dir
          @lib_elements = {}
  
          bbModule = ModuleBuildingBlock.new(projName, config.name)
          bbModule.contents = []
          
          tcs = @configTcMap[config]       
            
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
              #addSteps(projName, config.step, bbModule, projDir, nil, tcs, config)
            end 
            bbModule.main_content = CustomConfig.new(projName, config.name)
          elsif Bake.options.lint
            bbModule.main_content = Lint.new(projName, config.name)
            bbModule.main_content.set_lint_min(Bake.options.lint_min).set_lint_max(Bake.options.lint_max)
          elsif Metamodel::LibraryConfig === config
            bbModule.main_content = SourceLibrary.new(projName, config.name)
          elsif Metamodel::ExecutableConfig === config
            bbModule.main_content = Executable.new(projName, config.name)
            if not config.artifactName.nil?
              x = Bake.options.build_config + "/" + config.artifactName.name
              bbModule.main_content.set_executable_name(x)
            end 
            bbModule.main_content.set_linker_script(convPath(config.linkerScript, config)) unless config.linkerScript.nil?
          end
          bbModule.last_content.dependencies << bbModule.main_content.get_task_name
          bbModule.last_content = bbModule.main_content
          bbModule.contents << bbModule.main_content
          
          
          ([bbModule] + bbModule.contents).each do |c|
            c.set_tcs(tcs)
            if (@loadedConfig.defaultToolchainTime <= File.mtime(config.file_name))
              c.set_config_files([config.file_name])
            else
              xxx = file "ssss"
              
              $defaultToolchainTime = @loadedConfig.defaultToolchainTime
              def xxx.timestamp
                $defaultToolchainTime
              end
              def xxx.needed?
                true
              end
            
              c.set_config_files([config.file_name, "ssss"])
            end
            c.set_project_dir(projDir)
            
            if tcs[:OUTPUT_DIR] != nil
              p = convPath(tcs[:OUTPUT_DIR], config)
              c.set_output_dir(p)
            elsif projName == @mainProjectName and config == @mainConfig 
              c.set_output_dir(Bake.options.build_config)
            else
              c.set_output_dir(Bake.options.build_config + "_" + @mainProjectName)
            end
            
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
          projDeps = config.dependency.map { |dd| "Project "+dd.name+","+dd.config }
          projDeps.concat(bbModule.main_content.dependencies)
          bbModule.main_content.set_dependencies(projDeps) #ALEX
          config.dependency.each { |dd| @lib_elements[dd.line_number] = [HasLibraries::DEPENDENCY, "MAIN "+dd.name+","+dd.config] } 
          
  
          @lib_elements.sort.each do |x|
            v = x[1]
            elem = 0
            while elem < v.length do 
              bbModule.main_content.add_lib_elements([v[elem..elem+1]])
              elem = elem + 2
            end
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

    def sayGoodbye
      # text = ""
      # this "fun part" shall not fail in any case!        
      begin
        #if Time.now.year == 2012 and Time.now.month == 1
        #  text = "  --  The munich software team wishes you a happy new year 2012!"
      rescue Exception
      end
    end


    def doit_internal()
      
      @mainProjectName = File::basename(Bake.options.main_dir)

      @loadedConfig = Config.new
      @loadedConfig.load
      
      @mainConfig = @loadedConfig.referencedConfigs[@mainProjectName].select { |c| c.name == Bake.options.build_config }.first
      
      substVars
      
      if (Bake.options.cmake)
        writeCMake
        ExitHelper.exit(0)
      end
      
      #convert2bb
      convert2bb2
      
      result = BUILD_PASSED # TODO: wird das nur hier gebraucht?
      begin
        result = @startBlock.execute ? BUILD_PASSED : BUILD_ABORTED  
      rescue AbortException
        result = BUILD_ABORTED
      rescue Exception => ex
        if Bake.options.debug
          puts ex.message
          puts ex.backtrace
        end 
        result = BUILD_FAILED
      end
      
        
      buildType = Bake.options.rebuild ? "Rebuild" : "Build"
          
      if result == BUILD_ABORTED
        Bake.formatter.printError "\n#{buildType} aborted."
        return false          
      elsif result == BUILD_FAILED
        #if Rake::application.preproFlags
        #  Bake.formatter.printSuccess "\nPreprocessing done."
        #  return true
        #else
          Bake.formatter.printError "\n#{buildType} failed."
          return false
        #end
      else
        Bake.formatter.printSuccess("\n#{buildType} done.")
        sayGoodbye
        return true          
      end
      
      
      
      
      #################################################

      startBBName = "Project "+Bake.options.project # can be "a,b" or just "a"
      if ALL_BUILDING_BLOCKS.include?startBBName
        startBB = ALL_BUILDING_BLOCKS[startBBName] 
      else
        possibleBlocks = ALL_BUILDING_BLOCKS.select { |name,block| name.start_with?(startBBName + ",") }
        if possibleBlocks.length > 1
          Bake.formatter.printError "Error: Dependency to project #{Bake.options.project} is ambiguous for project #{@mainProjectName}"
          ExitHelper.exit(1)
        elsif possibleBlocks.empty?
          Bake.formatter.printError "Error: Project #{Bake.options.project} is not a dependency of #{@mainProjectName},#{@mainConfig.name}"
          ExitHelper.exit(1)
        end
        startBB = possibleBlocks.values[0]
        startBBName = startBB.get_task_name
      end

      #################################################
      
      if Bake.options.single or Bake.options.filename
        content_names = startBB.contents.map { |c| c.get_task_name }
        startBB.main_content.set_helper_dependencies(startBB.main_content.dependencies.dup) if Executable === startBB.main_content
        startBB.main_content.dependencies.delete_if { |d| not content_names.include?d}
      end

      if Bake.options.filename
        startBB.contents.each do |c|
          if SourceLibrary === c or Executable === c
            
            # check that the file is REALLY included and glob if file does not exist and guess what file can be meant 
            Dir.chdir(startBB.project_dir) do
              
              theFile = []
              if not File.exists?(Bake.options.filename)
                Dir.chdir(startBB.project_dir) do
                  theFile = Dir.glob("**/#{Bake.options.filename}")
                  theFile.map! {|tf| startBB.project_dir + "/" + tf}
                end
                if theFile.length == 0
                  Bake.formatter.printError "Error: #{Bake.options.filename} not found in project #{Bake.options.project}"
                  ExitHelper.exit(1)
                end
              else
                if File.is_absolute?(Bake.options.filename)
                  theFile << Bake.options.filename
                else
                  theFile << startBB.project_dir + "/" + Bake.options.filename
                end
                  
              end
              
              exclude_files = []
              c.exclude_sources.each do |e|
                Dir.glob(e).each {|f| exclude_files << f} 
              end
              theFile.delete_if { |f| exclude_files.any? {|e| e==f} }
              if theFile.length == 0
                Bake.formatter.printError "Error: #{Bake.options.filename} excluded in config #{Bake.options.build_config} of project #{Bake.options.project}"
                ExitHelper.exit(1)
              end
              
              source_files = c.sources.dup
              c.source_patterns.each do |p|
                Dir.glob(p).each {|f| source_files << (startBB.project_dir + "/" + f)} 
              end
              
              theFile.delete_if { |f| source_files.all? {|e| e!=f} }
              if theFile.length == 0
                Bake.formatter.printError "Error: #{Bake.options.filename} is no source file in config #{Bake.options.build_config} of project #{Bake.options.project}"
                ExitHelper.exit(1)
              elsif theFile.length > 1
                Bake.formatter.printError "Error: #{Bake.options.filename} is ambiguous in project #{Bake.options.project}"
                ExitHelper.exit(1)
              else
                c.set_sources([theFile[0]])
                c.set_source_patterns([])
                c.set_exclude_sources([])
              end
            end

            break
          else
            def c.needed?
              false
            end
          end
        end
      end
      
      
      #################################################


      startBB.contents.each do |b|
        if SourceLibrary === b or Executable === b or CustomConfig === b
          @parseBB = b
        end
      end

      @bbs = []
      @num_modules = 1
      if Bake.options.single or Bake.options.filename
        @bbs << startBB
        @bbs.concat(startBB.contents)
      else
        @num_modules = calc_needed_bbs(startBBName, @bbs)
      end

      begin # show incs and stuff
        if Bake.options.show_includes
          @bbs.each do |bb|
            if HasIncludes === bb
              print bb.project_name
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
              puts bb.project_name
              
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

      @bbs.each_with_index do |bb, index|
        set_output_taskname(bb, index)
      end
      
      if Bake.options.filename
        runTaskName = "Objects of " + @parseBB.get_task_name
      else       
        runTaskName = startBB.get_task_name
      end
      
      @runTask = Rake.application[runTaskName]

      if Bake.options.filename
        @runTask.prerequisites
        @runTask.prerequisites.clear
      end

      return true
    end

    def start()
    
      if Bake.options.clean
        cleanTask = nil
        if Bake.options.filename
          Dir.chdir(@parseBB.project_dir) do
            relSource = File.rel_from_to_project(@parseBB.project_dir, @parseBB.sources[0], false)
            of = @parseBB.get_object_file(relSource)
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
      Rake::application.idei.set_build_info(@parseBB.project_name, @parseBB.config_name, @num_modules)
        
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

