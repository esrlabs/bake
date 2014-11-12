require 'bake/model/metamodel'
require 'imported/ext/file'

module Bake
  module Metamodel

      module Project::ClassModule
        def get_project_dir
          # todo: no. must be set from outside
          ::File.dirname(file_name)
        end
      end

  end
end
