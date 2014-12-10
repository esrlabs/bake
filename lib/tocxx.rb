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

require 'blocks/showIncludes'

module Bake

  class SystemCommandFailed < Exception
  end
  
  class ToCxx

    def initialize
      @configTcMap = {}
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
          
          Blocks::ALL_BLOCKS[config.qname] = block
          
          if not Bake.options.linkOnly and not Bake.options.prepro
            addSteps(block, block.preSteps,  config.preSteps)
            addSteps(block, block.postSteps, config.postSteps)
          end
          
          if Metamodel::CustomConfig === config
            if not Bake.options.linkOnly and not Bake.options.prepro
              addSteps(block, block.mainSteps, config) if config.step
            end 
          else
            compile = Blocks::Compile.new(block, config, @loadedConfig.referencedConfigs, @configTcMap[config])
            (Blocks::ALL_COMPILE_BLOCKS[projName] ||= []) << compile
            block.mainSteps << compile
            if Metamodel::LibraryConfig === config
              block.mainSteps << Blocks::Library.new(block, config, @loadedConfig.referencedConfigs, @configTcMap[config], compile)
            else
              block.mainSteps << Blocks::Executable.new(block, config, @loadedConfig.referencedConfigs, @configTcMap[config], compile)
            end
          end

          if not Bake.options.project and not Bake.options.filename
            addDependencies(block, config.dependency)
          end
                    
        end
      end

      end

    def convert2bb
      @loadedConfig.referencedConfigs.each do |projName, configs|
        configs.each do |config|
          if Bake.options.lint
            bbModule.main_content = Lint.new(projName, config.name)
            bbModule.main_content.set_lint_min(Bake.options.lint_min).set_lint_max(Bake.options.lint_max)
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
    
    def callBlocks(startBlocks, method)
      Blocks::ALL_BLOCKS.each {|name,block| block.visited = false }
      Blocks::Block.reset_block_counter
      result = true
      startBlocks.each do |block|
        result = callBlock(block, method) && result
        return false if not result and Bake.options.stopOnFirstError
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
    
    def doit()
      
      @loadedConfig = Config.new
      @loadedConfig.load # Dependency must be substed
      
      @mainConfig = @loadedConfig.referencedConfigs[Bake.options.main_project_name].select { |c| c.name == Bake.options.build_config }.first
      
      createConfigTcs
      substVars
      
      convert2bb2
      
      Blocks::Show.includes if Bake.options.show_includes
      Blocks::Show.includesAndDefines(@mainConfig) if Bake.options.show_includes_and_defines
      
      startBlocks = calcStartBlocks
      
      taskType = "Building"
      if Bake.options.prepro
        taskType = "Preprocessing"
      elsif Bake.options.linkOnly
          taskType = "Linking"
      elsif Bake.options.rebuild
        taskType = "Rebuilding"
      elsif Bake.options.clean
        taskType = "Cleaning"
      end
        
      begin
        result = true
        if Bake.options.clean or Bake.options.rebuild
          result = callBlocks(startBlocks, :clean)
        end
        if Bake.options.rebuild or not Bake.options.clean
          result = callBlocks(startBlocks, :execute) && result
        end      
      rescue AbortException
        Bake.formatter.printError "\n#{taskType} aborted."
        return false          
      end
            
      if result == false
        Bake.formatter.printError "\n#{taskType} failed."
        return false
      else
        Bake.formatter.printSuccess("\n#{taskType} done.")
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
