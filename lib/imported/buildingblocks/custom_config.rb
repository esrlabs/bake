require 'imported/buildingblocks/building_block'
require 'imported/buildingblocks/has_libraries_mixin'
require 'imported/buildingblocks/has_includes_mixin'

module Bake

  class CustomConfig < BuildingBlock
    include HasLibraries
    include HasIncludes

    def get_task_name()
      @task_name ||= "MAIN " + @project_name+"_"+@config_name
    end

    def convert_to_rake()
      res = task get_task_name
      def res.needed?
        return false
      end
      res.transparent_timestamp = true
      res.type = Rake::Task::CUSTOM
      setup_rake_dependencies(res)
      res
    end

  end
end
