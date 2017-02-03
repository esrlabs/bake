require 'pathname'

module Bake

  class Subst

    # this is done lazy because usually there is no need to calculate that
    def self.lazyPathes
      return unless @@lazy

      cppCmd = @@toolchain[:COMPILER][:CPP][:COMMAND]
      cCmd = @@toolchain[:COMPILER][:C][:COMMAND]
      asmCmd = @@toolchain[:COMPILER][:ASM][:COMMAND]
      archiverCmd = @@toolchain[:ARCHIVER][:COMMAND]
      linkerCmd = @@toolchain[:LINKER][:COMMAND]

      if @@config.toolchain
        linkerCmd = @@config.toolchain.linker.command if @@config.toolchain.linker and @@config.toolchain.linker.command != ""
        archiverCmd = @@config.toolchain.archiver.command if @@config.toolchain.linker and @@config.toolchain.archiver.command != ""
        @@config.toolchain.compiler.each do |c|
          if c.command != ""
            if c.ctype == :CPP
              cppCmd = c.command
            elsif c.ctype == :C
              cCmd = c.command
            elsif c.ctype == :ASM
              asmCmd = c.command
            end
          end
        end
      end

      @@cppExe      = File.which(cppCmd)
      @@cExe        = File.which(cCmd)
      @@asmExe      = File.which(asmCmd)
      @@archiverExe = File.which(archiverCmd)
      @@linkerExe   = File.which(linkerCmd)

      @@lazy = false
    end

    def self.itute(config, projName, isMainProj, toolchain, referencedConfigs, configTcMap)
      @@lazy = true
      @@config = config
      @@toolchain = toolchain
      @@referencedConfigs = referencedConfigs
      @@configTcMap = configTcMap
      @@toolchainName = config.defaultToolchain.basedOn if isMainProj

      @@configName = config.name
      @@projDir = config.parent.get_project_dir
      @@projName = projName
      @@resolvedVars = 0
      @@configFilename = config.file_name

      @@artifactName = ""
      if Metamodel::ExecutableConfig === config || Metamodel::LibraryConfig === config
        if not config.artifactName.nil?
          @@artifactName = config.artifactName.name
        else
          if Metamodel::ExecutableConfig === config
            @@artifactName = projName+Bake::Toolchain.outputEnding(toolchain)
          elsif Metamodel::LibraryConfig === config
            @@artifactName = "lib#{projName}.a"
          end
        end
      end

      if isMainProj
        @@userVarMap = {}
      else
        @@userVarMap = @@userVarMapMain.clone
      end

      config.set.each do |s|

        if (s.value != "" and s.cmd != "")
          Bake.formatter.printError("value and cmd attributes must be used exclusively", s)
          ExitHelper.exit(1)
        end

        if (s.value != "")
          setName = substString(s.name, s)
          if (setName.empty?)
            Bake.formatter.printWarning("Name of variable must not be empty - variable will be ignored", s)
          else
            @@userVarMap[s.name] = substString(s.value, s)
            if s.env
              ENV[s.name] = @@userVarMap[s.name]
              config.setEnvVar(s.name, @@userVarMap[s.name])
            end
          end
        else
          cmd_result = false
          consoleOutput = ""
          begin
            Dir.chdir(@@projDir) do
              cmd = [substString(s.cmd, s)]
              cmd_result, consoleOutput = ProcessHelper.run(cmd)
              @@userVarMap[s.name] = consoleOutput.chomp
              if s.env
                ENV[s.name] = @@userVarMap[s.name]
                config.setEnvVar(s.name, @@userVarMap[s.name])
              end
            end
          rescue Exception=>e
            consoleOutput = e.message
          end
          if (cmd_result == false)
            Bake.formatter.printWarning("Command not successful, variable #{s.name} will be set to \"\" (#{consoleOutput.chomp}).", s)
            @@userVarMap[s.name] = ""
            if s.env
              ENV[s.name] = ""
              config.setEnvVar(s.name, "")
            end
          end
        end

      end

      @@userVarMapMain = @@userVarMap.clone if isMainProj

      3.times {
        subst(config);
        substToolchain(toolchain)
      }

      @@resolvedVars = 0
      lastFoundInVar = -1
      100.times do
        subst(config)
        break if @@resolvedVars == 0 or (@@resolvedVars >= lastFoundInVar and lastFoundInVar >= 0)
        lastFoundInVar = @@resolvedVars
      end
      if (@@resolvedVars > 0)
        Bake.formatter.printError("Cyclic variable substitution detected", config.file_name)
        ExitHelper.exit(1)
      end

    end

    def self.substString(str, elem=nil)
      substStr = ""
      posSubst = 0
      while (true)
        posStart = str.index("$(", posSubst)
        break if posStart.nil?
        posEnd = str.index(")", posStart)
        break if posEnd.nil?
        posStartSub = str.index("$(", posStart+1)
        if (not posStartSub.nil? and posStartSub < posEnd) # = nested vars
          newStr = str[0,posStartSub] + substString(str[posStartSub..posEnd],elem)
          if (str.length + 1 > posEnd)
            str = newStr + str[posEnd+1..-1]
          else
            str = newStr
          end
          next
        end

        substStr << str[posSubst..posStart-1] if posStart>0

        @@resolvedVars += 1
        var = str[posStart+2..posEnd-1]

        splittedVar = var.split(",")

        if Bake.options.vars.has_key?(var)
          substStr << Bake.options.vars[var]
        elsif @@userVarMap.has_key?(var)
          substStr << @@userVarMap[var]
        elsif var == "MainConfigName"
          substStr << Bake.options.build_config
        elsif var == "MainProjectName"
          substStr << Bake.options.main_project_name
        elsif var == "MainProjectDir"
          substStr << Bake.options.main_dir
        elsif var == "ConfigName"
         substStr << @@configName
        elsif var == "ToolchainName" and defined?@@toolchainName
         substStr << @@toolchainName
        elsif var == "ProjectName"
          substStr << @@projName
        elsif var == "ProjectDir"
          substStr << @@projDir
        elsif var == "OutputDir" or (splittedVar.length == 3 and splittedVar[0] == "OutputDir")
          if (var == "OutputDir")
            out_proj_name = @@projName
            out_conf_name = @@configName
          else
            out_proj_name = splittedVar[1].strip
            out_conf_name = splittedVar[2].strip
          end
          if @@referencedConfigs.has_key?out_proj_name
            configs = @@referencedConfigs[out_proj_name]
            config = configs.select {|c| c.name == out_conf_name }.first
            if config
               out_dir = nil
              if (config.toolchain and config.toolchain.outputDir and config.toolchain.outputDir != "")
                out_dir = config.toolchain.outputDir
              else
                out_dir = @@configTcMap[config][:OUTPUT_DIR]
              end
              if not out_dir
                qacPart = Bake.options.qac ? (".qac" + Bake.options.buildDirDelimiter) : ""
                if out_proj_name == Bake.options.main_project_name and out_conf_name == Bake.options.build_config
                  out_dir = "build" + Bake.options.buildDirDelimiter + qacPart + Bake.options.build_config
                else
                  out_dir = "build" + Bake.options.buildDirDelimiter + qacPart + out_conf_name + "_" + Bake.options.main_project_name + "_" + Bake.options.build_config
                end
              end
              out_dir = substString(out_dir, elem)
              if File.is_absolute?(out_dir)
                substStr << out_dir
              else
                substStr << Pathname.new(File.rel_from_to_project(@@projDir,config.get_project_dir,true)  + out_dir).cleanpath.to_s
              end
            else
              if Bake.options.verbose > 0
                msg = "Substitute variable '$(#{var})' with empty string, because config #{out_conf_name} not found for project #{out_proj_name}"
                Bake.formatter.printInfo(msg, elem ? elem : @@config)
              end
            end
          else
            if Bake.options.verbose > 0
              msg = "Substitute variable '$(#{var})' with empty string, because project #{out_proj_name} not found"
              Bake.formatter.printInfo(msg, elem ? elem : @@config)
            end
          end
        elsif splittedVar.length > 1 and splittedVar[0] == "OutputDir"
          if Bake.options.verbose > 0
            msg = "Substitute variable '$(#{var})' with empty string, because syntax of complex variable OutputDir is not $(OutputDir,<project name>,<config name>)"
            Bake.formatter.printInfo(msg, elem ? elem : @@config)
          end
        elsif var == "Time"
          substStr << Time.now.to_s
        elsif var == "Hostname"
          substStr << Socket.gethostname
        elsif var == "ArtifactName"
          substStr << @@artifactName
        elsif var == "ArtifactNameBase"
          substStr << @@artifactName.chomp(File.extname(@@artifactName))
        elsif var == "CPPPath"
          self.lazyPathes
          substStr << @@cppExe
        elsif var == "CPath"
          self.lazyPathes
          substStr << @@cExe
        elsif var == "ASMPath"
          self.lazyPathes
          substStr << @@asmExe
        elsif var == "ArchiverPath"
          self.lazyPathes
          substStr << @@archiverExe
        elsif var == "LinkerPath"
          self.lazyPathes
          substStr << @@linkerExe
        elsif var == "Roots"
          substStr << "___ROOTS___"
        elsif var == "/"
          substStr << File::SEPARATOR
        elsif var == ":"
          substStr << File::PATH_SEPARATOR
        elsif ENV[var]
          substStr << ENV[var]
        else
          if Bake.options.verbose >= 2 && !(["CompilerPrefix", "ArchiverPrefix", "LinkerPrefix"].include?(var))
            msg = "Substitute variable '$(#{var})' with empty string"
            if elem
              Bake.formatter.printInfo(msg, elem)
            else
              Bake.formatter.printInfo(msg +  " in the toolchain", @@config)
            end
          end
        end

        posSubst = posEnd + 1
      end
      substStr << str[posSubst..-1]
      substStr
    end

    def self.substToolchain(elem)
      if Hash === elem
        elem.each do |k, e|
          if Hash === e or Array === e
            substToolchain(e)
          elsif String === e
            elem[k] = substString(e)
          end
        end
      elsif Array === elem
        elem.each_with_index do |e, i|
          if Hash === e or Array === e
            substToolchain(e)
          elsif String === e
            elem[i] = substString(e)
          end
        end
      end
    end

    def self.subst(elem)
      elem.class.ecore.eAllAttributes_derived.each do |a|
        next if a.name == "file_name" or a.name == "line_number"
        return if Metamodel::Set === elem.class
        return if Metamodel::DefaultToolchain === elem
        return if Metamodel::Toolchain === elem.class
        next if a.eType.name != "EString"
        substStr = substString(elem.getGeneric(a.name), elem)
        elem.setGeneric(a.name, substStr)
      end

      childsRefs = elem.class.ecore.eAllReferences.select{|r| r.containment}
      childsRefs.each do |c|
        elem.getGenericAsArray(c.name).each { |child| subst(child) }
      end
    end

  end

end

