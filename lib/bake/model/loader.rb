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

      if !Bake.options.dry
        @DumpFileCache = RGen::Fragment::DumpFileCache.new(fcm)
      else
        @DumpFileCache = nil
      end

      @model = RGen::Fragment::FragmentedModel.new(:env => @env)
    end

    def load_internal(filename, silent = false)
      silent = false if Bake.options.debug
      loader = RText::DefaultLoader.new(
        Bake::Language,
        @model,
        :file_provider => proc { [filename] },
        :cache => @DumpFileCache)
      loader.load(:before_load => proc {|fragment, kind|
        case kind
        when :load_update_cache
          if Bake.options.verbose >= 3
            puts "Loading and caching #{fragment.location}" unless silent
          else
            puts "Loading #{fragment.location}" unless silent
          end
        when :load_cached
          if Bake.options.verbose >= 3
            puts "Loading cached #{fragment.location}" unless silent
          else
            puts "Loading #{fragment.location}" unless silent
          end
        when :load
          puts "Loading #{fragment.location}" unless silent
        else
          Bake.formatter.printError("Error: Could not load #{fragment.location}")
          ExitHelper.exit(1)
        end
      })

      frag = @model.fragments[0]
      @model.remove_fragment(frag)
      frag
    end


    def load(filename)
      sumErrors = 0

      if not File.exists?filename
        Bake.formatter.printError("Error: #{filename} does not exist")
        ExitHelper.exit(1)
      end

      frag = nil
      if not Bake.options.nocache
        frag = load_internal(filename) # regular load
        frag = nil if frag.root_elements.length > 0 and filename != frag.root_elements[0].file_name
      end

      if frag.nil?
        def @DumpFileCache.load(fragment)
          :invalid
        end
        frag = load_internal(filename, !Bake.options.nocache)
      end

      frag.data[:problems].each do |p|
        Bake.formatter.printError(p.message, p.file, p.line)
      end

      if frag.data[:problems].length > 0
        ExitHelper.exit(1)
      end

      return frag

    end

  end
end