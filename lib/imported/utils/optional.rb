require 'rake'

module Bake
  module Utils
    def self.optional_package(block1, block2)
      begin
        block1.call
      rescue LoadError => e
        if RakeFileUtils.verbose == true
          puts e
        end
        block2.call if block2
      end
    end
  end
end
