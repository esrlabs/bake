module Bake

  class MergeConfig
  
    def initialize(child, parent)
      @child = child
      @parent = parent
    end
    

    def manipulateLineNumbers(ar)
      ar.each { |l| l.line_number -= 100000  }
    end
    
    def clone(obj)
      if obj.is_a?(Metamodel::ModelElement)
        cloneModelElement(obj)
      elsif Array === obj
        obj.map { |o| clone(o) }
      else
        obj # no clone, should not happen
      end
    end
    
    def cloneModelElement(obj)
      cpy = obj.class.new
      cpy.file_name = obj.file_name
      obj.class.ecore.eAllStructuralFeatures.each do |f|
        value = obj.getGeneric(f.name)
        if f.is_a?(RGen::ECore::EReference) && f.containment
          if value.is_a?(Array)
            cpy.setGeneric(f.name, value.collect{|v| clone(v)})
          elsif !value.nil?
            cpy.setGeneric(f.name, clone(value))
          end
        elsif f.is_a?(RGen::ECore::EAttribute)
          cpy.setGeneric(f.name, value) if obj.eIsSet(f.name)
        end
      end
      cpy
    end
    
   
    def replace()
      @child.class.ecore.eAllReferences.each do |f|
        next unless @parent.class.ecore.eAllReferences.include?f
        next unless f.containment
        childData = @child.getGeneric(f.name)
        if (Array === childData and not childData.empty?) or (Metamodel::ModelElement === childData and not childData.nil?)
          @parent.setGeneric(f.name,clone(childData))
        end
      end
    end
    
    def hasSubNodes(elem)
      elem.class.ecore.eAllReferences.each do |f|
        next unless f.containment
        elemData = elem.getGeneric(f.name)
        return true if (Array === elemData && !elemData.empty?)
        return true if (Metamodel::ModelElement === elemData)
      end
      false
    end

    def sameAttr(childData, parentData)
      childData.class.ecore.eAllAttributes.all? { |a| 
        a.eAnnotations.each do |x| x.details.each do |y|
          return true if (y.key == :internal and y.value == true)
        end; end
        a.name == "line_number" || (not childData.eIsSet(a.name)) || (childData.getGeneric(a.name) == parentData.getGeneric(a.name))
      }
    end
    
    def removeChilds(childElem, parentElem)
      return if childElem.nil? or parentElem.nil?
      
      childElem.class.ecore.eAllReferences.each do |f|
        next unless f.containment
        
        childData = childElem.getGeneric(f.name)
        parentData = parentElem.getGeneric(f.name)
        next if childData.nil? or parentData.nil?
        
        if (Array === childData)
          if !parentData.empty? && !childData.empty?
            childData.each do |c|
              cN = hasSubNodes(c)    
              toRemove = []
              parentData.each do |p|
                if (not cN)
                  if sameAttr(c, p)  
                    toRemove << p
                  end
                else
                  removeChilds(c, p);
                end
              end
              toRemove.each do |r|
                parentElem.removeGeneric(f.name, r)
              end
            end
          end
        elsif Metamodel::ModelElement === childData
          if sameAttr(childData, parentData)
            cN = hasSubNodes(childData)
            if (not cN)
              parentElem.setGeneric(f.name, nil)
            else
              removeChilds(childData, parentData)
            end
          end # otherwise not equal, will not be deleted
        end
      end
    end
    
    
    def adaptAttributes(childData, parentData)
      childData.class.ecore.eAllAttributes.each do |a| 
        parentData.setGeneric(a.name, childData.getGeneric(a.name)) if childData.eIsSet(a.name)
      end
    end
    
    def adapt(child, parent)
      (parent.class.ecore.eAllReferences & child.class.ecore.eAllReferences).each do |f|
        next unless f.containment
          
        childData = child.getGeneric(f.name)
        next if childData.nil? or (Array === childData && childData.empty?)
        parentData = parent.getGeneric(f.name)
          
        if Array === childData
          if f.name == "compiler"
            childData.each do |c| 
              p = parentData.find { |p| p.ctype == c.ctype }
              if p.nil?
                parentData << c
              else
                adaptAttributes(c, p)
                adapt(c, p)
              end
            end
            parent.setGeneric(f.name, parentData)
          else
            parent.setGeneric(f.name, parentData + childData)
          end
        elsif Metamodel::ModelElement === childData
          if parentData.nil?
            parent.setGeneric(f.name, childData)
          else
            adaptAttributes(childData, parentData)
            adapt(childData, parentData)
          end
        end
      end
    end
    
    
    def extendAttributes(childData, parentData)
       parentData.class.ecore.eAllAttributes.each do |a| 
         childData.setGeneric(a.name, parentData.getGeneric(a.name)) if !childData.eIsSet(a.name) && parentData.eIsSet(a.name)
       end
     end
     
     def extend(child, parent)
       (parent.class.ecore.eAllReferences & child.class.ecore.eAllReferences).each do |f|
         next unless f.containment
         parentData = parent.getGeneric(f.name)
         next if parentData.nil? or (Array === parentData && parentData.empty?)
         childData = child.getGeneric(f.name)
           
         if Array === parentData
           if f.name == "compiler"
             extendedParentData = []
             parentData.each do |p| 
               c = childData.find { |c| p.ctype == c.ctype }
               if c
                 adaptAttributes(c, p)
                 adapt(c, p)
               end
               extendedParentData << p
             end
             restOfChildData = childData.find_all { |c| parentData.find {|p| p.ctype != c.ctype } }
             child.setGeneric(f.name, extendedParentData + restOfChildData)  
           else
             if ["exLib", "exLibSearchPath", "userLibrary"].include?f.name
               manipulateLineNumbers(parentData)
             end
             child.setGeneric(f.name, parentData + childData)
           end
         elsif Metamodel::ModelElement === parentData
           if childData.nil?
             child.setGeneric(f.name, parentData)
           else
             extendAttributes(childData, parentData)
             extend(childData, parentData)
           end
         end
       end
     end    
    
    def merge(type) # :merge means child will be updated, else parent will be updated
      if (type == :remove)
        removeChilds(@child, @parent)
      elsif (type == :replace)
        replace
      elsif (type == :extend)
        adapt(clone(@child), @parent)
      elsif (type == :merge)
        extend(@child, clone(@parent))
      end
    end
  
  end

end