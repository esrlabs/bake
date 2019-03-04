require_relative '../toolchain/colorizing_formatter'
require_relative '../../common/options/parser'
require_relative '../options/showToolchains'
require_relative '../options/showLicense'
require_relative '../options/showDoc'
require_relative '../options/usage'
require_relative '../options/create'
require_relative '../../common/options/finder'
require_relative '../../common/root'
require_relative '../../common/crc32'

module Bake

  def self.options
    @@options
  end
  def self.options=(options)
    @@options = options
  end

  class Options < Parser
    attr_accessor :build_config, :nocache, :analyze, :eclipseOrder, :envToolchain, :showConfigs
    attr_reader :main_dir, :project, :filename, :main_project_name, :buildDirDelimiter, :dot, :cc2j_filename # String
    attr_reader :include_filter, :exclude_filter, :adapt # String List
    attr_reader :conversion_info, :stopOnFirstError, :clean, :rebuild, :show_includes, :show_includes_and_defines, :projectPaths, :qac, :dry, :syncedOutput, :debug_threads, :skipBuildingLine # Boolean
    attr_reader :linkOnly, :compileOnly, :no_autodir, :clobber, :docu, :debug, :prepro, :prebuild, :printTime, :json, :wparse, :caseSensitivityCheck, :fileCmd, :mergeInc, :mergeIncMain # Boolean
    attr_reader :threads, :socket # Fixnum
    attr_reader :vars, :include_filter_args # map
    attr_reader :verbose
    attr_reader :filelist # set
    attr_reader :consoleOutput_fullnames
    attr_reader :roots # Root array
    attr_reader :diabCaseCheck
    attr_reader :defines


    def initialize(argv)
      super(argv)

      @caseSensitivityCheck = Bake::Utils::OS.windows?
      @skipBuildingLine = false
      @debug_threads = false
      @dry = false
      @filelist = nil
      @qac = false
      @projectPaths = false
      @wparse = false
      @dot = nil
      @prebuild = false
      @printTime = false
      @buildDirDelimiter = "/"
      @conversion_info = false
      @envToolchain = false
      @analyze = false
      @eclipseOrder = false
      @showConfigs = false
      @consoleOutput_fullnames = false
      @prepro = false
      @stopOnFirstError = false
      @verbose = 1
      @vars = {}
      @build_config = ""
      @main_dir = nil
      @project = nil
      @filename = nil
      @cc2j_filename = nil
      @json = false
      @clean = false
      @clobber = false
      @docu = false
      @debug = false
      @rebuild = false
      @nocache = false
      @show_includes = false
      @show_includes_and_defines = false
      @linkOnly = false
      @compileOnly = false
      @no_autodir = false
      @threads = 8
      @roots = []
      @socket = 0
      @include_filter = []
      @include_filter_args = {}
      @exclude_filter = []
      @main_project_name = ""
      @adapt = []
      @syncedOutput = false
      @diabCaseCheck = false
      @defines = []
      @fileCmd = false
      @mergeInc = false
      @mergeIncMain = false

      add_option(["-b",                   ""                     ], lambda { |x| set_build_config(x)                     })
      add_option(["-m"                                           ], lambda { |x| @main_dir = x                           })
      add_option(["-p"                                           ], lambda { |x| @project = x                            })
      add_option(["-f"                                           ], lambda { |x| @filename = x.gsub(/[\\]/,'/')          })
      add_option(["-c"                                           ], lambda {     @clean = true                           })
      add_option(["-a"                                           ], lambda { |x| Bake.formatter.setColorScheme(x.to_sym) })
      add_option(["-w"                                           ], lambda { |x| set_root(x)                             })
      add_option(["-r"                                           ], lambda {     @stopOnFirstError = true                })
      add_option(["-O"                                           ], lambda {     @syncedOutput = true                    })
      add_option(["--rebuild"                                    ], lambda {     @rebuild = true                         })
      add_option(["--prepro"                                     ], lambda {     @prepro = true                          })
      add_option(["--link-only",          "--link_only"          ], lambda {     @linkOnly = true;                       })
      add_option(["--compile-only",       "--compile_only"       ], lambda {     @compileOnly = true;                    })
      add_option(["--no-autodir",         "--no_autodir"         ], lambda {     @no_autodir = true                      })

      add_option(["--create"                                     ], lambda { |x| Bake::Create.proj(x)                    })
      add_option(["--conversion-info",    "--conversion_info"    ], lambda {     @conversion_info = true                 })
      add_option(["--file-list",          "--file_list"          ], lambda {     @filelist = Set.new                     })
      add_option(["--filter-paths"                               ], lambda {     @projectPaths = true                    })
      add_option(["--qac"                                        ], lambda {     @qac = true                             })

      add_option(["--generate-doc",       "--docu"               ], lambda {     @docu = true                            })

      add_option(["--adapt"                                      ], lambda { |x| set_adapt(x)                            })

      add_option(["-v"                                           ], lambda { |x, dummy1, dummy2| set_verbose(x)          })

      add_option(["--debug"                                      ], lambda {     @debug = true                           })
      add_option(["--debug-threads"                              ], lambda {     @debug_threads = true                   })
      add_option(["--set"                                        ], lambda { |x| set_set(x)                              })
      add_option(["-nb"                                          ], lambda {     @skipBuildingLine = true                })
      add_option(["--no-case-check"                              ], lambda {     @caseSensitivityCheck = false           })
      add_option(["--file-cmd"                                   ], lambda {     @fileCmd = true                         })
      add_option(["--merge-inc"                                  ], lambda {     @mergeInc = true                        })
      add_option(["--merge-inc-main"                             ], lambda {     @mergeIncMain = true                    })
      add_option(["--clobber"                                    ], lambda {     @clobber = true; @clean = true          })
      add_option(["--ignore-cache",       "--ignore_cache"       ], lambda {     @nocache = true                         })
      add_option(["-j",                   "--threads"            ], lambda { |x, dummy1, dummy2| set_threads(x)          })
      add_option(["--socket"                                     ], lambda { |x| @socket = String === x ? x.to_i : x     })
      add_option(["--toolchain-info",     "--toolchain_info"     ], lambda { |x| ToolchainInfo.showToolchain(x)          })
      add_option(["--toolchain-names",    "--toolchain_names"    ], lambda {     ToolchainInfo.showToolchainList         })
      add_option(["--dot",                                       ], lambda { |x| @dot = x                                })
      add_option(["--do",                 "--include_filter"     ], lambda { |x| set_filter(x)                           })
      add_option(["--omit",               "--exclude_filter"     ], lambda { |x| @exclude_filter << x                    })
      add_option(["--abs-paths",          "--show_abs_paths"     ], lambda {     @consoleOutput_fullnames = true         })
      add_option(["--prebuild"                                   ], lambda {     @prebuild = true                        })
      add_option(["--Wparse"                                     ], lambda {     @wparse = true                          })

      add_option(["-h",                   "--help"               ], lambda {     Bake::Usage.show                        })
      add_option(["--time",                                      ], lambda {     @printTime = true                       })

      add_option(["--incs-and-defs",      "--show_incs_and_defs" ], lambda {     @show_includes_and_defines = true       })
      add_option(["--incs-and-defs=bake",                        ], lambda {     @show_includes_and_defines = true       })
      add_option(["--incs-and-defs=json"                         ], lambda { @show_includes_and_defines=true; @json=true })
      add_option(["--license",            "--show_license"       ], lambda {     License.show                            })
      add_option(["--doc",                "--show_doc"           ], lambda {     Doc.show                                })
      add_option(["--install-doc",        "--install_doc"        ], lambda {     Doc.install                             })

      add_option(["-D"                                           ], lambda { |x| @defines << x                           })

      add_option(["--dry"                                        ], lambda {     @dry = true                             })

      add_option(["--crc32"                                      ], lambda { |x| CRC32.printAndExit(x)                   })

      add_option(["--diab-case-check"                            ], lambda {  @diabCaseCheck = true; @compileOnly = true })

      add_option(["--version"                                    ], lambda {     Bake::Usage.version                     })
      add_option(["--list",               "--show_configs"       ], lambda {     @showConfigs = true                     })
      add_option(["--compilation-db"                             ], lambda { |x,dummy| @cc2j_filename = (x ? x : "compile_commands.json" )})
      add_option(["--build_",                                    ], lambda {     @buildDirDelimiter = "_"                })

      # deprecated and not replaced by new command
      add_option(["--show_include_paths"                         ], lambda {     @show_includes = true                   })

    end

    def parse_options()
      parse_internal(false)

      searchDir = @main_dir.nil? ? Dir.pwd : @main_dir
      dir = Bake.findDirOfFileToRoot(searchDir,"Project.meta")
      if dir
        set_main_dir(dir)
      else
        Bake.formatter.printError("Error: Project.meta not found in #{searchDir} or upwards")
        ExitHelper.exit(1)
      end

      def_roots = Root.calc_roots_bake(@main_dir)
      @roots += def_roots

      if @roots.empty?
        @roots = []
        @roots = Root.calc_def_roots(@main_dir)
      end

      @roots = Root.uniq(@roots)

      @adapt.uniq!

      if @project
        ar = @project.split(",")
        if ar.length > 2
          Bake.formatter.printError("Error: only one comma allowed for -p")
          ExitHelper.exit(1)
        end
        ar[0] = File::basename(Dir.pwd) if ar[0] == "."
        @project = ar.join(",")
      end

      if @conversion_info
        if @rebuild
          Bake.formatter.printError("Error: --conversion-info and --rebuild not allowed at the same time")
          ExitHelper.exit(1)
        end
        if @clean
          Bake.formatter.printError("Error: --conversion-info and -c not allowed at the same time")
          ExitHelper.exit(1)
        end
        if @prepro
          Bake.formatter.printError("Error: --conversion-info and --prepro not allowed at the same time")
          ExitHelper.exit(1)
        end
        if @linkOnly
          Bake.formatter.printError("Error: --conversion-info and --linkOnly not allowed at the same time")
          ExitHelper.exit(1)
        end
        if @compileOnly
          Bake.formatter.printError("Error: --conversion-info and --compileOnly not allowed at the same time")
          ExitHelper.exit(1)
        end
        if @docu
          Bake.formatter.printError("Error: --conversion-info and --docu not allowed at the same time")
          ExitHelper.exit(1)
        end
      end

      if @linkOnly
        if @rebuild
          Bake.formatter.printError("Error: --link-only and --rebuild not allowed at the same time")
          ExitHelper.exit(1)
        end
        if @clean
          Bake.formatter.printError("Error: --link-only and -c not allowed at the same time")
          ExitHelper.exit(1)
        end
        if @prepro
          Bake.formatter.printError("Error: --link-only and --prepro not allowed at the same time")
          ExitHelper.exit(1)
        end
        if @filename
          Bake.formatter.printError("Error: --link-only and --filename not allowed at the same time")
          ExitHelper.exit(1)
        end
      end

      if @compileOnly
        if @linkOnly
          Bake.formatter.printError("Error: --compile-only and --link-only not allowed at the same time")
          ExitHelper.exit(1)
        end
        if @filename
          Bake.formatter.printError("Error: --compile-only and --filename not allowed at the same time")
          ExitHelper.exit(1)
        end
      end

      if @prepro
        if @rebuild
          Bake.formatter.printError("Error: --prepro and --rebuild not allowed at the same time")
          ExitHelper.exit(1)
        end
        if @clean
          Bake.formatter.printError("Error: --prepro and -c not allowed at the same time")
          ExitHelper.exit(1)
        end
      end

      if @caseSensitivityCheck == false && @diabCaseCheck == true
        Bake.formatter.printError("Error: --no-case-check and --diab-case-check not allowed at the same time")
        ExitHelper.exit(1)
      end

      @filename = "." if @compileOnly

    end

    def check_valid_dir(dir)
     if not File.exists?(dir)
        Bake.formatter.printError("Error: Directory #{dir} does not exist")
        ExitHelper.exit(1)
      end
      if not File.directory?(dir)
        Bake.formatter.printError("Error: #{dir} is not a directory")
        ExitHelper.exit(1)
      end
    end

    def set_build_config(config)
      if not @build_config.empty?
        Bake.formatter.printError("Error: Cannot set build config '#{config}', because build config is already set to '#{@build_config}'")
        ExitHelper.exit(1)
      end
      @build_config = config
    end

    def set_main_dir(dir)
      check_valid_dir(dir)
      @main_dir = File.expand_path(dir.gsub(/[\\]/,'/'))
      @main_project_name = File::basename(@main_dir)
    end

    def set_root(dir)
      root = Root.extract_depth(dir)
      check_valid_dir(root.dir)
      root.dir  = File.expand_path(root.dir.gsub(/[\\]/,'/'))
      @roots << root
    end

    def set_adapt(name)
      name.split(",").each do |n|
        @adapt << n if not @adapt.include?n
      end
    end

    def checkNum(num)
      if String === num && !/\A\d+\z/.match(num)
        Bake.formatter.printError("Error: #{num} is not a positive number")
        ExitHelper.exit(1)
      end
    end

    def set_threads(num)
      checkNum(num)
      @threads = String === num ? num.to_i : num
      if @threads <= 0
        Bake.formatter.printError("Error: number of threads must be > 0")
        ExitHelper.exit(1)
      end
    end

    def set_verbose(num)
      checkNum(num)
      @verbose = String === num ? num.to_i : num
      if @verbose < 0 || verbose > 3
        Bake.formatter.printError("Error: verbose must be between 0 and 3")
        ExitHelper.exit(1)
      end
    end

    def set_set(str)
      ar = str.split("=")
      if not str.include?"=" or ar[0].length == 0
        Bake.formatter.printError("Error: --set must be followed by key=value")
        ExitHelper.exit(1)
      end
      @vars[ar[0]] = ar[1..-1].join("=")
    end

    def set_filter(f)
      splitted = f.split("=", 2)
      @include_filter << splitted[0]
      @include_filter_args[splitted[0]] = splitted[1] if splitted.length == 2
    end

  end

end


