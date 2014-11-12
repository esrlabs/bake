require 'imported/buildingblocks/building_block'

# todo...
module Bake

  class CustomBuildingBlock < BuildingBlock
    attr_reader :custom_command, :actions

    def set_custom_command(c)
      @custom_command = c
      self
    end

    def get_task_name()
      name
    end

    def set_actions(actions)
      if actions.kind_of?(Array)
        @actions = actions
      else
        @actions = [actions]
      end
    end

    def convert_to_rake()
      desc get_task_name
      res = task get_task_name do
        actions.each do |a|
          a.call
        end
      end
      res.type = Rake::Task::CUSTOM
      setup_rake_dependencies(res)
      res
    end

  end
end
