module Bake

    def self.cleanup()
      Blocks::ALL_BLOCKS.clear
      Blocks::ALL_COMPILE_BLOCKS.clear
      Bake::IDEInterface.instance.set_abort(false)
    end

end
