require 'bake/model/metamodel'
require 'bake/model/language'
require 'common/version'

require 'rgen/environment'
require 'rgen/fragment/dump_file_cache'
require 'rgen/fragment/fragmented_model'
require 'rgen/util/file_cache_map'

require 'rtext/default_loader'

require 'common/exit_helper'
require 'bake/toolchain/colorizing_formatter'
require 'bake/options/options'

module Bake

  class Loader
  
    attr_reader :model
  
    def initialize
      @env = RGen::Environment.new
    
      fcm = RGen::Util::FileCacheMap.new(".bake", ".cache")
      fcm.version_info = Version.number
      @DumpFileCache = RGen::Fragment::DumpFileCache.new(fcm)
      if Bake.options.nocache
        def @DumpFileCache.load(fragment)
          :invalid
        end
      end
      
      @model = RGen::Fragment::FragmentedModel.new(:env => @env)
    end
    
    def load(filename)
    
      sumErrors = 0
      
      if not File.exists?filename
        Bake.formatter.printError "Error: #{filename} does not exist"
        ExitHelper.exit(1) 
      end
    
      loader = RText::DefaultLoader.new(
        Bake::Language,
        @model,
        :file_provider => proc { [filename] },
        :cache => @DumpFileCache)
      loader.load(:before_load => proc {|fragment, kind|
        case kind
        when :load_update_cache
          if Bake.options.verboseHigh
            puts "Loading and caching #{fragment.location}"
          else
            puts "Loading #{fragment.location}"
          end
        when :load_cached
          if Bake.options.verboseHigh
            puts "Loading cached #{fragment.location}"
          else
            puts "Loading #{fragment.location}"
          end
        when :load
          puts "Loading #{fragment.location}"
        else
          Bake.formatter.printError "Error: Could not load #{fragment.location}"
          ExitHelper.exit(1)     
        end
      })
    
      f = @model.fragments[0]
      @model.remove_fragment(f)
    
      f.data[:problems].each do |p|
        Bake.formatter.printError "Error: "+p.file+"("+p.line.to_s+"): "+p.message
      end
      
      if f.data[:problems].length > 0
        ExitHelper.exit(1) 
      end
      
      return f
    
    end
  
  end
end