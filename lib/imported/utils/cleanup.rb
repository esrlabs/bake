module Bake
  module Utils

    def self.cleanup_rake()
      Bake::ALL_BLOCKS.clear
      Bake::IDEInterface.instance.set_abort(false)
      # todo clean workspace?
    end

  end
end
