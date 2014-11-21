require 'imported/utils/exit_helper'
require 'imported/toolchain/colorizing_formatter'
require 'common/options/parser'
require 'common/version'

module Bake

  class Cache
    attr_accessor :project2config
    attr_accessor :files # project_files
    attr_accessor :cache_file
    attr_accessor :version
    attr_accessor :workspace_roots
    attr_accessor :include_filter
    attr_accessor :exclude_filter
    attr_accessor :defaultToolchain
    attr_accessor :defaultToolchainTime
    attr_accessor :no_autodir
  end
  
  class CacheAccess
      attr_reader :defaultToolchain
      attr_reader :defaultToolchainTime
      attr_reader :cacheFilename
  
      def initialize(pm_filename, config_name, options)
        @cacheFilename = File.dirname(pm_filename)+"/.bake/"+File.basename(pm_filename)+"."+sanitize_filename(config_name)+".cache"
        
        CLOBBER.include(File.dirname(pm_filename)+"/.bake")
          
        FileUtils.mkdir_p(File.dirname(@cacheFilename))
        @defaultToolchain = nil
        @defaultToolchainTime = nil
      end
      
      def load_cache
        cache = nil
        begin
          allFiles = Dir.glob(File.dirname(@cacheFilename)+"/*.cache")
          if allFiles.include?(@cacheFilename)
            cacheTime = File.mtime(@cacheFilename)
            contents = File.open(@cacheFilename, "rb") {|io| io.read }
            cache = Marshal.load(contents)
            
            if cache.version != Version.number
              Bake.formatter.printInfo("Info: cache version ("+cache.version+") does not match to bake version ("+Version.number+"), reloading meta information")
              cache = nil
              Bake.options.set_nocache # complete re-read 
            else
              @defaultToolchain = cache.defaultToolchain
              @defaultToolchainTime = cache.defaultToolchainTime
            end
              
            if cache != nil
              if cache.cache_file != @cacheFilename
                Bake.formatter.printInfo "Info: cache filename changed, reloading meta information"
                cache = nil
                Bake.options.set_nocache # abs dir may wrong 
              end
            end
            
            if cache != nil
              cache.files.each do |c|
                if (not File.exists?(c))
                  Bake.formatter.printInfo "Info: meta file(s) renamed or deleted, reloading meta information"
                  cache = nil
                  Bake.options.set_nocache # abs dir may wrong 
                  break
                end
              end
            end
            
            if cache != nil
              cache.project2config.each do |pname,config|
                if not File.exists?(config.file_name)
                  Bake.formatter.printInfo "Info: meta file(s) renamed or deleted, reloading meta information"
                  cache = nil
                  Bake.options.set_nocache # abs dir may wrong 
                end
              end  
            end
              
            if cache != nil
              cache.files.each do |c|
                if File.mtime(c) > cacheTime
                  Bake.formatter.printInfo "Info: cache is out-of-date, reloading meta information"
                  cache = nil
                  break
                end
              end
            end

            if cache != nil
              if cache.workspace_roots.length == Bake.options.roots.length
                cache.workspace_roots.each do |r|
                  if not Bake.options.roots.include?r
                    cache = nil
                    break
                  end
                end  
              else
                cache = nil
              end
              Bake.formatter.printInfo "Info: specified roots differ from cached roots, reloading meta information" if cache.nil?
            end
            
            if cache != nil
              if (not Bake.options.include_filter.eql?(cache.include_filter)) or (not Bake.options.exclude_filter.eql?(cache.exclude_filter))
                cache = nil
                Bake.formatter.printInfo "Info: specified filters differ from cached filters, reloading meta information"
              end
            end 
            
            if cache != nil
              if (not Bake.options.no_autodir.eql?(cache.no_autodir))
                cache = nil
                Bake.formatter.printInfo "Info: no_autodir option differs in cache, reloading meta information"
              end
            end             
            
          else
            Bake.formatter.printInfo("Info: cache not found, reloading meta information")
          end
          
        rescue ExitHelperException
          raise
        rescue
          Bake.formatter.printWarning "Warning: cache file corrupt, reloading meta information"
          cache = nil
        end      
        
        if cache != nil
          Bake.formatter.printInfo "Info: cache is up-to-date, loading cached meta information" if Bake.options.verboseHigh
          
          cache.files.each do |c|
            CLOBBER.include(File.dirname(c)+"/.bake")
          end          
          
          return cache.project2config
        end
        return nil
        
      end
      
      def write_cache(project_files, project2config, defaultToolchain, defaultToolchainTime)
        cache = Cache.new
        cache.project2config = project2config
        cache.files = project_files
        cache.cache_file = @cacheFilename
        cache.version = Version.number
        cache.include_filter = Bake.options.include_filter
        cache.no_autodir = Bake.options.no_autodir
        cache.exclude_filter = Bake.options.exclude_filter
        cache.workspace_roots = Bake.options.roots
        cache.defaultToolchain = defaultToolchain
        cache.defaultToolchainTime = defaultToolchainTime
        bbdump = Marshal.dump(cache)
        begin
          File.delete(@cacheFilename)
        rescue
        end
        File.open(@cacheFilename, 'wb') {|file| file.write(bbdump) }
          
        project_files.each do |f|
          CLOBBER.include(File.dirname(f)+"/.bake")
        end

      end
      
  end
  
 
end
  