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
      puts " --list                   Lists all configs with a DefaultToolchain."
      puts " --rebuild                Clean before build."
      puts " --clobber                Clean the file/project (same as option -c) AND the bake cache files."
      puts " --prepro                 Stop after preprocessor."
      puts " --link-only              Only link executables - doesn't update objects and archives or start PreSteps and PostSteps."
      puts "                          Forces executables to be relinked."
      puts " --generate-doc           Builds docu instead of compiling sources."
      puts " --lint                   Performs Lint checks instead of compiling sources."
      puts " --lint-min <num>         If number of files in a project is too large for lint to handle, it is possible"
      puts "                          to specify only a part of the file list to lint (default -1)."
      puts " --lint-max <num>         See above (default -1)."
      puts " --ignore-cache           Rereads the original meta files - usefull if workspace structure has been changed."
      puts " --threads <num>          Set NUMBER of parallel compiled files (default is 8)."
      puts " --socket <num>           Set SOCKET for sending errors, receiving commands, etc. - used by e.g. Eclipse."
      puts " --toolchain-info <name>  Prints default values of a toolchain."
      puts " --toolchain-names        Prints available toolchains."
      puts " --do <name>              Includes steps with this filter name (can be used multiple times)."
      puts "                          'PRE', 'POST', 'STARTUP' or 'EXIT' includes all according steps."
      puts " --omit <name>            Excludes steps with this filter name (can be used multiple times)."
      puts "                          'PRE', 'POST', 'STARTUP' or 'EXIT' excludes all according steps."
      puts " --abs-paths              Compiler prints absolute filename paths instead of relative paths."
      puts " --no-autodir             Disable auto completion of paths like in IncludeDir"
      puts " --set <key>=<value>      Sets a variable. Overwrites variables defined in Project.metas (can be used multiple times)."
      puts " --adapt <name>           Specifies an adapt project to manipulate the configs (can be used multiple times)"
      puts " --incs-and-defs          Used by IDEs plugins"
      puts " --conversion-info        Prints infos for an external tool which converts bake configs for other build systems"
      puts " --bundle <dir>           Bundles the output (experimental, description will follow)"
      puts " --writeCC2J <name>       Writes compiler command into a json file (experimental!)"
      puts " --create exe|lib|custom  Creates a project with exe, lib or custom template"
      puts ""
      puts " --version                Print version."
      puts " --doc                    Open documentation in browser"
      puts " -h, --help               Print this help."
      puts " --license                Print the license."
      puts ""
      puts " --debug                  Print out backtraces in some cases - used only for debugging bake."      
      ExitHelper.exit(0)      
    end

  end

end