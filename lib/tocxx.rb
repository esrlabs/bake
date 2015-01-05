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
require 'blocks/library'
require 'blocks/executable'
require 'blocks/lint'
require 'blocks/docu'

require 'set'
require 'socket'

require 'blocks/showIncludes'
require 'common/abortException'

module Bake

  class SystemCommandFailed < Exception
  end
  
  class ToCxx

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
      Subst.itute(@mainConfig, Bake.options.main_project_name, true, @configTcMap[@mainConfig])
      @loadedConfig.referencedConfigs.each do |projName, configs|
        configs.each do |config|
          if config != @mainConfig 
            Subst.itute(config, projName, false, @configTcMap[config])
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
    
    def convert2bb
      @loadedConfig.referencedConfigs.each do |projName, configs|
        configs.each do |config|
          
          block = Blocks::Block.new(config, @loadedConfig.referencedConfigs)
          
          Blocks::ALL_BLOCKS[config.qname] = block
          
          if not Bake.options.linkOnly and not Bake.options.prepro and not Bake.options.lint and not Bake.options.docu and not Bake.options.filename
            addSteps(block, block.preSteps,  config.preSteps)
            addSteps(block, block.postSteps, config.postSteps)
          end
          
          if Bake.options.docu
            block.mainSteps << Blocks::Docu.new(config, @configTcMap[config])
          elsif Metamodel::CustomConfig === config
            if not Bake.options.linkOnly and not Bake.options.prepro and not Bake.options.lint and not Bake.options.docu and not Bake.options.filename
              addSteps(block, block.mainSteps, config) if config.step
            end 
          elsif Bake.options.lint
            block.mainSteps << Blocks::Lint.new(block, config, @loadedConfig.referencedConfigs, @configTcMap[config])
          else
            compile = Blocks::Compile.new(block, config, @loadedConfig.referencedConfigs, @configTcMap[config])
            (Blocks::ALL_COMPILE_BLOCKS[projName] ||= []) << compile
            block.mainSteps << compile
            if not Bake.options.filename
              if Metamodel::LibraryConfig === config
                block.mainSteps << Blocks::Library.new(block, config, @loadedConfig.referencedConfigs, @configTcMap[config], compile)
              else
                block.mainSteps << Blocks::Executable.new(block, config, @loadedConfig.referencedConfigs, @configTcMap[config], compile)
              end
            end
          end

          if not Bake.options.project# and not Bake.options.filename
            addDependencies(block, config.dependency)
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
      Blocks::ALL_BLOCKS.each {|name,block| block.visited = false; block.result = false;  block.inDeps = false }
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

      taskType = "Building"
      if Bake.options.lint
        taskType = "Linting"
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
        @loadedConfig = Config.new
        @loadedConfig.load
        
        @mainConfig = @loadedConfig.referencedConfigs[Bake.options.main_project_name].select { |c| c.name == Bake.options.build_config }.first
  
        if Bake.options.lint
          @defaultToolchain = Utils.deep_copy(Bake::Toolchain::Provider["Lint"])
          integrateToolchain(@defaultToolchain, @mainConfig.defaultToolchain)
        else
          @defaultToolchain = @loadedConfig.defaultToolchain
        end
          
        createBaseTcsForConfig
        substVars
        createTcsForConfig
        
        convert2bb
        
        Blocks::Show.includes if Bake.options.show_includes
        Blocks::Show.includesAndDefines(@mainConfig, @configTcMap[@mainConfig]) if Bake.options.show_includes_and_defines
        
        startBlocks = calcStartBlocks

        Bake::IDEInterface.instance.set_build_info(@mainConfig.parent.name, @mainConfig.name, Blocks::ALL_BLOCKS.length)
        
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
          ExitHelper.set_exit_code(1)
          return
        end
              
        if result == false
          Bake.formatter.printError "\n#{taskType} failed."
          ExitHelper.set_exit_code(1)
          return
        else
          Bake.formatter.printSuccess("\n#{taskType} done.")
        end
      rescue SystemExit
        Bake.formatter.printError "\n#{taskType} failed."
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
