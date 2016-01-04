#!/usr/bin/env ruby


require 'bake/model/metamodel_ext'

require 'bake/util'
require 'bake/cache'
require 'bake/subst'
require 'bake/mergeConfig'

require 'common/exit_helper'
require 'common/ide_interface'
require 'common/ext/file'
require 'bake/toolchain/provider'
require 'common/ext/stdout'
require 'common/utils'
require 'bake/toolchain/colorizing_formatter'
require 'bake/config/loader'

require 'blocks/block'
require 'blocks/commandLine'
require 'blocks/makefile'
require 'blocks/compile'
require 'blocks/convert'
require 'blocks/library'
require 'blocks/executable'
require 'blocks/lint'
require 'blocks/convert'
require 'blocks/docu'

require 'set'
require 'socket'

require 'blocks/showIncludes'
require 'common/abortException'

require 'adapt/config/loader'

module Bake

  class SystemCommandFailed < Exception
  end
  
  class ToCxx
    
    @@linkBlock = 0

    def self.linkBlock
      @@linkBlock = 1
    end
    
    def initialize
      @configTcMap = {}
    end

    def createBaseTcsForConfig
      @loadedConfig.referencedConfigs.each do |projName, configs|
        configs.each do |config|
          tcs = Utils.deep_copy(@defaultToolchain)
          @configTcMap[config] = tcs
        end  
      end
    end

    def createTcsForConfig
      @loadedConfig.referencedConfigs.each do |projName, configs|
        configs.each do |config|
          integrateToolchain(@configTcMap[config], config.toolchain)
        end  
      end
    end
        
    def substVars
      Subst.itute(@mainConfig, Bake.options.main_project_name, true, @configTcMap[@mainConfig], @loadedConfig, @configTcMap)
      @loadedConfig.referencedConfigs.each do |projName, configs|
        configs.each do |config|
          if config != @mainConfig 
            Subst.itute(config, projName, false, @configTcMap[config], @loadedConfig, @configTcMap)
          end 
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

    def addDependencies(block, config)
      config.dependency.each do |dep|
        @loadedConfig.referencedConfigs[dep.name].each do |configRef|
          if configRef.name == dep.config
            block.dependencies << configRef.qname if not Bake.options.project# and not Bake.options.filename
            blockRef = Blocks::ALL_BLOCKS[configRef.qname]
            block.childs << blockRef
            blockRef.parents << block
            break
          end  
        end
      end
    end    

    def makeBlocks
      @loadedConfig.referencedConfigs.each do |projName, configs|
        configs.each do |config|
          block = Blocks::Block.new(config, @loadedConfig.referencedConfigs)
          Blocks::ALL_BLOCKS[config.qname] = block
        end
      end
    end
    
    def makeGraph
        @loadedConfig.referencedConfigs.each do |projName, configs|
          configs.each do |config|
            block = Blocks::ALL_BLOCKS[config.qname]
              addDependencies(block, config)
          end
        end
        Blocks::ALL_BLOCKS.each do |name,block|
          block.dependencies.uniq!
          block.childs.uniq!
          block.parents.uniq!
        end
    end
    
    def convert2bb
      @loadedConfig.referencedConfigs.each do |projName, configs|
        configs.each do |config|
          block = Blocks::ALL_BLOCKS[config.qname]
          
          addSteps(block, block.startupSteps,  config.startupSteps)
          addSteps(block, block.exitSteps,  config.exitSteps)
          
          if not Bake.options.linkOnly and not Bake.options.prepro and not Bake.options.lint and not Bake.options.conversion_info and not Bake.options.docu and not Bake.options.filename and not Bake.options.analyze
            addSteps(block, block.preSteps,  config.preSteps)
            addSteps(block, block.postSteps, config.postSteps)
          end
          
          if Bake.options.docu
            block.mainSteps << Blocks::Docu.new(config, @configTcMap[config])
          elsif Metamodel::CustomConfig === config
            if not Bake.options.linkOnly and not Bake.options.prepro and not Bake.options.lint and not Bake.options.conversion_info and not Bake.options.docu and not Bake.options.filename and not Bake.options.analyze
              addSteps(block, block.mainSteps, config) if config.step
            end 
          elsif Bake.options.conversion_info
            block.mainSteps << Blocks::Convert.new(block, config, @loadedConfig.referencedConfigs, @configTcMap[config])
          elsif Bake.options.lint
            block.mainSteps << Blocks::Lint.new(block, config, @loadedConfig.referencedConfigs, @configTcMap[config])
          else
            compile = Blocks::Compile.new(block, config, @loadedConfig.referencedConfigs, @configTcMap[config])
            (Blocks::ALL_COMPILE_BLOCKS[projName] ||= []) << compile
            block.mainSteps << compile
            if not Bake.options.filename and not Bake.options.analyze
              if Metamodel::LibraryConfig === config
                block.mainSteps << Blocks::Library.new(block, config, @loadedConfig.referencedConfigs, @configTcMap[config], compile)
              else
                block.mainSteps << Blocks::Executable.new(block, config, @loadedConfig.referencedConfigs, @configTcMap[config], compile)
              end
            end
          end


                    
        end
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
    
    def callBlocks(startBlocks, method, ignoreStopOnFirstError = false)
      Blocks::ALL_BLOCKS.each {|name,block| block.visited = false; block.result = true;  block.inDeps = false }
      Blocks::Block.reset_block_counter
      result = true
      startBlocks.each do |block|
        result = callBlock(block, method) && result
        if not ignoreStopOnFirstError
          return false if not result and Bake.options.stopOnFirstError
        end
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
      end

      if startConfigName
        blockName = startProjectName+","+startConfigName
        if not Blocks::ALL_BLOCKS.include?(startProjectName+","+startConfigName)
          Bake.formatter.printError("Error: project #{startProjectName} with config #{startConfigName} not found")
          ExitHelper.exit(1)
        end
        startBlocks = [Blocks::ALL_BLOCKS[startProjectName+","+startConfigName]]
        Blocks::Block.set_num_projects(1)
      elsif startProjectName
        startBlocks = []
        Blocks::ALL_BLOCKS.each do |blockName, block|
          if blockName.start_with?(startProjectName + ",")
            startBlocks << block
          end
        end
        if startBlocks.length == 0
          Bake.formatter.printError("Error: project #{startProjectName} not found")
          ExitHelper.exit(1)
        end
        startBlocks.reverse! # most probably the order of dependencies if any
        Blocks::Block.set_num_projects(startBlocks.length)
      else
        startBlocks = [Blocks::ALL_BLOCKS[Bake.options.main_project_name+","+Bake.options.build_config]]
        Blocks::Block.set_num_projects(Blocks::ALL_BLOCKS.length)
      end
     return startBlocks       
    end
    
    def doit()

      taskType = "Building"
      if Bake.options.lint
        taskType = "Linting"
      elsif Bake.options.conversion_info
        taskType = "Showing conversion infos"
      elsif Bake.options.docu
        taskType = "Generating documentation"
      elsif Bake.options.prepro
        taskType = "Preprocessing"
      elsif Bake.options.linkOnly
          taskType = "Linking"
      elsif Bake.options.rebuild
        taskType = "Rebuilding"
      elsif Bake.options.clean
        taskType = "Cleaning"
      end      
      
      begin      
        al = AdaptConfig.new
        adaptConfigs = al.load()
        
        @loadedConfig = Config.new
        @loadedConfig.load(adaptConfigs)
        
        taskType = "Analyzing" if Bake.options.analyze
                  
        @mainConfig = @loadedConfig.referencedConfigs[Bake.options.main_project_name].select { |c| c.name == Bake.options.build_config }.first
  
        if Bake.options.lint
          @defaultToolchain = Utils.deep_copy(Bake::Toolchain::Provider["Lint"])
        else
          basedOn =  @mainConfig.defaultToolchain.basedOn
          basedOnToolchain = Bake::Toolchain::Provider[basedOn]
          if basedOnToolchain.nil?
            Bake.formatter.printError("DefaultToolchain based on unknown compiler '#{basedOn}'", config.defaultToolchain)
            ExitHelper.exit(1)
          end

          # The flag "-FS" must only be set for VS2013 and above          
          ENV["MSVC_FORCE_SYNC_PDB_WRITES"] = ""
          if basedOn == "MSVC"
            begin
              res = `cl.exe 2>&1`
              raise Exception.new unless $?.success?
              scan_res = res.scan(/ersion (\d+).(\d+).(\d+)/)
              if scan_res.length > 0
                ENV["MSVC_FORCE_SYNC_PDB_WRITES"] = "-FS" if scan_res[0][0].to_i >= 18 # 18 is the compiler major version in VS2013
              else
                Bake.formatter.printError("Could not read MSVC version")
                ExitHelper.exit(1)
              end
            rescue SystemExit
              raise
            rescue Exception => e
              Bake.formatter.printError("Could not detect MSVC compiler")
              ExitHelper.exit(1)
            end
          end
          
          @defaultToolchain = Utils.deep_copy(basedOnToolchain)
          Bake.options.envToolchain = true if (basedOn.include?"_ENV")
        end
        integrateToolchain(@defaultToolchain, @mainConfig.defaultToolchain)
          
        # todo: cleanup this hack
        Bake.options.analyze = @defaultToolchain[:COMPILER][:CPP][:COMPILE_FLAGS].include?"analyze"
        Bake.options.eclipseOrder = @mainConfig.defaultToolchain.eclipseOrder
        
        createBaseTcsForConfig
        substVars
        createTcsForConfig
        
        @@linkBlock = 0
        
        makeBlocks
        makeGraph
        convert2bb
        
        Blocks::Show.includes if Bake.options.show_includes
        Blocks::Show.includesAndDefines(@mainConfig, @configTcMap[@mainConfig]) if Bake.options.show_includes_and_defines
        
        startBlocks = calcStartBlocks

        Bake::IDEInterface.instance.set_build_info(@mainConfig.parent.name, @mainConfig.name, Blocks::ALL_BLOCKS.length)
        
        ideAbort = false
        begin
          result = callBlocks(startBlocks, :startup, true)
          if Bake.options.clean or Bake.options.rebuild
            if not Bake.options.stopOnFirstError or result
              result = callBlocks(startBlocks, :clean) && result
            end
          end
          if Bake.options.rebuild or not Bake.options.clean
            if not Bake.options.stopOnFirstError or result
              result = callBlocks(startBlocks, :execute) && result
            end
          end      
        rescue AbortException
          ideAbort = true
        end
        result = callBlocks(startBlocks, :exits, true) && result
        
        if ideAbort
          Bake.formatter.printError("\n#{taskType} aborted.")
          ExitHelper.set_exit_code(1)
          return
        end
        
        if Bake.options.cc2j_filename
          Blocks::BlockBase.prepareOutput(Bake.options.cc2j_filename)
          File.open(Bake.options.cc2j_filename, 'w') do |f|  
            f.puts "["
            noComma = Blocks::CC2J.length - 1
            Blocks::CC2J.each_with_index do |c, index|
              cmd = c[:command].is_a?(Array) ? c[:command].join(' ') : c[:command]
              f.puts "  { \"directory\": \"" + c[:directory] +  "\","
              f.puts "    \"command\": \"" + cmd +  "\","
              f.puts "    \"file\": \"" + c[:file] +  "\" }#{index == noComma ? "" : ","}"
            end
            f.puts "]"
          end
        end
              
        if result == false
          Bake.formatter.printError("\n#{taskType} failed.")
          ExitHelper.set_exit_code(1)
          return
        else
          if Bake.options.linkOnly and @@linkBlock == 0
            Bake.formatter.printSuccess("\nNothing to link.")
          else
            Bake.formatter.printSuccess("\n#{taskType} done.")
          end
        end
      rescue SystemExit
        Bake.formatter.printError("\n#{taskType} failed.") if ExitHelper.exit_code != 0
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

trap("SIGINT") do
  Bake::IDEInterface.instance.set_abort(1)
end