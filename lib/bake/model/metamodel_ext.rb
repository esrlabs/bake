require_relative 'metamodel'
require_relative '../../common/ext/file'

module Bake
  module Metamodel

      module ModelElement::ClassModule
        def get_project_dir
          comp = self
          while comp.respond_to?"parent"
            comp = comp.parent
          end
          ::File.dirname(comp.file_name)
        end

        def getConfig
          comp = self
          while !(BaseConfig_INTERNAL === comp) && comp.respond_to?("parent")
            comp = comp.parent
          end
          return comp
        end

      end

      module Dependency::ClassModule
        def setInjected
          @injected = true
        end
        def injected?
          @injected ||= false
        end
      end
      
      module Adapt::ClassModule
        def mapValue(str)
          str.split(";").map { |p| /\A#{p.gsub("*", "(\\w*)")}\z/ }
        end
        def calcHash()
          @hash = {}
          deprecated = ["toolchain", "mainConfig", "mainProject", "os"]
          deprecated.each do |d|
            @hash[d] = self.send(d).empty? ? [] : mapValue(self.send(d))
          end
          self.scopes.each do |s|
            @hash[s.name] = [] unless @hash.has_key?(s.name)
            @hash[s.name] += mapValue(s.value)
          end
          @hash
        end
        def getHash
          @hash ||= calcHash()
        end
      end
      
      module BaseConfig_INTERNAL::ClassModule
        def qname
          @qname ||= parent.name + "," + name
        end
        def depInc
          baseElement.find_all { |l| Dependency === l || IncludeDir === l}
        end
        def dependency
          baseElement.find_all { |l| Dependency === l }
        end
        def libStuff
          baseElement.find_all { |l| LibStuff === l }
        end
        def includeDir
          baseElement.find_all { |l| IncludeDir === l }
        end
        def setEnvVar(name, value)
          @envVar ||= {}
          @envVar[name] = value
        end
        def writeEnvVars()
          @envVar.each do |name, value|
            ENV[name] = value
          end if defined?(@envVar)
        end
      end

  end
end
