require_relative '../common/exit_helper'
require_relative 'toolchain/colorizing_formatter'
require_relative '../common/options/parser'
require_relative '../common/version'
require_relative '../adapt/config/loader'

module Bake

  class Cache
    attr_accessor :referencedConfigs
    attr_accessor :adaptConfigs
    attr_accessor :adaptStrings
    attr_accessor :cache_file
    attr_accessor :version
    attr_accessor :workspace_roots
    attr_accessor :include_filter
    attr_accessor :exclude_filter
    attr_accessor :no_autodir
    attr_accessor :build_config
    attr_accessor :adapt_filenames
  end

  class CacheAccess
      attr_reader :cacheFilename

      def initialize()
        qacStr = Bake.options.qac ? "Qac" : ""
        if Bake.options.build_config == ""
          @cacheFilename = Bake.options.main_dir+"/.bake/Default" + qacStr + ".Project.meta.cache"
        else
          @cacheFilename = Bake.options.main_dir+"/.bake/Project.meta." + sanitize_filename(Bake.options.build_config) + qacStr + ".cache"
        end
        if !Bake.options.dry
          Utils.gitIgnore(File.dirname(@cacheFilename), :silent) 
        end
      end

      def load_cache
        cache = nil
        begin

          fileExists = File.exist?(@cacheFilename)
          puts "Cache: Checking if cache file #{@cacheFilename} exists: #{fileExists}" if Bake.options.debug
          if fileExists
            cacheTime = File.mtime(@cacheFilename)
            contents = File.open(@cacheFilename, "rb") {|io| io.read }
            cache = Marshal.load(contents)

            puts "Cache: Checking cache version: #{cache.version} vs. #{Version.number}" if Bake.options.debug
            if cache.version != Version.number
              Bake.formatter.printInfo("Info: cache version ("+cache.version+") does not match to bake version ("+Version.number+"), reloading meta information")
              cache = nil
            end

            if cache != nil
              puts "Cache: Checking if cache was moved: #{@cacheFilename} vs. #{cache.cache_file}" if Bake.options.debug
              if cache.cache_file != @cacheFilename
                Bake.formatter.printInfo("Info: cache filename changed, reloading meta information")
                cache = nil
              end
            end

            if cache != nil
              puts "Cache: Checking if referenced configs are up to date..." if Bake.options.debug
              cache.referencedConfigs.each do |pname,configs|
                configs.each do |config|
                  fileExists = File.exist?(config.file_name)
                  puts "Cache: Checking if #{config.file_name} exists: #{fileExists}" if Bake.options.debug
                  if not fileExists
                    Bake.options.nocache = true
                    Bake.formatter.printInfo("Info: cached meta file #{config.file_name} renamed or deleted, reloading meta information")
                    cache = nil
                    break
                  end
                  configTime = File.mtime(config.file_name)
                  puts "Cache: Checking if #{config.file_name} was modified: #{configTime} vs #{cacheTime}" if Bake.options.debug
                  if configTime > cacheTime + 1
                    Bake.formatter.printInfo("Info: #{config.file_name} has been changed, reloading meta information")
                    cache = nil
                    break
                  end
                end
                break if cache == nil
              end
            end

            if (cache != nil)
              puts "Cache: Checking adapt options: #{cache.adaptStrings.inspect} vs. #{Bake.options.adapt.inspect}" if Bake.options.debug
              if (cache.adaptStrings.length != Bake.options.adapt.length) ||
                (cache.adaptStrings.any? { |a| !Bake.options.adapt.include?(a) }) ||
                  (Bake.options.adapt.any? { |a| !cache.adaptStrings.include?(a) })
                Bake.formatter.printInfo("Info: adapts flags have been changed, reloading meta information")
                cache = nil
              end
            end

            if (cache != nil)
              cache.adapt_filenames.each do |fHash|
                f = fHash[:file]
                fileExists = File.exist?(f)
                puts "Cache: Checking if #{f} exists: #{fileExists}" if Bake.options.debug
                if !fileExists
                  Bake.formatter.printInfo("Info: #{f} does not exist anymore, reloading meta information")
                  cache = nil
                  break
                end
                adaptTime = File.mtime(f)
                puts "Cache: Checking if #{f} was modified: #{adaptTime} vs #{cacheTime}" if Bake.options.debug
                if adaptTime > cacheTime + 1
                  Bake.formatter.printInfo("Info: #{f} has been changed, reloading meta information")
                  cache = nil
                  break
                end
              end
            end

            if cache != nil
              puts "Cache: Checking root options: #{cache.workspace_roots.inspect} vs. #{Bake.options.roots.inspect}" if Bake.options.debug
              if (!Root.equal(cache.workspace_roots, Bake.options.roots))
                Bake.formatter.printInfo("Info: specified roots differ from cached roots, reloading meta information") if cache.nil?
                cache = nil
              end
            end

            if cache != nil
              puts "Cache: Checking include_filter options: #{cache.include_filter.inspect} vs. #{Bake.options.include_filter.inspect}" if Bake.options.debug
              if (cache.include_filter.length != Bake.options.include_filter.length) ||
                (cache.include_filter.any? { |a| !Bake.options.include_filter.include?(a) }) ||
                (Bake.options.include_filter.any? { |a| !cache.include_filter.include?(a) })
                cache = nil
                Bake.formatter.printInfo("Info: specified include filters differ from cached filters, reloading meta information")
              end
            end

            if cache != nil
              puts "Cache: Checking exclude_filter options: #{cache.exclude_filter.inspect} vs. #{Bake.options.exclude_filter.inspect}" if Bake.options.debug
              if (cache.exclude_filter.length != Bake.options.exclude_filter.length) ||
                (cache.exclude_filter.any? { |a| !Bake.options.exclude_filter.include?(a) }) ||
                (Bake.options.exclude_filter.any? { |a| !cache.exclude_filter.include?(a) })
                cache = nil
                Bake.formatter.printInfo("Info: specified include filters differ from cached filters, reloading meta information")
              end
            end

            if cache != nil
              puts "Cache: Checking autodir option: #{cache.no_autodir} vs. #{Bake.options.no_autodir}" if Bake.options.debug
              if (not Bake.options.no_autodir.eql?(cache.no_autodir))
                cache = nil
                Bake.formatter.printInfo("Info: no_autodir option differs in cache, reloading meta information")
              end
            end

          else
            Bake.formatter.printInfo("Info: cache not found, reloading meta information")
          end
        rescue Exception => e
          Bake.formatter.printWarning("Warning: cache file corrupt, reloading meta information (cache might be written by an older bake version)")
          if Bake.options.debug
            puts e.message
            puts e.backtrace
          end
          cache = nil
        end

        if cache != nil
          Bake.formatter.printInfo("Info: cache is up-to-date, loading cached meta information") if Bake.options.verbose >= 3
          Bake.options.build_config = cache.build_config
          return cache.referencedConfigs
        end

        return nil
      end

      def write_cache(referencedConfigs, adaptConfigs)
        return if Bake.options.dry

        cache = Cache.new
        cache.referencedConfigs = referencedConfigs
        cache.adaptStrings = Bake.options.adapt
        cache.adaptConfigs = adaptConfigs
        cache.cache_file = @cacheFilename
        cache.version = Version.number
        cache.include_filter = Bake.options.include_filter
        cache.no_autodir = Bake.options.no_autodir
        cache.exclude_filter = Bake.options.exclude_filter
        cache.workspace_roots = Bake.options.roots
        cache.build_config = Bake.options.build_config
        cache.adapt_filenames = AdaptConfig.filenames
        bbdump = Marshal.dump(cache)
        begin
          File.open(@cacheFilename, 'wb') {|file| file.write(bbdump) }
        rescue Exception=>e
          if Bake.options.verbose >= 3
            Bake.formatter.printWarning("Warning: Could not write cache file #{@cacheFilename}")
            if Bake.options.debug
              puts e.message
              puts e.backtrace
            end
          end
        end
        Bake.options.nocache = false
      end

  end


end
