require_relative "../blocks/block"

module Bake

    def self.cleanup()
      Blocks::ALL_BLOCKS.clear
      Blocks::ALL_COMPILE_BLOCKS.clear
      Blocks::CC2J.clear
      Bake::IDEInterface.instance.set_abort(false)
      Blocks::Block.reset_block_counter
      Blocks::Block.reset_delayed_result
    end

end
