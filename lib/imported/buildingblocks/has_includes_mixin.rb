module Bake
  module HasIncludes
    def includes
      @includes ||= []
    end
    def set_includes(x)
      @includes = x
      self
    end

    def local_includes
      @local_includes ||= []
    end
    def set_local_includes(x)
      @local_includes = x
      self
    end

  end
end
