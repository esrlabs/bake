module Bake
  module HasLibraries
    LIB = 1
    USERLIB = 2
    LIB_WITH_PATH = 3
    SEARCH_PATH = 4
    DEPENDENCY = 5

    def lib_elements
      @lib_elements ||= []
    end

    # value: can be string or building block
    def add_lib_element(type, value, front = false)
      elem = [type, value.instance_of?(String) ? value : value.name]
      if front
        lib_elements.unshift(elem)
      else
        lib_elements << elem
      end
    end

    # 1. element: type
    # 2. element: name, must not be a building block
    def add_lib_elements(array_of_tuples, front = false)
      if front
        @lib_elements = array_of_tuples+lib_elements
      else
        lib_elements.concat(array_of_tuples)
      end
    end

  end
end
