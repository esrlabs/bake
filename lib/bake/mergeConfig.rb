require_relative '../common/ext/rtext'

module Bake

  class MergeConfig

    def initialize(child, parent)
      @child = child
      @parent = parent
    end

    def self.clone(obj)
      if obj.is_a?(Metamodel::ModelElement)
        cloneModelElement(obj)
      elsif Array === obj
        obj.map { |o| clone(o) }
      else
        obj # no clone, should not happen
      end
    end

    def self.cloneModelElement(obj)
      cpy = obj.class.new
      cpy.file_name = obj.file_name
      cpy.org_file_name = obj.file_name
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
      if Metamodel::BaseConfig_INTERNAL === @child &&
        Metamodel::BaseConfig_INTERNAL ===  @parent
        if @child.mergeInc != "" && @parent.mergeInc != "no"
          @parent.mergeInc = @child.mergeInc
        end
      end

      @child.class.ecore.eAllReferences.each do |f|
        next unless @parent.class.ecore.eAllReferences.include?f
        next unless f.containment
        childData = @child.getGeneric(f.name)
        if Metamodel::ModelElement === childData
          @parent.setGeneric(f.name,childData) if !childData.nil?
        elsif Array === childData
          if !childData.empty?
            parentData = @parent.getGeneric(f.name)
            cclasses = childData.map { |c| c.class }.uniq
            parentData.delete_if { |p| cclasses.include?p.class }
            parentData += childData
            @parent.setGeneric(f.name,parentData)
          end
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
      
      if Metamodel::BaseConfig_INTERNAL === childElem &&
        Metamodel::BaseConfig_INTERNAL ===  parentElem
        if childElem.mergeInc == parentElem.mergeInc
          parentElem.mergeInc = ""
        end
      end

      childElem.class.ecore.eAllReferences.each do |f|
        next unless f.containment
        begin
          childData = childElem.getGeneric(f.name)
          parentData = parentElem.getGeneric(f.name)
        rescue Exception => ex
          next # how to check fast if f.name is valid?
        end
        next if childData.nil? or parentData.nil?
        if (Array === childData)
          if !parentData.empty? && !childData.empty?
            childData.each do |c|
              cN = hasSubNodes(c)
              toRemove = []
              parentData.each do |p|
                next if p.class != c.class
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
          if parentData.class == childData.class && sameAttr(childData, parentData)
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

    def extendAttributes(childData, parentData)
       parentData.class.ecore.eAllAttributes.each do |a|
         childData.setGeneric(a.name, parentData.getGeneric(a.name)) if !childData.eIsSet(a.name) && parentData.eIsSet(a.name)
       end
     end

     def extend(child, parent, push_front)
       if Metamodel::BaseConfig_INTERNAL === child &&
         Metamodel::BaseConfig_INTERNAL ===  parent
         if child.mergeInc != "" && parent.mergeInc != "no"
           parent.mergeInc = child.mergeInc
         end
       end

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
                 extendAttributes(c, p)
                 extend(c, p, push_front)
                 extendedParentData << c
               else
                 extendedParentData << p
               end
             end
             restOfChildData = childData.find_all { |c| parentData.find {|p| p.ctype != c.ctype } }
             child.setGeneric(f.name, extendedParentData + restOfChildData)
           else
             if push_front
               child.setGeneric(f.name, childData + parentData)
             else
               child.setGeneric(f.name, parentData + childData)
             end
           end
         elsif Metamodel::ModelElement === parentData
           if childData.nil? || childData.class != parentData.class
             child.setGeneric(f.name, parentData)
           else
             extendAttributes(childData, parentData)
             extend(childData, parentData, push_front)
           end
         end
       end
     end

     def copyChildToParent(c, p)
       (p.class.ecore.eAllReferences & c.class.ecore.eAllReferences).each do |f|
         next unless f.containment
         childData = c.getGeneric(f.name)
         next if childData.nil? || (Array === childData && childData.empty?)
         p.setGeneric(f.name, childData)
       end
     end

    def merge(type)
      if (@child.strict == true) && !(@child.class == @parent.class)
        return
      end

      s = StringIO.new
      ser = RText::Serializer.new(Language)

      if Bake.options.debug
        s.puts "\n>>>> child <<<<"
        ser.serialize(@child, s)
        s.puts "\n>>>> parent <<<<"
        ser.serialize(@parent, s)
      end
      
      if (type == :remove)
        removeChilds(@child, @parent)
      elsif (type == :replace)
        replace
      elsif (type == :extend)
        c = MergeConfig.clone(@child)
        extend(c, @parent, false)
        copyChildToParent(c, @parent)
      elsif (type == :push_front)
        c = MergeConfig.clone(@child)
        extend(c, @parent, true)
        copyChildToParent(c, @parent)
      elsif (type == :merge)
        extend(@child, MergeConfig.clone(@parent), false)
      end

      if Bake.options.debug
        s.puts "\n>>>> result of #{type.to_s} <<<<"
        ser.serialize(type == :merge ? @child : @parent, s)
        puts "#{s.string}"
      end


    end

  end

end