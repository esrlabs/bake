require 'bakery/model/metamodel'
require 'bakery/model/language'
require 'bake/version'

require 'rgen/environment'
require 'rgen/fragment/fragmented_model'

require 'rtext/default_loader'

require 'imported/utils/exit_helper'
require 'imported/utils/printer'

module Bake

class BakeryLoader

attr_reader :model

def initialize(options)
  @env = RGen::Environment.new
  @options = options
  @model = RGen::Fragment::FragmentedModel.new(:env => @env)
end

def load(filename)

  sumErrors = 0
  
  if not File.exists?filename
    Printer.printError "Error: #{filename} does not exist"
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
    Printer.printError "Error: "+p.file+"("+p.line.to_s+"): "+p.message
  end
  
  if f.data[:problems].length > 0
    ExitHelper.exit(1) 
  end
  
  return @env

end


end
end