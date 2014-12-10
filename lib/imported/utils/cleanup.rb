module Bake
  module Utils

    def self.cleanup_rake()
      Blocks::ALL_BLOCKS.clear
      Blocks::ALL_COMPILE_BLOCKS.clear
      Bake::IDEInterface.instance.set_abort(false)
      # todo clean workspace?
    end

  end
end
