#!/usr/bin/env ruby


require 'bake/model/metamodel_ext'
require 'bake/util'
require 'bake/cache'
require 'bake/subst'
require 'bake/mergeConfig'

require 'imported/buildingblocks/lint'
require 'imported/utils/exit_helper'
require 'imported/ide_interface'
require 'imported/ext/file'
require 'bake/toolchain/provider'
require 'imported/ext/stdout'
require 'imported/utils/utils'
require 'bake/toolchain/colorizing_formatter'
require 'bake/config/loader'

require 'blocks/block'
require 'blocks/commandLine'
require 'blocks/makefile'
require 'blocks/compile'
require 'blocks/library'
require 'blocks/executable'

require 'set'
require 'socket'

#require 'ruby-prof'

module Bake

  class SystemCommandFailed < Exception
  end
  
  class ToCxx

    
    def initialize
        
        
      @configTcMap = {}
    end
    


 

    


    def writeCMake
      Bake.formatter.printError "Error: --cmake not supported by this version."
    end

    def getTc(config)
    end
    
    def createConfigTcs
      @loadedConfig.referencedConfigs.each do |projName, configs|
        configs.each do |config|
          tcs = nil
          if not Metamodel::CustomConfig === config
            tcs = Utils.deep_copy(@loadedConfig.defaultToolchain)
            integrateToolchain(tcs, config.toolchain)
          else
            tcs = Utils.deep_copy(Bake::Toolchain::Provider.default)
          end    
          @configTcMap[config] = tcs
        end  
      end
    end
    
    def substVars
      Subst.itute(@mainConfig, Bake.options.main_project_name, true, @configTcMap[@mainConfig])
      @loadedConfig.referencedConfigs.each do |projName, configs|
        configs.each do |config|
          Subst.itute(config, projName, false, @configTcMap[config]) if projName != Bake.options.main_project_name
        end  
      end
    end
    

    
    def addSteps(block, blockSteps, configSteps)
      Array(configSteps.step).each do |step|
        if Bake::Metamodel::Makefile === step
          blockSteps << Blocks::Makefile.new(step, @loadedConfig.referencedConfigs, block)
        elsif Bake::Metamodel::CommandLine === step
          blockSteps << Blocks::CommandLine.new(step, @loadedConfig.referencedConfigs)
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
          
          block = Blocks::Block.new(config, @loadedConfig.referencedConfigs)
          
          #@startBlock = block if Blocks::ALL_BLOCKS.empty?
          Blocks::ALL_BLOCKS[config.qname] = block
          
          if not Bake.options.linkOnly
            addSteps(block, block.preSteps,  config.preSteps)
            addSteps(block, block.postSteps, config.postSteps)
          end
          
          if Metamodel::CustomConfig === config
            addSteps(block, block.mainSteps, config) if config.step 
          else
            compile = Blocks::Compile.new(block, config, @loadedConfig.referencedConfigs, @configTcMap[config])
            block.mainSteps << compile
            if Metamodel::LibraryConfig === config
              block.mainSteps << Blocks::Library.new(block, config, @loadedConfig.referencedConfigs, @configTcMap[config], compile)
            else
              block.mainSteps << Blocks::Executable.new(block, config, @loadedConfig.referencedConfigs, @configTcMap[config], compile)
            end
          end
          
          
          # todo: überprüfung auch bei convertBBs
          if not Bake.options.project and not Bake.options.filename
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
            
          if Bake.options.lint
            bbModule.main_content = Lint.new(projName, config.name)
            bbModule.main_content.set_lint_min(Bake.options.lint_min).set_lint_max(Bake.options.lint_max)
          end
          
  
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

      
    end

    def doit()
      parsingOk = false
      ex = nil
      begin
        parsingOk = doit_internal
      rescue Exception => e
        ex = e
      end
      if not parsingOk and Bake::IDEInterface.instance
        Bake::IDEInterface.instance.set_build_info(Bake.options.main_project_name, Bake.options.build_config.nil? ? "Not set" : Bake.options.build_config, 0)
        err_res = ErrorDesc.new
        err_res.file_name = Bake.options.main_dir
        err_res.line_number = 0
        err_res.severity = ErrorParser::SEVERITY_ERROR
        err_res.message = "Parsing configurations failed, see log output."
        Bake::IDEInterface.instance.set_errors([err_res])
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

    def callBlock(block, method)
      begin
        return block.send(method)
      rescue AbortException
        raise
      rescue Exception => ex
        if Bake.options.debug
          puts ex.message
          puts ex.backtrace
        end 
        return false
      end
    end
    
    def callBlocks(startBlocks, method)
      Blocks::ALL_BLOCKS.each {|name,block| block.visited = false }
      Blocks::Block.reset_block_counter
      result = true
      startBlocks.each do |block|
        result = callBlock(block, method) && result
      end
      return result
    end
    
    def calcStartBlocks
      startProjectName = nil
      startConfigName = nil
      if Bake.options.project
        splitted = Bake.options.project.split(',')
        startProjectName = splitted[0]
        startConfigName = splitted[1] if splitted.length == 2
      elsif Bake.options.filename
        startProjectName = Bake.options.main_project_name
        startConfigName = Bake.options.build_config  
      end

      if startConfigName
        blockName = startProjectName+","+startConfigName
        if not Blocks::ALL_BLOCKS.include?(startProjectName+","+startConfigName)
          Bake.formatter.printError "Error: project #{startProjectName} with config #{startConfigName} not found"
          ExitHelper.exit(1)
        end
        startBlocks = [Blocks::ALL_BLOCKS[startProjectName+","+startConfigName]]
        Blocks::Block.set_num_projects(1)
      elsif startProjectName
        startBlocks = []
        Blocks::ALL_BLOCKS.each do |blockName, block|
          if blockName.start_with? startProjectName
            startBlocks << block
          end
        end
        startBlocks.reverse! # most probably the order of dependencies if any
        Blocks::Block.set_num_projects(startBlocks.length)
      else
        startBlocks = [Blocks::ALL_BLOCKS[Bake.options.main_project_name+","+Bake.options.build_config]]
        Blocks::Block.set_num_projects(Blocks::ALL_BLOCKS.length)
      end
     return startBlocks       
    end
    
    def doit_internal()
      
      @loadedConfig = Config.new
      @loadedConfig.load # Dependency must be substed
      
      @mainConfig = @loadedConfig.referencedConfigs[Bake.options.main_project_name].select { |c| c.name == Bake.options.build_config }.first
      
      createConfigTcs
      substVars
      
      if (Bake.options.cmake)
        writeCMake
        ExitHelper.exit(0)
      end
      
      convert2bb2
      
      startBlocks = calcStartBlocks
      
      begin
        result = true
        if Bake.options.clean or Bake.options.rebuild
          result = callBlocks(startBlocks, :clean)
        end
        if not Bake.options.clean
          result = callBlocks(startBlocks, :execute) && result
        end      
      rescue AbortException
        Bake.formatter.printError "\nAborted."
        return false          
      end
            
      if result == false
        #if Rake::application.preproFlags
        #  Bake.formatter.printSuccess "\nPreprocessing done."
        #  return true
        #else
          Bake.formatter.printError "\nFailed."
          return false
        #end
      else
        Bake.formatter.printSuccess("\nDone.")
        sayGoodbye
        return true          
      end
      

      
      #################################################


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
        
        if Bake::IDEInterface.instance and Bake::IDEInterface.instance.get_abort
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
      Bake::IDEInterface.instance.set_build_info(@parseBB.project_name, @parseBB.config_name, @num_modules)
        
      @runTask.invoke
          
      buildType = Bake.options.rebuild ? "Rebuild" : "Build"
          
      if Bake::IDEInterface.instance and Bake::IDEInterface.instance.get_abort
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
        Bake::IDEInterface.instance.connect(Bake.options.socket)
      end
    end

    def disconnect()
      if Bake.options.socket != 0
        Bake::IDEInterface.instance.disconnect()
      end
    end


  end
end


# metamodel Files vs File vs Dir vs Make vs ... ? merge?

