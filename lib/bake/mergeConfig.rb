module Bake

  class MergeConfig
  
    def initialize(child, parent)
      @child = child
      @parent = parent
    end
    
    def mergeToolchain(st,tt, isDefault)
      st.compiler.each do |sc|
        found = false
        tt.compiler.each do |tc|
          if tc.ctype == sc.ctype
            found = true
            sf = clone(sc.flags); tf = tc.flags
            tc.setFlags(@merge ? (sf+tf) : (tf+sf))
            sd = clone(sc.define); td = tc.define
            tc.setDefine(@merge ? (sd+td) : (td+sd))
            if not sc.internalDefines.nil? and (not @merge or tc.internalDefines.nil?) 
              tc.setInternalDefines(clone(sc.internalDefines))
            end 
            if sc.command != "" and (not @merge or tc.command == "") 
              tc.setCommand(clone(sc.command))
            end
          end
        end
        tt.addCompiler(sc) if not found
      end

      if not st.archiver.nil?
        if (not @merge or tt.archiver.nil?)
          tt.setArchiver(clone(st.archiver))
        else
          if st.archiver.command != "" and (not @merge or tt.archiver.command == "")
            tt.archiver.setCommand(clone(st.archiver.command))
          end
          stFlags = clone(st.archiver.flags); ttFlags = tt.archiver.flags
          tt.archiver.setFlags(@merge ? (stFlags+ttFlags) : (ttFlags+stFlags))
        end
      end 
 
      if not st.linker.nil?
        if (not @merge or tt.linker.nil?)
          tt.setLinker(clone(st.linker))
        else
          if st.linker.command != "" and (not @merge or tt.linker.command == "") 
            tt.linker.setCommand(clone(st.linker.command))
          end
          stFlags     = clone(st.linker.flags);           ttFlags     = tt.linker.flags
          stPreFlags  = clone(st.linker.libprefixflags);  ttPreFlags  = tt.linker.libprefixflags
          stPostFlags = clone(st.linker.libpostfixflags); ttPostFlags = tt.linker.libpostfixflags
          tt.linker.setFlags(          @merge ? (stFlags+ttFlags)         : (ttFlags+stFlags)        )
          tt.linker.setLibprefixflags( @merge ? (stPreFlags+ttPreFlags)   : (ttPreFlags+stPreFlags)  )
          tt.linker.setLibpostfixflags(@merge ? (stPostFlags+ttPostFlags) : (ttPostFlags+stPostFlags))
        end
      end 
      
      if st.outputDir != "" and (not @merge or tt.outputDir == "")
        tt.setOutputDir(clone(st.outputDir))
      end

      if not st.docu.nil? and (not @merge or tt.docu.nil?) 
        tt.setDocu(clone(st.docu))
      end
      
      sLint = clone(st.lintPolicy); tLint = tt.lintPolicy
      tt.setLintPolicy(@merge ? (sLint + tLint) : (tLint + sLint))
      
      if (isDefault)
        if st.basedOn != "" and (not @merge or tt.basedOn == "") 
          tt.setBasedOn(clone(st.basedOn))
        end
        if st.eclipseOrder # eclipse order always wins
          tt.setEclipseOrder(clone(st.eclipseOrder))
        end
        if not st.internalIncludes.nil? and (not @merge or tt.internalIncludes.nil?) 
          tt.setInternalIncludes(clone(st.internalIncludes))
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
    
    def cloneParent(obj)
      @merge ? clone(obj) : obj
    end
    def cloneChild(obj)
      @merge ? obj : clone(obj)
    end
    
    def replace()
      # Valid for all configs
      toReplace = [:dependency, :set, :exLib, :exLibSearchPath, :userLibrary, :startupSteps, :preSteps, :postSteps, :exitSteps, :toolchain, :defaultToolchain]

      # Valid for custom config
      if (Metamodel::CustomConfig === @child && Metamodel::CustomConfig === @parent)
        toReplace << :step
      end

      # Valid for library and exe config
      if ((Metamodel::LibraryConfig === @child || Metamodel::ExecutableConfig === @child) && (Metamodel::LibraryConfig === @parent || Metamodel::ExecutableConfig === @parent))
        toReplace << :files << :excludeFiles << :includeDir
      end

      # Valid for exe config
      if (Metamodel::ExecutableConfig === @child && Metamodel::ExecutableConfig === @parent)
        toReplace << :linkerScript << :artifactName << :mapFile
      end
      
      toReplace.each do |name|
        childData = @child.method(name).call()
        if (Array === childData and not childData.empty?) or (Metamodel::ModelElement === childData and not childData.nil?)
          @parent.method(name.to_s + "=").call(clone(childData))
        end
      end
    end
    
    def remove()
      # Valid for all configs
      @parent.toolchain = nil if not @child.toolchain.nil?
      @parent.defaultToolchain = nil if not @child.defaultToolchain.nil?
      [:toolchain, :defaultToolchain].each do |name|
        @parent.method(name.to_s+"=").call(nil) if not @child.method(name).call().nil?
      end
      
      [:startupSteps, :preSteps, :postSteps, :exitSteps].each do |name|
        pSteps = @parent.method(name).call()
        cSteps = @child.method(name).call()
        next if pSteps.nil? or cSteps.nil?
        ps = pSteps.step  
        ps.delete_if { |ps| cSteps.step.any? { |cs| cs.name == ps.name } }
        pSteps.step=ps
      end
        
      toRemove = [:dependency, :set, :exLib, :exLibSearchPath, :userLibrary]
        
      # Valid for custom config
      if (Metamodel::CustomConfig === @child && Metamodel::CustomConfig === @parent)
        toRemove << :step
      end

      # Valid for library and exe config
      if ((Metamodel::LibraryConfig === @child || Metamodel::ExecutableConfig === @child) && (Metamodel::LibraryConfig === @parent || Metamodel::ExecutableConfig === @parent))
        toRemove << :files << :excludeFiles << :includeDir
      end

      # Valid for exe config
      if (Metamodel::ExecutableConfig === @child && Metamodel::ExecutableConfig === @parent)
        toRemove << :linkerScript << :artifactName << :mapFile
      end
      
      toRemove.each do |name|
        childData = @child.method(name).call()
        parentData = @parent.method(name).call()
        if (Array === childData)
          if not childData.empty?
            parentData.delete_if { |d| childData.any? { |e| e.name == d.name } }
            @parent.method(name.to_s + "=").call(parentData) # TODO: needed?
          end
        elsif not childData.nil? and not parentData.nil?
          if childData.name == parentData.name
            if (name != :dependency) or (childData.config == parentData.config)
              @parent.method(name.to_s + "=").call(nil)
            end
          end
        end          
      end      
    end   
    
    def extend()
      
    end
    
    def merge(type) # :merge means child will be updated, else parent will be updated
      if (type == :remove)
        remove
        return
      elsif (type == :replace)
        replace
        return
      end

      @merge = (type == :merge)
      target = (@merge ? @child : @parent)
      source = (@merge ? @parent : @child)
      
      # Valid for all config types
      
      deps = cloneParent(@parent.dependency)
      cloneChild(@child.dependency).each do |cd|
        deps << cd if deps.none? {|pd| pd.name == cd.name and pd.config == cd.config }
      end
      target.setDependency(deps)
      
      target.setSet(cloneParent(@parent.set) + cloneChild(@child.set))
      
      cExLib = cloneParent(@parent.exLib)
      cExLibSearchPath = cloneParent(@parent.exLibSearchPath)
      cUserLibrary = cloneParent(@parent.userLibrary)
      if @merge # otherwise thay are already manipulated when loading Adapt.meta
        manipulateLineNumbers(cExLib)
        manipulateLineNumbers(cExLibSearchPath)
        manipulateLineNumbers(cUserLibrary)
      end
      target.setExLib(cExLib + cloneChild(@child.exLib))
      target.setExLibSearchPath(cExLibSearchPath + cloneChild(@child.exLibSearchPath))
      target.setUserLibrary(cUserLibrary + cloneChild(@child.userLibrary))

 
      [:startupSteps, :preSteps, :postSteps, :exitSteps].each do |name|
        sourceData = source.method(name).call()
        targetData = target.method(name).call()
        if not sourceData.nil?
          if targetData.nil?
            target.method(name.to_s+"=").call(clone(sourceData))
          else
            targetData.step = cloneParent(@parent.method(name).call().step) + cloneChild(@child.method(name).call().step)
          end
        end
      end

      st = source.defaultToolchain
      tt = target.defaultToolchain
      if not st.nil? 
        if (not @merge or tt.nil?)
          target.setDefaultToolchain(clone(st))
        else
          mergeToolchain(st,tt,true)
        end
      end
      
      st = source.toolchain
      tt = target.toolchain
      if not st.nil? 
        if (not @merge or tt.nil?)
          target.setToolchain(clone(st))
        else
          mergeToolchain(st,tt,false)
        end
      end      


      # Valid for custom config
      if (Metamodel::CustomConfig === @child && Metamodel::CustomConfig === @parent)
        if not source.step.nil? and (not @merge or target.step.nil?)
          target.step = clone(source.step)
        end
      end

      # Valid for library and exe config
      if ((Metamodel::LibraryConfig === @child || Metamodel::ExecutableConfig === @child) && (Metamodel::LibraryConfig === @parent || Metamodel::ExecutableConfig === @parent))
        target.setFiles(cloneParent(@parent.files) + cloneChild(@child.files))
        target.setExcludeFiles(cloneParent(@parent.excludeFiles) + cloneChild(@child.excludeFiles))
        target.setIncludeDir(cloneParent(@parent.includeDir) + cloneChild(@child.includeDir))
      end

      # Valid for exe config
      if (Metamodel::ExecutableConfig === @child && Metamodel::ExecutableConfig === @parent)
        [:linkerScript, :artifactName, :mapFile].each do |name|
          sourceData = source.method(name).call()
          targetData = target.method(name).call()
          if not sourceData.nil? and (not @merge or targetData.nil?)
            target.method(name.to_s+"=").call(clone(sourceData))
          end
        end
      end
    
    end
  
  end

end