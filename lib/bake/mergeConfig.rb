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
            cc.setFlags(clone(pc.flags) + cc.flags)
            cc.setDefine(clone(pc.define) + cc.define)
            if cc.internalDefines.nil? and not pc.internalDefines.nil?
              cc.setInternalDefines(clone(pc.internalDefines))
            end 
            if cc.command == "" and pc.command != ""
              cc.setCommand(clone(pc.command))
            end
          end
        end
        ct.addCompiler(pc) if not found
      end

      if not pt.archiver.nil?
        if (ct.archiver.nil?)
          ct.setArchiver(clone(pt.archiver))
        else
          if ct.archiver.command == "" and pt.archiver.command != ""
            ct.archiver.setCommand(clone(pt.archiver.command))
          end
          ct.archiver.setFlags(clone(pt.archiver.flags) + ct.archiver.flags)
        end
      end 
 
      if not pt.linker.nil?
        if (ct.linker.nil?)
          ct.setLinker(clone(pt.linker))
        else
          if ct.linker.command == "" and pt.linker.command != ""
            ct.linker.setCommand(clone(pt.linker.command))
          end
          ct.linker.setFlags(clone(pt.linker.flags) + ct.linker.flags)
          ct.linker.setLibprefixflags(clone(pt.linker.libprefixflags) + ct.linker.libprefixflags)
          ct.linker.setLibpostfixflags(clone(pt.linker.libpostfixflags) + ct.linker.libpostfixflags)
        end
      end 
      
      if ct.outputDir == "" and pt.outputDir != ""
        ct.setOutputDir(clone(pt.outputDir))
      end

      if ct.docu.nil? and not pt.docu.nil?
        ct.setDocu(clone(pt.docu))
      end
      
      ct.setLintPolicy(clone(pt.lintPolicy) + ct.lintPolicy)
      
      if (isDefault)
        if ct.basedOn == "" and pt.basedOn != ""
          ct.setBasedOn(clone(pt.basedOn))
        end
        if pt.eclipseOrder # is that a good idea?
          ct.setEclipseOrder(clone(pt.eclipseOrder))
        end
        if ct.internalIncludes.nil? and not pt.internalIncludes.nil?
          ct.setInternalIncludes(clone(pt.internalIncludes))
        end 
      end
      
    end
    
    def manipulateLineNumbers(ar)
      ar.each { |l| l.line_number -= 100000  }
    end
    
    def clone(obj)
      return obj.map {|o| o.dup} if Array === obj
      return obj.dup
    end
    
    def merge()
    
      # Valid for all config types

      deps = clone(@parent.dependency)
      @child.dependency.each do |cd|
        deps << cd if deps.none? {|pd| pd.name == cd.name and pd.config == cd.config }
      end
      @child.setDependency(deps)
      
      @child.setSet(clone(@parent.set) + @child.set)

      cExLib = clone(@parent.exLib)
      cExLibSearchPath = clone(@parent.exLibSearchPath)
      cUserLibrary = clone(@parent.userLibrary)
      manipulateLineNumbers(cExLib)
      manipulateLineNumbers(cExLibSearchPath)
      manipulateLineNumbers(cUserLibrary)

      @child.setExLib(cExLib + @child.exLib)
      @child.setExLibSearchPath(cExLibSearchPath + @child.exLibSearchPath)
      @child.setUserLibrary(cUserLibrary + @child.userLibrary)

      if not @parent.startupSteps.nil?
        if (@child.startupSteps.nil?)
          @child.setStartupSteps(clone(@parent.startupSteps))
        else
          @child.startupSteps.setStep(clone(@parent.startupSteps.step) + @child.startupSteps.step)
        end
      end
      
      if not @parent.preSteps.nil?
        if (@child.preSteps.nil?)
          @child.setPreSteps(clone(@parent.preSteps))
        else
          @child.preSteps.setStep(clone(@parent.preSteps.step) + @child.preSteps.step)
        end
      end
      
      if not @parent.postSteps.nil?
        if (@child.postSteps.nil?)
          @child.setPostSteps(clone(@parent.postSteps))
        else
          @child.postSteps.setStep(clone(@parent.postSteps.step) + @child.postSteps.step)
        end
      end

      if not @parent.exitSteps.nil?
        if (@child.exitSteps.nil?)
          @child.setExitSteps(clone(@parent.exitSteps))
        else
          @child.exitSteps.setStep(clone(@parent.exitSteps.step) + @child.exitSteps.step)
        end
      end
      
      pt = @parent.defaultToolchain
      ct = @child.defaultToolchain

      if not pt.nil?
        if (ct.nil?)
          @child.setDefaultToolchain(clone(pt))
        else
          mergeToolchain(pt,ct,true)
        end
      end
      
      pt = @parent.toolchain
      ct = @child.toolchain
      
      if not pt.nil?
        if (ct.nil?)
          @child.setToolchain(clone(pt))
        else
          mergeToolchain(pt,ct,false)
        end
      end

      # Valid for custom config
      
      if (Metamodel::CustomConfig === @child && Metamodel::CustomConfig === @parent)
        @child.setStep(clone(@parent.step)) if @child.step.nil? and not @parent.step.nil?
      end

      # Valid for library and exe config
      
      if ((Metamodel::LibraryConfig === @child || Metamodel::ExecutableConfig === @child) && (Metamodel::LibraryConfig === @parent || Metamodel::ExecutableConfig === @parent))
        @child.setFiles(clone(@parent.files) + @child.files)
        @child.setExcludeFiles(clone(@parent.excludeFiles) + @child.excludeFiles)
        @child.setIncludeDir(clone(@parent.includeDir) + @child.includeDir)
      end

      # Valid for exe config
      
      if (Metamodel::ExecutableConfig === @child && Metamodel::ExecutableConfig === @parent)
        @child.setLinkerScript(clone(@parent.linkerScript)) if @child.linkerScript.nil? and not @parent.linkerScript.nil?
        @child.setArtifactName(clone(@parent.artifactName)) if @child.artifactName.nil? and not @parent.artifactName.nil?
        @child.setMapFile(clone(@parent.mapFile)) if @child.mapFile.nil?  and not @parent.mapFile.nil?
      end
    
    end
  
  end

end