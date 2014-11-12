require 'imported/buildingblocks/building_block'
require 'imported/buildingblocks/has_libraries_mixin'
require 'imported/buildingblocks/has_sources_mixin'
require 'imported/buildingblocks/has_includes_mixin'


# can be used as wrapper for other tasks
module Bake
  class ModuleBuildingBlock < BuildingBlock

    attr_accessor :contents
    attr_accessor :main_content
    attr_accessor :last_content

    def initialize(name)
      super
      @contents = []
      @last_content = self
      @main_content = nil
    end

    def get_task_name()
      name
    end

    def convert_to_rake()
      res = task get_task_name
      res.type = Rake::Task::MODULE
      res.transparent_timestamp = true

      setup_rake_dependencies(res)
      res
    end
  end
end
