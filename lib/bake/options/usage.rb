module Bake

  class Usage
  
    def self.show
      puts "\nUsage: bake [options]"
      puts " [-b] <name>              Config name of main project"
      puts " -m <dir>                 Directory of main project (default is current directory)."
      puts " -p <dir>                 Project to build/clean (default is main project)"
      puts " -f <name>                Build/Clean this file only."
      puts " -c                       Clean the file/project."
      puts " -a <scheme>              Use ansi color sequences (console must support it). Possible values are 'white' and 'black'."
      puts " -v<level>                Verbose level from 0 to 3, whereas -v0 is less, -v1 is normal (default) and -v2 and -v3 are more verbose."
      puts " -r                       Stop on first error."
      puts " -w <root>                Add a workspace root (can be used multiple times)."
      puts "                          If no root is specified, the parent directory of the main project is added automatically."
      puts " --show_configs           Shows all configs with DefaultToolchain."
      puts " --rebuild                Clean before build."
      puts " --clobber                Clean the file/project (same as option -c) AND the bake cache files."
      puts " --prepro                 Stop after preprocessor."
      puts " --link_only              Only link executables - doesn't update objects and archives or start PreSteps and PostSteps."
      puts "                          Forces executables to be relinked."
      puts " --docu                   Builds docu instead of compiling sources."
      puts " --lint                   Performs Lint checks instead of compiling sources."
      puts " --lint_min <num>         If number of files in a project is too large for lint to handle, it is possible"
      puts "                          to specify only a part of the file list to lint (default -1)."
      puts " --lint_max <num>         See above (default -1)."
      puts " --ignore_cache           Rereads the original meta files - usefull if workspace structure has been changed."
      puts " --threads <num>          Set NUMBER of parallel compiled files (default is 8)."
      puts " --socket <num>           Set SOCKET for sending errors, receiving commands, etc. - used by e.g. Eclipse."
      puts " --toolchain_info <name>  Prints default values of a toolchain."
      puts " --toolchain_names        Prints available toolchains."
      puts " --include_filter <name>  Includes steps with this filter name (can be used multiple times)."
      puts "                          'PRE', 'POST', 'STARTUP' or 'EXIT' includes all according steps."
      puts " --exclude_filter <name>  Excludes steps with this filter name (can be used multiple times)."
      puts "                          'PRE', 'POST', 'STARTUP' or 'EXIT' excludes all according steps."
      puts " --show_abs_paths         Compiler prints absolute filename paths instead of relative paths."
      puts " --no_autodir             Disable auto completion of paths like in IncludeDir"
      puts " --set <key>=<value>      Sets a variable. Overwrites variables defined in Project.metas (can be used multiple times)."
      puts " --show_include_paths     Used by IDEs plugins"
      puts " --show_incs_and_defs     Used by IDEs plugins"
      puts " --conversion_info        Prints infos for an external tool which converts bake configs for other build systems"
      puts " --writeCC2J <name>       Writes compiler command into a json file (experimental!)"
      puts " --create exe|lib|custom  Creates a project with exe, lib or custom template"
      puts ""
      puts " --version                Print version."
      puts " --doc                    Open documentation in browser"
      puts " -h, --help               Print this help."
      puts " --show_license           Print the license."
      puts ""
      puts " --debug                  Print out backtraces in some cases - used only for debugging bake."      
      ExitHelper.exit(0)      
    end

  end

end