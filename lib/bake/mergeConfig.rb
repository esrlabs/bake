module Bake

  class MergeConfig
  
    def initialize(child, parent)
      @child = child
      @parent = parent
    end
    
    def mergeToolchain(pt,ct)
      pt.compiler.each do |pc|
        if ct.compiler.none?{|cc| cc.ctype == pc.ctype}
          ct.addCompiler(pc)
        end
      end
      if ct.archiver.nil? and not pt.archiver.nil?
        ct.setArchiver(pt.archiver)
      end
      if ct.linker.nil? and not pt.linker.nil?
        ct.setLinker(pt.linker)
      end
    end
    
    def manipulateLineNumbers(ar)
      ar.each { |l| l.line_number -= 1000000 if l.line_number > 0 }
    end
    
    def merge()
    
      # Valid for all config types

      deps = @parent.dependency
      @child.dependency.each do |cd|
        overwrite = false        
        deps.each do |pd|
          if pd.name == cd.name
            pd.config = cd.config
            overwrite = true
            break
          end
        end
        deps << cd if not overwrite 
      end
      @child.setDependency(deps)
      
      @child.setSet(@parent.set + @child.set)

      manipulateLineNumbers(@parent.exLib)
      manipulateLineNumbers(@parent.exLibSearchPath)
      manipulateLineNumbers(@parent.userLibrary)

      @child.setExLib(@parent.exLib           + @child.exLib)
      @child.setExLibSearchPath(@parent.exLibSearchPath + @child.exLibSearchPath)
      @child.setUserLibrary(@parent.userLibrary     + @child.userLibrary)
      
      if not @parent.preSteps.nil?
        if (@child.preSteps.nil?)
          @child.setPreSteps(@parent.preSteps)
        else
          @child.preSteps.setStep(@parent.preSteps.step + @child.preSteps.step)
        end
      end
      
      if not @parent.postSteps.nil?
        if (@child.postSteps.nil?)
          @child.setPostSteps(@parent.postSteps)
        else
          @child.postSteps.setStep(@parent.postSteps.step + @child.postSteps.step)
        end
      end
      
      pt = @parent.defaultToolchain
      ct = @child.defaultToolchain
      
      if not pt.nil?
        if (ct.nil?)
          @child.setDefaultToolchain(pt)
        else
          mergeToolchain(pt,ct)
        end
      end
      
      # Valid for custom config
      
      if (Metamodel::CustomConfig === @child && Metamodel::CustomConfig === @parent)
        @child.setStep(@parent.step) if @child.step.nil? and not @parent.step.nil?
      end
      
      # Valid for library and exe config
      
      if ((Metamodel::LibraryConfig === @child || Metamodel::ExecutableConfig === @child) && (Metamodel::LibraryConfig === @parent || Metamodel::ExecutableConfig === @parent))
        
        @child.setFiles(@parent.files        + @child.files)
        @child.setExcludeFiles(@parent.excludeFiles + @child.excludeFiles)
        @child.setIncludeDir(@parent.includeDir   + @child.includeDir)
        
        pt = @parent.toolchain
        ct = @child.toolchain
        
        if not pt.nil?
          if (ct.nil?)
            @child.setToolchain(pt)
          else
            mergeToolchain(pt,ct)
          end
        end
                
      end
      
      # Valid for exe config
      
      if (Metamodel::ExecutableConfig === @child && Metamodel::ExecutableConfig === @parent)
        @child.setLinkerScript(@parent.linkerScript) if @child.linkerScript.nil? and not @parent.linkerScript.nil?
        @child.setArtifactName(@parent.artifactName) if @child.artifactName.nil? and not @parent.artifactName.nil?
        @child.setMapFile(@parent.mapFile)      if @child.mapFile.nil?      and not @parent.mapFile.nil?
      end
    
    end
  
  end

end