require_relative '../../common/version'

module Bake

  class Usage

    def self.version
      Bake::Version.printBakeVersion
      ExitHelper.exit(0)
    end


    def self.show
      Bake::Version.printBakeVersion
      puts "\nUsage: bake [options]"
      puts " [-b] <name>              Config name of main project"
      puts " -m <dir>                 Directory of main project (default is current directory)."
      puts " -p <dir>                 Project to build/clean (default is main project)"
      puts " -f <name>                Build/Clean this file only."
      puts " -c                       Clean the file/project."
      puts " -a <scheme>              Use ansi color sequences (console must-- support it). Possible values are 'white' and 'black'."
      puts " -v<level>                Verbose level from 0 to 3, whereas -v0 is less, -v1 is normal (default) and -v2 and -v3 are more verbose."
      puts " -r                       Stop on first error."
      puts " -w <root>[,<depth>]      Add a workspace root (can be used multiple times). Additionally the search depth can be specified (>=0)."
      puts "                          If no root is specified, the parent directory of the main project is added automatically."
      puts " --list                   Lists all configs with a DefaultToolchain."
      puts " --rebuild                Clean before build."
      puts " --clobber                Clean the file/project (same as option -c) AND the bake cache files."
      puts " --prepro                 Stop after preprocessor."
      puts " --link-only              Only link executables - doesn't update objects and archives or start PreSteps and PostSteps."
      puts "                          Forces executables to be relinked."
      puts " --compile-only           Only the compile steps are executed, equivalent to -f '.'"
      puts " --no-case-check          Disables case-sensitivity-check of included header files (only relative paths on Windows are checked)."
      puts " --generate-doc           Builds docu instead of compiling sources."
      puts " --ignore-cache           Rereads the original meta files - usefull if workspace structure has been changed."
      puts " -j <num>                 Set NUMBER of parallel compiled files (default is 8)."
      puts " -O                       The output will be synchronized per configuration. Note, this delays output."
      puts " -D <define>              Adds this define to the compiler commands"
      puts " --socket <num>           Set SOCKET for sending errors, receiving commands, etc. - used by e.g. Eclipse."
      puts " --toolchain-info <name>  Prints default values of a toolchain."
      puts " --toolchain-names        Prints available toolchains."
      puts " --dot <filename>         Creates a .dot file of the config dependencies."
      puts " --do <name>[=<arg>]      Includes elements with this filter name (can be used multiple times)."
      puts "                          Optional arguments which can be accessed in Project.meta via $(FilterArguments, <name>)."
      puts "                          'PRE', 'POST', 'STARTUP', 'EXIT' or 'CLEAN' includes all according steps."
      puts " --omit <name>            Excludes elements with this filter name (can be used multiple times)."
      puts "                          'PRE', 'POST', 'STARTUP', 'EXIT' or 'CLEAN' excludes all according steps."
      puts " --abs-paths              Compiler prints absolute filename paths instead of relative paths."
      puts " --Wparse                 The error parser result is also taken into account, not only the return value of compiler, archiver and linker."
      puts " --no-autodir             Disable auto completion of paths like in IncludeDir"
      puts " --set <key>=<value>      Sets a variable. Overwrites variables defined in Project.metas (can be used multiple times)."
      puts " --adapt <name>           Specifies an adapt project to manipulate the configs (can be used multiple times, or --adapt <name1,name2,...>)"
      puts " --incs-and-defs=json     Prints includes and defines of all projects in json format"
      puts " --incs-and-defs=bake     Used by IDEs plugins"
      puts " --conversion-info        Prints infos for an external tool which converts bake configs for other build systems"
      puts " --file-list              Writes all sources and headers used by a SINGLE config into '<config output folder>/file-list.txt'."
      puts "                          Writes all sources and headers used by ALL configs into '<main config output folder/global-file-list.txt'."
      puts " --prebuild               Does not build configs which are marked as 'prebuild', this feature is used for distributions."
      puts " --compilation-db [<fn>]  Writes compilation information into filename fn in json format, default for fn is compile_commands.json"
      puts " --create exe|lib|custom  Creates a project with exe, lib or custom template"
      puts " --nb                     Suppresses the lines \"**** Building x of y: name (config) ****"
      puts " --crc32 <string>         Calulates the CRC32 of string (0x4C11DB7, init 0, final xor 0, input and result not reflected), used for Uid variable calculation"
      puts " --diab-case-check        When compiling with DCC, this switches to the case check on Windows machines. No actual compilation is done."
      puts " --file-cmd               Writes arguments into a file and hands it over the compiler/archiver/linker. Works only for supported compilers."
      puts " --merge-inc              Merges includes together, so the compiler gets only one include directory (applies to all configs which mergeInc attribute is not set)."
      puts " --merge-inc-main         Same as --merge-inc, but does the merge only for the main project."
      puts " --link-beta              Improved linking, order of libs changed. Experimental."
      puts " --build_                 DEPRECATED: build directories will be build_<name> instead of build/<name>"
      puts " --version                Print version."
      puts " --time                   Print elapsed time at the end."
      puts " --doc                    Open documentation in browser"
      puts " --dry                    No changes to the file system, no external processes like the compiler are called."
      puts "                          Exceptions: some special command line options like --create or --dot and 'cmd's of 'Set's."
      puts " --install-doc            If installed, --doc opens the offline docu, otherwise it's online. You may need super user rights to enhance the bake-toolkit installation."
      puts " -h, --help               Print this help."
      puts " --license                Print the license."
      puts " --debug                  Print out backtraces in some cases - used only for debugging bake."
      puts " --debug-threads          Print some debug information about started and stopped threads."
      ExitHelper.exit(0)
    end

  end

end