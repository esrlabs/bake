module Bake
  module HasDependencies

    def dependencies
      @dependencies ||= []
    end

    def helper_dependencies
      @helper_dependencies ||= []
    end

   def set_dependencies(deps)
      @dependencies = deps.map { |dep| dep.instance_of?(String) ? dep : dep.name }
      self
    end

    def set_helper_dependencies(deps)
      @helper_dependencies = deps.map { |dep| dep.instance_of?(String) ? dep : dep.name }
      self
    end

    def direct_deps
      return @direct_deps if @direct_deps

      @all_dependencies_set = Set.new
      @all_dependencies_set << self
      @all_dependencies = [self]

      depList = helper_dependencies.length > 0 ? helper_dependencies : dependencies

      depList.each do |d|
        bb = ALL_BUILDING_BLOCKS[d]
        if not bb
          raise "Error: while reading config file for #{self.name}: dependent building block \"#{d}\" was specified but not found!"
        end
        next if @all_dependencies_set.include?bb

        @all_dependencies << bb
        @all_dependencies_set << bb

        # deps in modules may be splitted into its contents
        if ModuleBuildingBlock === bb
          bb.contents.each do |c|
            next if @all_dependencies_set.include?c
            @all_dependencies << c
            @all_dependencies_set << c
          end
        end

      end

      @direct_deps = @all_dependencies.dup
      @direct_deps
    end

    def all_dependencies()
      return @all_dependencies if @all_deps_calculated

      direct_deps.each do |d|
        d.all_dependencies_recursive(@all_dependencies, @all_dependencies_set)
      end

      @all_deps_calculated = true
      @all_dependencies
    end

    def all_dependencies_recursive(all_deps, all_deps_set)
      deps = [] # needed to keep order

      direct_deps.each do |d|
        next if all_deps_set.include?d
        all_deps << d
        all_deps_set << d
        deps << d
      end

      deps.each do |d|
        d.all_dependencies_recursive(all_deps, all_deps_set)
      end
    end

  end
end
