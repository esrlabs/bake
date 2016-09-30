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
          libStuff.find_all { |l| Dependency === l }
        end
      end

  end
end
