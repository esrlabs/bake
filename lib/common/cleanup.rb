require_relative "../blocks/block"
require_relative "ext/file"
require_relative "../bake/config/checks"

module Bake

    def self.cleanup()
      Blocks::ALL_BLOCKS.clear
      Blocks::ALL_COMPILE_BLOCKS.clear
      Blocks::CC2J.clear
      Bake::IDEInterface.instance.set_abort(false)
      Blocks::Block.reset_block_counter
      Blocks::Block.reset_delayed_result
      Configs::Checks.cleanupWarnings
      ToCxx::reset_include_deps
    end

end
