module Cxxproject

  class Subst
  
    def self.itute(config, projName, options, isMainProj, toolchain)
    
      @@configName = config.name
      @@projDir = config.parent.get_project_dir
      @@projName = projName
      @@options = options
      @@mainProjectName = File::basename(options.main_dir)
      @@resolvedVars = 0
      @@configFilename = config.file_name
      
      @@artifactName = ""
      if Metamodel::ExecutableConfig === config
        if not config.artifactName.nil?
          @@artifactName = config.artifactName.name
        elsif config.defaultToolchain != nil
          basedOnToolchain = Cxxproject::Toolchain::Provider[config.defaultToolchain.basedOn]
          if basedOnToolchain != nil
            @@artifactName = projName+basedOnToolchain[:LINKER][:OUTPUT_ENDING]
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
          Printer.printError "Error: #{config.file_name}(#{s.line_number}): value and cmd attributes must be used exclusively"
          ExitHelper.exit(1)
        end
        
        if (s.value != "")
          @@userVarMap[s.name] = substString(s.value)
        else
          cmd_result = false
          begin
            rd, wr = IO.pipe
            cmd = [substString(s.cmd)]
            cmd << {
             :err=>wr,
             :out=>wr
            }
            consoleOutput = ""
            Dir.chdir(@@projDir) do
              cmd_result, consoleOutput = ProcessHelper.safeExecute() { sp = spawn(*cmd); ProcessHelper.readOutput(sp, rd, wr) }
            end
          @@userVarMap[s.name] = consoleOutput.chomp
          rescue
          end
          if (cmd_result == false)
            Printer.printWarning "Warning: #{config.file_name}(#{s.line_number}): command not successful, variable #{s.name} wil be set to \"\"  (#{consoleOutput.chomp})."
            @@userVarMap[s.name] = ""
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
        Printer.printError "Error: #{config.file_name}: cyclic variable substitution detected"
        ExitHelper.exit(1)
      end
      
    end
    
    def self.substString(str)
      substStr = ""
      posSubst = 0
      while (true)
        posStart = str.index("$(", posSubst)
        break if posStart.nil?
        posEnd = str.index(")", posStart)
        break if posEnd.nil?
        substStr << str[posSubst..posStart-1] if posStart>0
      
        @@resolvedVars += 1
        var = str[posStart+2..posEnd-1]

        if @@options.vars.has_key?(var)
          substStr << @@options.vars[var]  
        elsif @@userVarMap.has_key?(var)
          substStr << @@userVarMap[var]       
        elsif var == "MainConfigName"
          substStr << @@options.build_config
        elsif var == "MainProjectName"
          substStr << @@mainProjectName
        elsif var == "MainProjectDir"
          substStr << @@options.main_dir
        elsif var == "ConfigName"
         substStr << @@configName
        elsif var == "ProjectName"
          substStr << @@projName
        elsif var == "ProjectDir"
          substStr << @@projDir
        elsif var == "OutputDir"
          if @@projName == @@mainProjectName 
            substStr << @@options.build_config
          else
            substStr << (@@options.build_config + "_" + @@mainProjectName)
          end
        elsif var == "Time"
          substStr << Time.now.to_s
        elsif var == "Hostname"
          substStr << Socket.gethostname
        elsif var == "ArtifactName"
          substStr << @@artifactName
        elsif var == "ArtifactNameBase"
          substStr << @@artifactName.chomp(File.extname(@@artifactName))
        elsif var == "Roots"
          substStr << "___ROOTS___"
        elsif var == "/"
          if Cxxproject::OS.windows?
            substStr << "\\"
          else
            substStr << "/"
          end
        elsif ENV[var]
          substStr << ENV[var]
        else
          if @@options.verbose
            Printer.printInfo "Info: #{@@configFilename}: substitute variable '$(#{var})' with empty string"
          end
          substStr << ""
        end
      
        posSubst = posEnd + 1
      end
      substStr << str[posSubst..-1]
      substStr
    end

    def self.substToolchain(elem)
      elem.each do |k, e|
        if Hash === e or Array === e
          substToolchain(e) 
        elsif String === e
          elem[k] = substString(e)
        end  
      end
    end

    
    def self.subst(elem)
      elem.class.ecore.eAllAttributes_derived.each do |a|
        next if a.name == "file_name" or a.name == "line_number"
        #next if Metamodel::DefaultToolchain === elem
        next if a.eType.name != "EString" 
        substStr = substString(elem.getGeneric(a.name))
        elem.setGeneric(a.name, substStr)
      end
    
      childsRefs = elem.class.ecore.eAllReferences.select{|r| r.containment}
      childsRefs.each do |c|
        elem.getGenericAsArray(c.name).each { |child| subst(child) }
      end     
    end
  
  end
  
end

