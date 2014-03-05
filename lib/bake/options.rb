require 'cxxproject/ext/rake'
require 'cxxproject/utils/printer'
require "cxxproject/toolchain/colorizing_formatter"
require "option/parser"

module Cxxproject

  class Options < Parser
    attr_reader :build_config, :main_dir, :project, :filename, :eclipse_version, :alias_filename # String
    attr_reader :roots, :include_filter, :exclude_filter # String List
    attr_reader :clean, :rebuild, :single, :verbose, :nocache, :color, :show_includes, :linkOnly, :check_uninc, :printLess, :no_autodir, :clobber # Boolean
    attr_reader :threads, :socket # Fixnum

    def initialize(argv)
      super(argv)

      @build_config = ""
      @main_dir = nil
      @project = nil      
      @filename = nil
      @single = false
      @clean = false
      @clobber = false
      @rebuild = false
      @verbose = false
      @nocache = false
      @check_uninc = false
      @color = false
      @show_includes = false
      @linkOnly = false
      @printLess = false
      @no_autodir = false
      @threads = 8
      @roots = []
      @socket = 0
      @include_filter = []
      @exclude_filter = []
      @def_roots = []
      @eclipse_version = ""
      @alias_filename = ""
      
      add_default(Proc.new{ |x| set_build_config_default(x) })
      
      add_option(Option.new("-m",true)                     { |x| set_main_dir(x)            })
      add_option(Option.new("-b",true)                     { |x| set_build_config(x)        })
      add_option(Option.new("-p",true)                     { |x| set_project(x); set_single })
      add_option(Option.new("-f",true)                     { |x| set_filename(x)            })
      add_option(Option.new("-c",false)                    {     set_clean                  })
      add_option(Option.new("-a",true)                     { |x| set_color(x)               })
      add_option(Option.new("-w",true)                     { |x| set_root(x)                })
      add_option(Option.new("-r",false)                    {     set_error                  })
      add_option(Option.new("--depfileInfo",false)         {     set_depfileInfo            })
      add_option(Option.new("--rebuild",false)             {     set_rebuild                })
      add_option(Option.new("--prepro",false)              {     set_prepro                 })
      add_option(Option.new("--link_only",false)           {     set_linkOnly               })
      add_option(Option.new("--no_autodir",false)          {     set_no_autodir             })
      
      add_option(Option.new("-v0",false)                   {     set_v(0)                   })
      add_option(Option.new("-v1",false)                   {     set_v(1)                   })
      add_option(Option.new("-v2",false)                   {     set_v(2)                   })
        
      add_option(Option.new("--clobber",false)             {     set_clobber                })
      add_option(Option.new("--ignore_cache",false)        {     set_nocache                })
      add_option(Option.new("--threads",true)              { |x| set_threads(x)             })
      add_option(Option.new("--socket",true)               { |x| set_socket(x)              })
      add_option(Option.new("--toolchain_info",true)       { |x| print_toolchain(x)         })
      add_option(Option.new("--toolchain_names",false)     {     print_toolchains           })
      add_option(Option.new("--include_filter",true)       { |x| set_include_filter(x)      })
      add_option(Option.new("--exclude_filter",true)       { |x| set_exclude_filter(x)      })
      add_option(Option.new("--show_abs_paths",false)      {     set_show_fullnames         })
      add_option(Option.new("--visualStudio",false)        {     set_visualStudio           })
      add_option(Option.new("-h",false)                    {     usage; ExitHelper.exit(0)  })
      add_option(Option.new("--help",false)                {     usage; ExitHelper.exit(0)  })
      add_option(Option.new("--show_include_paths",false)  {     set_show_inc               })
      add_option(Option.new("--eclipse_version",true)      { |x| set_eclipse_version(x)     })
      add_option(Option.new("--show_license",false)        {     show_license               })
      add_option(Option.new("--version",false)             {     ExitHelper.exit(0)         })
      add_option(Option.new("--check_uninc",false)         {     set_check_uninc            })
      add_option(Option.new("--alias",true)                { |x| set_alias_filename(x)      })

    end

    def usage
      puts "\nUsage: bake [options]"
      puts " [-b] <name>              Config name of main project"
      puts " -m <dir>                 Directory of main project (default is current directory)."
      puts " -p <dir>                 Project to build/clean (default is main project)"
      puts " -f <name>                Build/Clean this file only."
      puts " -c                       Clean the file/project."
      puts " -a <scheme>              Use ansi color sequences (console must support it). Possible values are 'white' and 'black'."
      puts " -v<level>                Verbose level from 0 to 2, whereas -v0 is less, -v1 is normal (default) and -v2 is more verbose."
      puts " -r                       Stop on first error."
      puts " -w <root>                Add a workspace root (can be used multiple times)."
      puts "                          If no root is specified, the parent directory of the main project is added automatically."
      puts " --rebuild                Clean before build."
      puts " --clobber                Clean the file/project (same as option -c) AND the bake cache files."
      puts " --prepro                 Stop after preprocessor."
      puts " --link_only              Only link executable - doesn't update objects and archives or start PreSteps and PostSteps"
      puts " --ignore_cache           Rereads the original meta files - usefull if workspace structure has been changed."
      puts " --check_uninc            Checks for unnecessary includes (only done for successful project builds)."
      puts " --threads <num>          Set NUMBER of parallel compiled files (default is 8)."
      puts " --socket <num>           Set SOCKET for sending errors, receiving commands, etc. - used by e.g. Eclipse."
      puts " --toolchain_info <name>  Prints default values of a toolchain."
      puts " --toolchain_names        Prints available toolchains."
      puts " --include_filter <name>  Includes steps with this filter name (can be used multiple times)."
      puts "                          'PRE' or 'POST' includes all PreSteps respectively PostSteps."
      puts " --exclude_filter <name>  Excludes steps with this filter name (can be used multiple times)."
      puts "                          'PRE' or 'POST' excludes all PreSteps respectively PostSteps."
      puts " --show_abs_paths         Compiler prints absolute filename paths instead of relative paths."
      puts " --no_autodir             Disable auto completion of paths like in IncludeDir"
      puts ""
      puts " --version                Print version."
      puts " -h, --help               Print this help."
      puts " --show_license           Print the license."      
          
    end
    
    def parse_options()
      parse_internal(false)
      set_main_dir(Dir.pwd) if @main_dir.nil?
      set_project(File.basename(@main_dir)) if @project.nil?
      @roots = @def_roots if @roots.length == 0
      Rake::application.max_parallel_tasks = @threads
      
      if @linkOnly
        if @rebuild
          Printer.printError "Error: --link_only and --rebuild not allowed at the same time" 
          ExitHelper.exit(1)
        end
        if @clean
          Printer.printError "Error: --link_only and -c not allowed at the same time" 
          ExitHelper.exit(1)
        end
      end
    end
    
    def check_valid_dir(dir)
     if not File.exists?(dir)
        Printer.printError "Error: Directory #{dir} does not exist"
        ExitHelper.exit(1)
      end
      if not File.directory?(dir)
        Printer.printError "Error: #{dir} is not a directory"
        ExitHelper.exit(1)
      end      
    end    

    def set_include_filter(x)
      @include_filter << x
    end

    def set_exclude_filter(x)
      @exclude_filter << x
    end
    
    def set_build_config_default(config)
      index = config.index('-')
      return false if (index != nil and index == 0) 
      set_build_config(config)
      return true
    end

    def set_build_config(config)
      if not @build_config.empty?
        Printer.printError "Error: Cannot set build config '#{config}', because build config is already set to '#{@build_config}'"
        ExitHelper.exit(1)
      end
      @build_config = config
    end
    
    def set_main_dir(dir)
      check_valid_dir(dir)
      @main_dir = File.expand_path(dir.gsub(/[\\]/,'/'))
      @def_roots = calc_def_roots(@main_dir)
    end
    
    def set_project(name)
      @project = name
    end
    
    def set_filename(filename)
      @filename = filename.gsub(/[\\]/,'/')
    end

    def set_single()
      @single = true
    end
    def set_clean()
      @clean = true
    end
    def set_clobber()
      @clobber = true
      set_clean
    end
    def set_rebuild()
      @clean = true
      @rebuild = true
    end
    def set_nocache()
      @nocache = true
    end
    def set_check_uninc()
      @check_uninc = true
    end
    def set_prepro()
      Rake::application.preproFlags = true
    end
    def set_linkOnly()
      @linkOnly = true
      set_single()
    end
    
    def set_no_autodir()
      @no_autodir = true
    end    

    def set_v(num)
      if num == 0
        @printLess = true
        @verbose = false
        Rake::application.options.silent = true
      elsif num == 1
        Rake::application.options.silent = false
        @printLess = false
        @verbose = false
      elsif num == 2
        Rake::application.options.silent = false
        @printLess = false
        @verbose = true
      end
    end
        
    def set_color(x)
      if (x != "black" and x != "white")
        Printer.printError "Error: color scheme must be 'black' or 'white'"
        ExitHelper.exit(1)
      end
      begin      
        ColorizingFormatter::setColorScheme(x.to_sym)
        @color = true
        ColorizingFormatter.enabled = true
      rescue Exception => e
        Printer.printError "Error: colored gem not installed (#{e.message})"
        puts e.backtrace if @verbose
        ExitHelper.exit(1)
      end
    end
        
    def set_error()
      Rake::Task.bail_on_first_error = true
    end
    
    def set_depfileInfo()
      Cxxproject::HasSources.print_additional_depfile_info = true
    end    
    
    def set_show_inc
      @show_includes = true
    end
    
    def set_show_fullnames
      Rake::application.consoleOutput_fullnames = true
    end    

    def set_visualStudio
      Rake::application.consoleOutput_visualStudio = true
    end
        
    def set_root(dir)
      check_valid_dir(dir)
      r = File.expand_path(dir.gsub(/[\\]/,'/'))
      @roots << r if not @roots.include?r
    end
        
    def set_threads(num)
      @threads = String === num ? num.to_i : num
      if @threads <= 0
        Printer.printError "Error: number of threads must be > 0"
        ExitHelper.exit(1)
      end
    end
    def set_socket(num)
      @socket = String === num ? num.to_i : num
    end

    def printHash(x, level)
      x.each do |k,v|
        if Hash === v
          if level > 0
            level.times {print "  "}
          else
            print "\n"
          end
          puts k
          printHash(v,level+1)
        elsif Array === v or String === v
          level.times {print "  "}
          puts "#{k} = #{v}"
        end
      end
    end

    def print_toolchain(x)
      tcs = Cxxproject::Toolchain::Provider[x]
      if tcs.nil?
        puts "Toolchain not available"
      else
        printHash(tcs, 0)
      end 
      ExitHelper.exit(0)
    end
    
    def print_toolchains()
      puts "Available toolchains:"
      Cxxproject::Toolchain::Provider.list.keys.each { |c| puts "* #{c}" }
      ExitHelper.exit(0)
    end
    
    def show_license()
      licenseFile = File.join(File.dirname(File.dirname(File.dirname(__FILE__))), "license.txt")
      file = File.new(licenseFile, "r")
      while (line = file.gets)
        puts "#{line}"
      end
      file.close
      ExitHelper.exit(0)
    end

    def set_eclipse_version(x)
      @eclipse_version = x
    end

    def set_alias_filename(x)
      @alias_filename = x
    end

  end

end


