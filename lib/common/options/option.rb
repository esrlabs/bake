module Bake

class Option
  attr_reader :param, :arg, :block
  def initialize(param, arg, &f)
    @param = param
    @arg = arg # true / false
    @block = f
    f
  end
end

end
