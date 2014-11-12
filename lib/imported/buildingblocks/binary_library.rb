require 'imported/buildingblocks/building_block'
require 'imported/buildingblocks/has_libraries_mixin'
require 'imported/buildingblocks/has_includes_mixin'

module Bake

  class BinaryLibrary < BuildingBlock
    include HasLibraries
    include HasIncludes

    def initialize(name, useNameAsLib = true)
      super(name)
      if useNameAsLib
        @useNameAsLib = name
        add_lib_element(HasLibraries::LIB, name, true)
      else
        @useNameAsLib = nil
      end
    end

    def get_task_name()
      return @useNameAsLib if @useNameAsLib
      @name
    end


    def convert_to_rake()
      res = task get_task_name
      def res.needed?
        return false
      end
      res.transparent_timestamp = true
      res.type = Rake::Task::BINARY
      setup_rake_dependencies(res)
      res
    end

  end
end
