require 'bake/model/metamodel'
require 'bake/model/language'
require 'bake/version'

require 'rgen/environment'
require 'rgen/fragment/dump_file_cache'
require 'rgen/fragment/fragmented_model'
require 'rgen/util/file_cache_map'

require 'rtext/default_loader'

require 'cxxproject/utils/exit_helper'
require 'cxxproject/utils/printer'
require 'bake/options'

module Cxxproject

class Loader

attr_reader :model

def initialize(options)
  @env = RGen::Environment.new
  @options = options

  fcm = RGen::Util::FileCacheMap.new(".bake", ".cache")
  fcm.version_info = Version.bake
  @DumpFileCache = RGen::Fragment::DumpFileCache.new(fcm)
  if @options.nocache
    def @DumpFileCache.load(fragment)
      :invalid
    end
  end
  
  @model = RGen::Fragment::FragmentedModel.new(:env => @env)
  @mainProjectName = File::basename(@options.main_dir)
end

def load(filename)

  sumErrors = 0
  
  if not File.exists?filename
    Printer.printError "Error: #{filename} does not exist"
    ExitHelper.exit(1) 
  end

  loader = RText::DefaultLoader.new(
    Cxxproject::Language,
    @model,
    :file_provider => proc { [filename] },
    :cache => @DumpFileCache)
  loader.load(:before_load => proc {|fragment, kind|
    case kind
    when :load_update_cache
      if @options.verbose
        puts "Loading and caching #{fragment.location}"
      else
        puts "Loading #{fragment.location}"
      end
    when :load_cached
      if @options.verbose
        puts "Loading cached #{fragment.location}"
      else
        puts "Loading #{fragment.location}"
      end
    when :load
      puts "Loading #{fragment.location}"
    else
      Printer.printError "Error: Could not load #{fragment.location}"
      ExitHelper.exit(1)     
    end
  })

  f = @model.fragments[0]
  @model.remove_fragment(f)

  f.data[:problems].each do |p|
    Printer.printError "Error: "+p.file+"("+p.line.to_s+"): "+p.message
  end
  
  if f.data[:problems].length > 0
    ExitHelper.exit(1) 
  end
  
  return f

end


end
end