require_relative 'metamodel'
require_relative 'language'
require_relative '../../common/version'

require 'rgen/environment'
require 'rgen/fragment/dump_file_cache'
require 'rgen/fragment/fragmented_model'
require 'rgen/util/file_cache_map'

require 'rtext/default_loader'

require_relative '../../common/ext/rgen'
require_relative '../../common/exit_helper'
require_relative '../toolchain/colorizing_formatter'
require_relative '../options/options'

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

      @globalFilterStrMap = {
        Bake::Metamodel::StartupSteps => "STARTUP",
        Bake::Metamodel::PreSteps => "PRE",
        Bake::Metamodel::PostSteps => "POST",
        Bake::Metamodel::ExitSteps => "EXIT",
        Bake::Metamodel::CleanSteps => "CLEAN"
      }
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

      if !Bake.options.dry
        Utils.gitIgnore(File.dirname(filename)+"/.bake")
      end

      frag = @model.fragments[0]
      @model.remove_fragment(frag)
      frag
    end

    def filterElement?(elem)
      return false if Bake::Metamodel::Project === elem

      # 1st prio: explicit single filter
      if elem.filter != ""
        return true if  Bake.options.exclude_filter.include?elem.filter
        return false if Bake.options.include_filter.include?elem.filter
      end

      # 2nd prio: explicit global filter
      if defined?(elem.parent)
        globalFilterStr = @globalFilterStrMap[elem.parent.class]
        if (globalFilterStr)
            return true if  Bake.options.exclude_filter.include?globalFilterStr
            return false if Bake.options.include_filter.include?globalFilterStr
        end
      end

      # 3nd prio: default
      return true if elem.default == "off"
      false
    end

    def applyFilterOnArray(a)
      toRemove = []
      a.each do |elem|
        if filterElement?(elem)
          toRemove << elem
        else
          applyFilterOnElement(elem)
        end
      end
      toRemove.each { |r| r.parent = nil if r.respond_to?(:parent=) }
      return toRemove
    end

    def applyFilterOnElement(elem)
      return if elem.nil?
      elem.class.ecore.eAllReferences.each do |f|
       next unless f.containment
       begin
         childData = elem.getGeneric(f.name)
       rescue Exception => ex
         next
       end
       next if childData.nil?
       if (Array === childData)
         applyFilterOnArray(childData)
       elsif Metamodel::ModelElement === childData
         if filterElement?(childData)
           childData.parent = nil
         else
           applyFilterOnElement(childData)
         end
       end
      end
    end

    def load(filename)
      sumErrors = 0

      if not File.exist?filename
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

      tor = applyFilterOnArray(frag.root_elements)
      frag.root_elements.delete_if {|re| tor.include?(re)}

      return frag

    end

  end
end