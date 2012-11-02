module Cxxproject

  class Subst
  
    def self.itute(config, projName, options)
    
      @@configName = config.name
      @@projName = projName
      @@options = options
      @@mainProjectName = File::basename(options.main_dir)
      
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
      
      subst(config)    
    end
    
    def self.subst(elem)
      elem.class.ecore.eAllAttributes_derived.each do |a|
        next if a.name == "file_name" or a.name == "line_number"
        next if a.eType.name != "EString" 
        str = elem.getGeneric(a.name)
      
        posSubst = 0
        substStr = ""
        while (true)
          posStart = str.index("$(", posSubst)
          break if posStart.nil?
          posEnd = str.index(")", posStart)
          break if posEnd.nil?
          substStr << str[posSubst..posStart-1] if posStart>0
        
          var = str[posStart+2..posEnd-1]
        
          if var == "MainConfigName"
            substStr << @@options.build_config
          elsif var == "MainProjectName"
            substStr << @@mainProjectName 
          elsif var == "ConfigName"
           substStr << @@configName
          elsif var == "ProjectName"
            substStr << @@projName
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
          elsif ENV[var]
            substStr << ENV[var]
          elsif var == "PATH_TO_CYGWIN" # allowed to be not set
            substStr << ""
          else
            Printer.printError "Error: #{elem.file_name}(#{elem.line_number}): unknown substitution variable '$(#{var})'"
            ExitHelper.exit(1)
          end
        
          posSubst = posEnd + 1
        end
        substStr << str[posSubst..-1]
      
        elem.setGeneric(a.name, substStr)
      end    
    
      childsRefs = elem.class.ecore.eAllReferences.select{|r| r.containment}
      childsRefs.each do |c|
        elem.getGenericAsArray(c.name).each { |child| subst(child) }
      end     
    end
  
  end
  
end