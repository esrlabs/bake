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
    
    def cloneParent(obj)
      @merge ? clone(obj) : obj
    end
    def cloneChild(obj)
      @merge ? obj : clone(obj)
    end
    def getTargetNode()
      @merge ? @child : @parent
    end
    def getSourceNode()
      @merge ? @parent : @child
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
      [:toolchain, :defaultToolchain, :startupSteps, :preSteps, :postSteps, :exitSteps].each do |name|
        @parent.method(name.to_s+"=").call(nil) if not @child.method(name).call().nil?
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
      elsif (type == :replace)
        replace
      else
        @merge = (type == :merge)
      end
      
      # Valid for all config types
      
      deps = cloneParent(@parent.dependency)
      cloneChild(@child.dependency).each do |cd|
        deps << cd if deps.none? {|pd| pd.name == cd.name and pd.config == cd.config }
      end
      getTargetNode().setDependency(deps)
      
      getTargetNode().setSet(cloneParent(@parent.set) + cloneChild(@child.set))
      
      cExLib = cloneParent(@parent.exLib)
      cExLibSearchPath = cloneParent(@parent.exLibSearchPath)
      cUserLibrary = cloneParent(@parent.userLibrary)
      if @merge # otherwise thay are already manipulated when loading Adapt.meta
        manipulateLineNumbers(cExLib)
        manipulateLineNumbers(cExLibSearchPath)
        manipulateLineNumbers(cUserLibrary)
      end
      getTargetNode().setExLib(cExLib + cloneChild(@child.exLib))
      getTargetNode().setExLibSearchPath(cExLibSearchPath + cloneChild(@child.exLibSearchPath))
      getTargetNode().setUserLibrary(cUserLibrary + cloneChild(@child.userLibrary))

 
      [:startupSteps, :preSteps, :postSteps, :exitSteps].each do |name|
        sourceData = getSourceNode().method(name).call()
        targetData = getTargetNode().method(name).call()
        if not sourceData.nil?
          if targetData.nil?
            getTargetNode().method(name.to_s+"=").call(clone(sourceData))
          else
            targetData.step = cloneParent(@parent.method(name).call().step) + cloneChild(@child.method(name).call().step)
          end
        end
      end
      
      if not @merge
        return
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
        if not getSourceNode().step.nil? and (not @merge or getTargetNode().step.nil?)
          getTargetNode().step = clone(getSourceNode().step)
        end
      end

      # Valid for library and exe config
      if ((Metamodel::LibraryConfig === @child || Metamodel::ExecutableConfig === @child) && (Metamodel::LibraryConfig === @parent || Metamodel::ExecutableConfig === @parent))
        getTargetNode().setFiles(cloneParent(@parent.files) + cloneChild(@child.files))
        getTargetNode().setExcludeFiles(cloneParent(@parent.excludeFiles) + cloneChild(@child.excludeFiles))
        getTargetNode().setIncludeDir(cloneParent(@parent.includeDir) + cloneChild(@child.includeDir))
      end

      # Valid for exe config
      if (Metamodel::ExecutableConfig === @child && Metamodel::ExecutableConfig === @parent)
        [:linkerScript, :artifactName, :mapFile].each do |name|
          sourceData = getSourceNode().method(name).call()
          targetData = getTargetNode().method(name).call()
          if not sourceData.nil? and (not @merge or targetData.nil?)
            getTargetNode().method(name.to_s+"=").call(clone(sourceData))
          end
        end
      end
    
    end
  
  end

end