require 'bake/model/metamodel'
require 'common/ext/file'

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
      end

      module BaseConfig_INTERNAL::ClassModule
        def qname
          @qname ||= parent.name + "," + name
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
      end

  end
end
