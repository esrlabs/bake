require 'bakery/model/metamodel'
require 'bakery/model/language'
require 'common/version'

require 'rgen/environment'
require 'rgen/fragment/fragmented_model'

require 'rtext/default_loader'

require 'imported/utils/exit_helper'
require 'bake/toolchain/colorizing_formatter'

module Bake

  class BakeryLoader
    
    attr_reader :model
    
    def initialize
      @env = RGen::Environment.new
      @model = RGen::Fragment::FragmentedModel.new(:env => @env)
    end
    
    def load(filename)
    
      sumErrors = 0
      
      if not File.exists?filename
        Bake.formatter.printError "Error: #{filename} does not exist"
        ExitHelper.exit(1) 
      end
    
      loader = RText::DefaultLoader.new(
        Bake::BakeryLanguage,
        @model,
        :file_provider => proc { [filename] },
        :cache => @DumpFileCache)
      loader.load()
    
      f = @model.fragments[0]
      
      f.data[:problems].each do |p|
        Bake.formatter.printError "Error: "+p.file+"("+p.line.to_s+"): "+p.message
      end
      
      if f.data[:problems].length > 0
        ExitHelper.exit(1) 
      end
      
      return @env
    
    end
  
  
  end
end