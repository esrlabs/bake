require 'bake/model/metamodel'
require 'common/ext/file'

module Bake
  module Metamodel

      module ModelElement::ClassModule
        def get_project_dir
          # todo: no. must be set from outside
          ::File.dirname(file_name)
        end
      end
      
      module BaseConfig_INTERNAL::ClassModule
        def qname
          @qname ||= parent.name + "," + name
        end
      end      

  end
end
