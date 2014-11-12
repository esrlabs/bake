require 'imported/buildingblocks/building_block'
require 'imported/buildingblocks/has_sources_mixin'
require 'imported/buildingblocks/has_includes_mixin'

module Bake
  module SingleSourceModule
    def get_task_name()
      get_sources_task_name
    end

    def convert_to_rake()
      objects_multitask = prepare_tasks_for_objects()

      if objects_multitask
        namespace "compile" do
          desc "compile sources in #{@name}-configuration"
          task @name => objects_multitask
        end
        objects_multitask.add_description("compile sources only")
      end

      setup_rake_dependencies(objects_multitask)
      objects_multitask
    end
  end

  class SingleSource < BuildingBlock
    include HasSources
    include HasIncludes

    include SingleSourceModule
  end
end
