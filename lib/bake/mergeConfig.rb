module Bake

  class MergeConfig
  
    def initialize(child, parent)
      @child = child
      @parent = parent
    end
    
    def mergeToolchain(pt,ct, isDefault)
      pt.compiler.each do |pc|
        found = false
        ct.compiler.each do |cc|
          if cc.ctype == pc.ctype
            found = true
            cc.setFlags(pc.flags + cc.flags)
            cc.setDefine(pc.define + cc.define)
            if cc.internalDefines.nil? and not pc.internalDefines.nil?
              cc.setInternalDefines(pc.internalDefines)
            end 
            if cc.command == "" and pc.command != ""
              cc.setCommand(pc.command)
            end
          end
        end
        ct.addCompiler(pc) if not found
      end

      if not pt.archiver.nil?
        if (ct.archiver.nil?)
          ct.setArchiver(pt.archiver)
        else
          if ct.archiver.command == "" and pt.archiver.command != ""
            ct.archiver.setCommand(pt.archiver.command)
          end
          ct.archiver.setFlags(pt.archiver.flags + ct.archiver.flags)
        end
      end 
 
      if not pt.linker.nil?
        if (ct.linker.nil?)
          ct.setLinker(pt.linker)
        else
          if ct.linker.command == "" and pt.linker.command != ""
            ct.linker.setCommand(pt.linker.command)
          end
          ct.linker.setFlags(pt.linker.flags + ct.linker.flags)
          ct.linker.setLibprefixflags(pt.linker.libprefixflags + ct.linker.libprefixflags)
          ct.linker.setLibpostfixflags(pt.linker.libpostfixflags + ct.linker.libpostfixflags)
        end
      end 
      
      if ct.outputDir == "" and pt.outputDir != ""
        ct.setOutputDir(pt.outputDir)
      end

      if ct.docu.nil? and not pt.docu.nil?
        ct.setDocu(pt.docu)
      end
      
      ct.setLintPolicy(pt.lintPolicy + ct.lintPolicy)
      
      if (isDefault)
        if ct.basedOn == "" and pt.basedOn != ""
          ct.setBasedOn(pt.basedOn)
        end
        if ct.internalIncludes.nil? and not pt.internalIncludes.nil?
          ct.setInternalIncludes(pt.internalIncludes)
        end 
      end
      
    end
    
    def manipulateLineNumbers(ar)
      ar.each { |l| l.line_number -= 1000000 if l.line_number > 0 }
    end
    
    def merge()
    
      # Valid for all config types

      deps = @parent.dependency
      @child.dependency.each do |cd|
        deps << cd if deps.none? {|pd| pd.name == cd.name and pd.config == cd.config }
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
          mergeToolchain(pt,ct,true)
        end
      end
      
      pt = @parent.toolchain
      ct = @child.toolchain
      
      if not pt.nil?
        if (ct.nil?)
          @child.setToolchain(pt)
        else
          mergeToolchain(pt,ct,false)
        end
      end
      
      # Valid for custom config
      
      if (Metamodel::CustomConfig === @child && Metamodel::CustomConfig === @parent)
        @child.setStep(@parent.step) if @child.step.nil? and not @parent.step.nil?
      end
      
      # Valid for library and exe config
      
      if ((Metamodel::LibraryConfig === @child || Metamodel::ExecutableConfig === @child) && (Metamodel::LibraryConfig === @parent || Metamodel::ExecutableConfig === @parent))
        @child.setFiles(@parent.files + @child.files)
        @child.setExcludeFiles(@parent.excludeFiles + @child.excludeFiles)
        @child.setIncludeDir(@parent.includeDir + @child.includeDir)
      end
      
      # Valid for exe config
      
      if (Metamodel::ExecutableConfig === @child && Metamodel::ExecutableConfig === @parent)
        @child.setLinkerScript(@parent.linkerScript) if @child.linkerScript.nil? and not @parent.linkerScript.nil?
        @child.setArtifactName(@parent.artifactName) if @child.artifactName.nil? and not @parent.artifactName.nil?
        @child.setMapFile(@parent.mapFile) if @child.mapFile.nil?  and not @parent.mapFile.nil?
      end
    
    end
  
  end

end