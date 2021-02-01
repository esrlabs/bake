Changelog
=========

January XXXXX, 2021 - bake-toolkit 2.68.0
    * Enhance **--abs-paths** so it affects not only error messages but also sources, objects, includes, library and executable names.
    * Switch theme of documentation from Bootstrap to ReadTheDocs.

January 7, 2021 - bake-toolkit 2.67.0
    * Add variable *$(OriginalDir)*, which points to the directory of the containing meta file. Useful for relative paths from Adapt files.
    * Add *outputDirPostfix* to (Default)Toolchain. It can be used for special builds like MISRA checkers.
    * Add *ExcludeDir* to bakery. Up to now it was only possible to exclude by project name (with wildcards), but not complete folder trees.
    * Add robustness measure: now every dependency from bake to other gems is specified with hardcoded version on installation time and runtime.

October 23, 2020 - bake-toolkit 2.66
    * Bugfix: --list failed when Project.meta contains an Adapt
    * Bugfix: circular extension of projects not detected during load
    * Changed: llvm-lib is now used to archive when using Clang on Windows
    * Added: Automatic path completion for Makefile command, e.g.

      .. code-block:: console

          Makefile "someProject/Makefile", target: all, lib: "someProject/output/libresult.a"

September 18, 2020 - bake-toolkit 2.65.2
    * Bugfix: if pathname length of dependency file is > 255 on Windows, the compilation check might break.
    * Added: now Adapts can be also filtered
    * Cosmetic: replaced mouse-over-javascripts in syntax pages of the documentation by static texts.

September 7, 2020 - bake-toolkit 2.65.1
    * Bugfix: __THIS__ in Project.meta was resolved to main project name, not local project name
    * Bugfix: Fixed an exception with old Ruby versions where "fiddle" is not available

August 26, 2020 - bake-toolkit 2.65.0
    * Bugfix: Dependency to gem thwait 0.1.0 instead of latest version (they messed it up, latest gem might abort the builds on some systems)
    * Bugfix: Skip CompilationCheck on dry run
    * Added: CLANG_BITCODE toolchain

July 28, 2020 - bake-toolkit 2.64.4
    * Bugfix: Fixed the check in 2.64.3.

July 28, 2020 - bake-toolkit 2.64.3
    * Bugfix: Algorithm for CompilationCheck had quadratic instead of linear complexity.

July 24, 2020 - bake-toolkit 2.64.2
    * Added: experimental dev-feature "retry-linking" (not for public use)

July 24, 2020 - bake-toolkit 2.64.1
    * Bugfix: CompilationCheck did not work correctly in special configurations, e.g. LibraryConfig without files

July 22, 2020 - bake-toolkit 2.64.0
    * Added: CompilationCheck to check for included/excluded files in a build
    * Cosmetic: Internally using fiddle instead of Win32Api (getting rid of deprecated warning when starting bake)

June 22, 2020 - bake-toolkit 2.63.2
    * Changed: bake does not abort anymore if cache files cannot be written.

June 17, 2020 - bake-toolkit 2.63.1
    * Changed: "-Z dep-overview=<json>" exits now after writing the information into the json file.
    * Added: Warning in bakery if referenced projects or configs cannot be found.

June 10, 2020 - bake-toolkit 2.63.0
    * Bugfix: bake did not wait for a non-indepenent step (e.g. a generator) if it can be reached via multiple ways in the dependency hierarchy.
    * Added: Internal developer feature "-Z dep-overview=<json>" for intelligent CIs.
    * Added: Forbid include dirs with a leading space, e.g. *IncludeDir " include"*.
    * Added: An info is printed out if path magic is used in IncludeDir.
    * Added: Files have an optional attribute "linkDirectly", which means they are not archived in a lib, but linked directly to the executable.

May 14, 2020 - bake-toolkit 2.62.0
     * Added: bake now understands dependency files from Axivion, which makes incremental build possible.

May 4, 2020 - bake-toolkit 2.61.0
     * Added: possibility to specify additional root files with -w (they doesn't need to be called roots.bake).
       There are different use cases for this, e.g. having a Collection.meta outside the workspace.
     * Added: Variable *$(WorkingDir)* which points to the directory from which bake was called.
     * Added: *CompilationDB <file>* as option for main configs to generate compilation database. "--compilation-db" from command line will overrule this.

       .. code-block:: console

           ExecutableConfig Release {
             CompilationDB "$(ProjectDir)/compile_commands.json"
           }
     * Bugfix: build config could not be set after -j without number, e.g. "bake -j UnitTestBase"
     * Added: additional folder name case check on Windows (similar to the one from 2.60.2 but it covers other use cases)
     * Added: *Adapt scope* feature now also takes scopes from main config into account, not only from the to-be-adapted config.

March 25, 2020 - bake-toolkit 2.60.2
     * Added: a warning is printed if two folders differ only in letter case either on file system or due to (Windows) shell issues. Example:

March 20, 2020 - bake-toolkit 2.60.1 (not officially released)
     * Changed: dependencies are now injected to other injected dependencies. This should solve some bugs, hopefully it does not introduce other problems.

March 17, 2020 - bake-toolkit 2.60.0
     * Bugfix: the build order of configs were wrong when injecting dependencies.
       If e.g. a dependency to a generator was injected to a library, it could happen that the library was built before the generator was executed.

March 6, 2020 - bake-toolkit 2.59.0
     * Partly reverted changes introduced in 2.57.0. New behaviour:
       "Files" specific Flags/Defines are still first-is-best, but if Flags/Defines are specified for a single file it overrules previous definitions.

March 4, 2020 - bake-toolkit 2.58.0
     * Added: -j without number means that bake is using as many threads as cores are available.
     * Cosmetic: Added a warning if in Project.meta Flags/Defines are specified for a single file but ignored due to a previous definition.

       .. code-block:: console

           Files "src/*.cpp" # has higher priority (in this case *.cpp shall be have no additional flags/defines)
           Files "src/main.cpp" {
             Flags "-abc"    # ignored, overruled by file pattern above --> warning
           }

February 20, 2020 - bake-toolkit 2.57.0
     * Bugfix: if a file is explicitly defined in Project.meta, the flags/defines must not be overwritten even if flags/defines were defined later via a file pattern.

       .. code-block:: console

           Files "src/main.cpp" # must not be complied with "-abc"
           Files "src/*.cpp" {
             Flags "-abc"
           }

     * Added: support for Ruby 2.7.x.

January 20, 2020 - bake-toolkit 2.56.0
     * Added: new cmd argument --lines <start_line>:<end_line> for bake-format tool which tells to format lines only in range between start and end lines.
     * Added: new bake-rtext-service cmd tool, which runs the RText language protocol server and can be used by the IDE to provide the syntax highlighting, auto completion, errors annotation and model navigation.
     * Bugfix: Removed debug output for compilation-db, accidentally added with 2.53.
     * Bugfix: fixed an exception using scopes for adapts.

November 27, 2019 - bake-toolkit 2.55.1
     * Bugfix: If a project is directly in the workspace root, it could not be referenced in Collection.meta.

November 21, 2019 - bake-toolkit 2.55.0
     * Added: default number of compiling threads is now equal to the number of logical processors instead of hardcoded 8 (only for Ruby >= 2.2).
     * Added: possibility to overwrite bake internal defaults for toolchain commands and flags
     * Bugfix: "remove" attribute of "Flags" now correctly supports regex

November 4, 2019 - bake-toolkit 2.54.3
     * Added: Folders in roots.bake can end with "/" now.
     * Added: Improved Tasking error parser.
     * Added: .gitignore files are created if not existing in ".bake" and build folders.
     * Added: Developer feature "enforce-executable-config" added which converts a main LibraryConfig to ExecutableConfig on-the-fly.

October 16, 2019 - bake-toolkit 2.54.2
     * Added: Developer feature no-error-parser.
     * Added: "toolchain" in metadata.
     * Fixed: Variables now resolved in metadata.
     * Fixed: File specific toolchain handling was broken in 2.54.1.
     * Changed: ArtifactExtension can be used to extend ArtifactName.

October 14, 2019 - bake-toolkit 2.54.1
    * Reverted: The change from 2.54: "(Windows only) If a case mismatch is detected between Files definition in Project.meta and filesystem, the compilation will be aborted."
    * Added: Instead, the correct flags and defines will be used when specified at "Files" level in Project.meta. They will not be discarded anymore on case mismatch.

October 11, 2019 - bake-toolkit 2.54
    * Added: ArtifactExtension in Project.meta to configure the filename extension of the artifacts.
    * Added: Internal developer feature "-Z metadata=<json>" for MISRA tooling
    * Changed: Duplicate flags will not be removed anymore (use cases exist where they're needed)
    * Bugfix: (Windows only) If a case mismatch is detected between Files definition in Project.meta and filesystem, the compilation will be aborted.
    * Added: The filename for --dot can be omitted, default is <main config name>.dot in main project dir.
    * Added: --dot-project-level to write project-level-dependencies in dot files insted of config-level.
    * Changed: The modules in dot files now have full path for better post processing (the labels stay the same).

July 26, 2019 - bake-toolkit 2.53
    * Bugfix: bakery regex did not take comments into account when parsing Project.meta.
    * Added: "strict" attribute to match only the specified Adapt config type.
    * Added: Option to enforce a variable to be set. If variable is unset, an error will be reported.
    * Changed: using "libtool" and "-static -o" instead of "ar" and "r" for Clang on Mac.
    * Changed: ``"`` will be escaped to ``\\\"`` in compile_commands.json.

July 23, 2019 - bake-toolkit 2.52.1
    * Bugfix: --prebuild feature did not work well with -c/--rebuild in combination with -r.

July 22, 2019 - bake-toolkit 2.52.0
    * Added: "Scope" as additional adapt conditions.
    * Added: all conditions like "toolchain" support list format, e.g. "GCC;CLANG".
    * Added: "compileOnly" annotation for "Files" which means that they shall be compiled, but not archived or linked (experimental feature, might be changed in future).
    * Added: improved GCC compiler error parser.
    * Cosmetic: when enforcing local paths e.g. for outputDir, "./" will be removed for nicer output.

March 25, 2019 - bake-toolkit 2.51.2
    * Added: --dotc creates the dot graph AND compiles the projects as usual (in comparison to --dot).

March 21, 2019 - bake-toolkit 2.51.1
    * Bugfix: under certain cases the same Adapt.meta could be found twice which results into a warning.
    * Changed: if a cmd of a Set (variable) returns with !=0, the output of cmd is now printed out to get an idea why it has failed.

March 13, 2019 - bake-toolkit 2.51.0
    * Changed: refactored calculating include folders. Now it's much faster than before! However, the order of include folders may have changed for ambiguous configurations.
    * Changed: merge-include feature refactored after getting some feedback.

February 7, 2019 - bake-toolkit 2.50.0
    * Added: command line option "--merge-inc" which copies all include files into one temprary folder and invokes the compiler with just one include path.
    * Added: command line option "--file-cmd" which writes all command line arguments into a file and hands it over to the compiler (with "@" in gcc and dcc).
    * Added: "adapt" supports now lists of projects/configs (additionally to wildcards), separated with ";".
    * Added: added Cuda support for GCC toolchain (experimental)

January 23, 2019 - bake-toolkit 2.49.0
    * Added: Support for IAR compiler.

November 28, 2018 - bake-toolkit 2.48.3
    * Bugfix: Removed accidentally added debug output which was introduced in 2.48.2.

November 8, 2018 - bake-toolkit 2.48.2
    * Bugfix: Now compatible with new QAC folder structure (problem was that user-suppressed warnings in qac.cct were not suppressed).

September 20, 2018 - bake-toolkit 2.48.1
    * Bugfix: Compiler prefix change reverted for C and CPP, only assembler still has the new ASMCompilerPrefix.

September 7, 2018 - bake-toolkit 2.48.0
    * Bugfix: Variables can be set to an empty string now
    * Added: Compiler prefix mechanism improved, see documentation

July 31, 2018 - bake-toolkit 2.47.1
    * Bugfix: in same cases the OutputDir variables were not substituted correctly in 2.47.0.

July 27, 2018 - bake-toolkit 2.47.0
    * Added: *Sleep*, *MakeDir*, *Remove*, *Copy* and *Move* commands in Project.meta.
    * Added: option -D to add defines via command line.
    * Added: DCC case check with --diab-case-check for Windows. Makes sense to start the compilation again after full build was successful with this parameter.
      With this parameter the code is not compiled, only checked. It takes around the time of a compilation. Note, with GCC the check is done during compilation in
      "no time" - enhancement request ticked filed at Windriver to make that possible with Diab.
    * Improved: Cyclic variable substitution
    * Removed: support of Visual Studio (not Visual Studio Code)
    * Removed: official support of Ruby 1.9
    * Bugfix: MapFile command now working for GCC
    * Bugfix: --incs-and-defs did not show any results in case the workspace was broken like a missing library.

May 18, 2018 - bake-toolkit 2.46.0
    * Added: Makefile command has new attribute **noClean**. If set to true, the target *clean* will not be executed when project is cleaned. Default: false.
    * Added: Makefile command has new attribute **changeWorkingDir**. If set to false, bake stays in project's directory instead of changing into makefile's directory. Default: true.
    * Added: Before executing the makefile, bake sets the environment variables $(BAKE_XX_COMMAND) and $(BAKE_XX_FLAGS), whereas XX is one of CPP, C, ASM, AR or LD.

May 4, 2018 - bake-toolkit 2.45.0
    * Changed: it is possible now to specify adapt files directly with *--adapt <filename>*
    * Changed: variables can be set by calling a script (see *Set <var>, cmd: <script>*). If the script fails, bake aborts now with an error instead continuing with a warning.
    * Added: allow additional bake arguments specified per project in a bakery collection
    * Bugfix: bakery collections can now reference a quoted project name and names with "-" or ":"
    * Bugfix: under rare circumstances bake did not abort with an error if the main directory specified with -m does not exist

March 22, 2018 - bake-toolkit 2.44.1
    * Bugfix: in Adapt.meta "__MAIN__" in project now applies to *all* configs in the main project
    * Changed: "--compilation-db" now generates absolute paths if "--abs-paths" is set

February 26, 2018 - bake-toolkit 2.44.0
    * Added: Case sensitivity check of C/C++ include files (on by default!), use --no-case-check to disable it
    * Added: Variable $(Uid), a CRC32 over relative path to main project dir plus main config name.
    * Changed: error output is NOT shifted to the end anymore (was done when compiling with "-r")

February 15, 2018 - bake-toolkit 2.43.2
    * Bugfix: fixed prebuild feature after changes in 2.43.0

February 12, 2018 - bake-toolkit 2.43.1
    * Bugfix: exception when using file specific flags and defines fixed (bug introduced with 2.43.0)

February 12, 2018 - bake-toolkit 2.43.0
    * Bugfix: when building with "stop on first error" (-r) and an error occurs in PreSteps or PostSteps of a dependency, the error status was not correctly handled.
    * Added: option to keep file endings for object files, which means file.cpp becomes file.cpp.o instead of file.o:

      .. code-block:: console

          DefaultToolchain keepObjFileEndings: true

    * Added: the hard coded list for source file endings for a specific compiler (CPP, C, ASM) can now be overwritten, e.g.:

      .. code-block:: console

          Compiler CPP {
              SrcFileEndings ".cpp, .c, .cxx"
          }

January 12, 2018 - bake-toolkit 2.42.3
    * Added: command line parameter "-nb" to suppress the lines "\*\*\*\* Building x of y: name (config) \*\*\*\*"
    * Added: ExternalLibraries with "search: false" are now also taken into account when checking if executable is outdated
    * Added: "--adapt" accepts now comma separated values like this: "--adapt gcc,debug,bla", which is the same as "--adapt gcc --adapt debug --adapt bla"

December 14, 2017 - bake-toolkit 2.42.2
    * Added: bakeqac can suppress unsuppressible QAC errors now (with "PRQA S <num>" in the same source code line)
    * Bugfix: possible crash when using bake with the commandline tool "less"

December 6, 2017 - bake-toolkit 2.42.1
    * Added: --incs-and-defs now also prints the directory of the project

November 30, 2017 - bake-toolkit 2.42.0
    * Added: bakeqac now supports PRQA 2.2.2 and MCPP 1.5.2
    * Added: --qacverbose to print the commandline which is used for for qacli

November 27, 2017 - bake-toolkit 2.41.4
    * Changed: bakeqac cyclomatic complexity check is now more robust against non-ASCII characters in source files

November 17, 2017 - bake-toolkit 2.41.3
    * Changed: development dependency changed from latest rake to 12.2.1 to avoid problems with Ruby 1.9.

November 14, 2017 - bake-toolkit 2.41.2
    * Bugfix: complex variable $(OutputDir,"project name", "config name") did not work if output folder is not default and based on other variables
    * Changed: variable substitution speed up

November 14, 2017 - bake-toolkit 2.41.1
    * Bugfix: complex variable $(OutputDir,"project name", "config name") did not work at all

November 13, 2017 - bake-toolkit 2.41.0
    * Added: default and filter attributes now supported by all elements in Project.meta (except the Project element itself).
    * Added: "-p ." now specifies the project of the current folder. Example usage: "bakeqac UnitTestBase --adapt gcc -p ."
    * Bugfix: bakeqac does not suppress warnings anymore about mismatch between glibc and QAC.

October 10, 2017 - bake-toolkit 2.40.1
    * Added: bakeqac supports now different installation folders for QACPP and MCPP.
    * Added: qacsteps can now be separated by "," (e.g. "--qacstep admin,analyze,mdr")
    * Bugfix: spaces in roots.bake were not correctly interpreted on Linux / Mac under some circumstances.

October 9, 2017 - bake-toolkit 2.40.0
    * Workaround: glob pattern with ** don't work with NTFS junctions. First level now manually checked (like done in bake <= 2.34.4).
    * Added: filters can have arguments, e.g. --do run=--gtest_repeat=2, which can be accessed via $(FilterArguments, run).

September 19, 2017 - bake-toolkit 2.39.1
    * Bugfix: bakeqac: cyclomatic complexity check now also works with PRQA Framework 2.2.0.

September 18, 2017 - bake-toolkit 2.39.0
    * Changed: bakeqac: now compatible with PRQA Framework 2.2.0.

August 8, 2017 - bake-toolkit 2.38.3
    * Changed: bakeqac: if qacli returns with an error, file and message filters are now also applied (but qacli errors are printed out).

August 7, 2017 - bake-toolkit 2.38.2
    * Added: variable $(QacActive) evaluates to "yes" if bakeqac is running, otherwise "no".

August 3, 2017 - bake-toolkit 2.38.1
    * Bugfix: bakeqac: suppressions for cyclomatic complexity check may not work in certain cases.

July 21, 2017 - bake-toolkit 2.38.0
    * Bugfix: It was not possible to specify a path to the compiler including spaces.
    * Changed: --qacnofilter splitted into --qacnomsgfilter and --qacnofilefilter.
    * Changed: bake(ry) will exit if a specified workspace root does not exist.
    * Cosmetic: Removed "No match for project" warning from bakery.
    * Cosmetic: Changed info output when compiling single files with "-f".

July 18, 2017 - bake-toolkit 2.37.14
    * Bugfix: ".." in *Files* are replaced now with "__" instead with "##" (TI compiler cannot handle this).

July 17, 2017 - bake-toolkit 2.37.13
    * Bugfix: Corrected output folder for *Files* in Project.meta with absolute paths.

June 28, 2017 - bake-toolkit 2.37.12
    * Bugfix: bakery did not work with -j <num> and -v <num>.

June 22, 2017 - bake-toolkit 2.37.11
    * Changed: bakeqac: next try to workaround QAX daemon error.

June 19, 2017 - bake-toolkit 2.37.10
    * Cosmetic: Docu update for inofficial 2.37.9 release.

June 13, 2017 - bake-toolkit 2.37.9 (not released officially)
    * Bugfix: Exception in exception handler of writing dep files.

May 31, 2017 - bake-toolkit 2.37.8
    * Added: bake handles \*.cu files as c-files, so Cuda files can be compiled without renaming.

May 31, 2017 - bake-toolkit 2.37.7
    * Changed: bakeqac: terminate process and wait a little bit before killing it (for systems which support SIGTERM).

May 31, 2017 - bake-toolkit 2.37.6
    * Cosmetic: bakeqac: added more debug info in "process takes too long" workaround.

May 30, 2017 - bake-toolkit 2.37.5
    * Bugfix: bakeqac: now timeout workaround gets active as expected, but error handling was broken (ruby exception).

May 29, 2017 - bake-toolkit 2.37.4
    * Changed: bakeqac: timeout for *qacli* calls now 80% of qacretry time (except *qacli admin*, which is 60 seconds).

May 23, 2017 - bake-toolkit 2.37.3
    * Added: bakeqac: making metrics report now retried on error.
    * Added: new complex variable $(ProjectDir,<project name>).

May 3, 2017 - bake-toolkit 2.37.2
    * Added: new argument to *Linker* tag in Project.meta: *onlyDirectDeps: false|true*. If set to true, the linker links only first level dependencies (no subdependencies).
    * Added: bakeqac: made workaround introduced in 2.37.1 more robust (removing locks from qac files after killing qac process).

May 2, 2017 - bake-toolkit 2.37.1
    * Added: bakeqac: another workaround for hanging "qacli admin" call. Process will be killed after 60s and the call retried as long as the retry timer is not expired.

April 25, 2017 - bake-toolkit 2.37.0
    * Added: bakeqac: possibility to increase accepted cyclomatic complexity of functions, see documentation.
    * Bugfix: Info output "\*\*\*\* Building x of y: projectName (configName) \*\*\*\*" is suppressed again with "-v0" - affected versions: >= 2.32.0.

April 18, 2017 - bake-toolkit 2.36.1
    * Changed: bakeqac: it's not an error anymore, if a project doesn't consist of any files

April 11, 2017 - bake-toolkit 2.36.0
    * Added: bake can now use QAC to printout cyclomatic complexity. Use *--qacstep mdr* after regular MISRA build or from scratch *--qacstep "admin|analyze|mdr"*.

April 5, 2017 - bake-toolkit 2.35.3
    * Bugfix: added workaround for broken concurrent gem on some platforms with ruby 1.9.3.

March 30, 2017 - bake-toolkit 2.35.2
    * Bugfix: forgot to remove debug output in 2.35.1.

March 29, 2017 - bake-toolkit 2.35.1
    * Bugfix: --prebuild was broken - affected versions: >= 2.33.0.
    * Bugfix: Invalid command line arguments could have been recognized as valid, e.g. "--rebuild123" was interpreted as "--rebuild", there was no complaint about the "123" - affected versions: >= 2.34.4.

March 27, 2017 - bake-toolkit 2.35.0
    * Bugfix: Rubys IO.select() is not thread-safe by itself. It could happen, that bake hangs and the user has to press a key (due to waiting for already closed stdin stream) - affected versions: >= 2.33.0.
    * Bugfix: if no roots.bake was found, the default root ("<mainProject>/..") was added to the root list even when -w options were added on command line - affected versions: >= 2.26.0.
    * Added: roots defined on command line (with -w) and entries in roots.bake can be equipped with an optional search depth setting, e.g. "-w some/folder,3".
      This can reduce startup time of bake avoid multiple-projects-found-warnings.

March 16, 2017 - bake-toolkit 2.34.4
    * Added: CommandLine and Makefile have a new argument. If *independent: true*, they are not executed exclusively but in parallel to other projects/configs.
    * Added: -j can now be used without space and -v with space, e.g. -j8 or -j 8, -v2 or -v 2.
    * Internal: under the hood optimizations for parallel build.

March 9, 2017 - bake-toolkit 2.34.3
    * Changed: slightly changed thread handling (internal change).

March 9, 2017 - bake-toolkit 2.34.2
    * Changed: improved output for failed builds (exit status, bakery message).
    * Changed: improved debug-thread output.
    * Bugfix: killing processes on failure may not work correctly.

March 9, 2017 - bake-toolkit 2.34.1
    * Added: --debug-threads to debug multithread problems.
    * Bugfix: Cleaned up thread data structure. I don't think this is a real problem, but this depends on OS implementation of Ruby's thread lib".
    * Bugfix: On Linux console bakery abort output corrected.

March 8, 2017 - bake-toolkit 2.34.0
    * Added: With parameter -O the output can be synchronized now for parallel build.
    * Added: Logging which roots are checked when loading Project.metas.
    * Bugfix: Fixed ctrl-c for bakery in some shells.

March 2, 2017 - bake-toolkit 2.33.0
    * Changed: Projects are built in parallel now (not only the files within a single project). This implies a change in the output.

February 27, 2017 - bake-toolkit 2.32.0
    * Changed: Per default configs without *Files* and *Steps* are not counted and printed out anymore (because nothing has to be done), use *-v2* to show them again.
    * Changed: Templates used for *--create* are now closer to ESRLabs standard. Exit code corrected (was 1 instead of 0), thanks to flxo for the pull request.
    * Changed: Promoted warning "files are compiled more than once" to error.

February 23, 2017 - bake-toolkit 2.31.5
    * Added: qac: Retry if QAX daemon cannot be reached

February 22, 2017 - bake-toolkit 2.31.4
    * Bugfix: --install-doc was broken

February 22, 2017 - bake-toolkit 2.31.2
    * Changed: Files which will be compiled are now printed out *before* the compiler is called, not afterwards anymore.

February 17, 2017 - bake-toolkit 2.31.1
    * Added: Tasking compiler support

February 3, 2017 - bake-toolkit 2.31.0
    * Added: Dry run via command line parameter --dry.
    * Added: Support for compiler, archiver and linker prefixes, can be used for e.g. sccache.
    * Added: "If" is now an alias for "Adapt". To negate the conditions, use "Unless".
    * Added: For Adapts in Project.meta the "project" attribute is now "__THIS__" per default, which should be correct in almost every case.
    * Cosmetic: Getting rid of warning output if paths start with ".", e.g. IncludeDir "./local/abc".
    * Cosmetic: Only print the first out-of-date meta file when checking cache.

January 20, 2017 - bake-toolkit 2.30.0
    * Added: New adapt option "push_front".
    * Added: Project.meta and Collection.meta will be searched upwards if not found in current directory (or the directory specified with -m).
    * Changed: --doc opens online docu per default. You can install the offline docu with --install-doc.
    * Added: --debug prints more information when reading the cache, use this as feedback if you think caching does not work correctly.

January 12, 2017 - bake-toolkit 2.29.4
    * Added: qac: Workaround if QAC cannot handle the amount of errors and returns with != 0. The build must not be aborted, instead the printed errors should be parsed.

January 12, 2017 - bake-toolkit 2.29.3
    * Bugfix: qac: QAC bails out if modules have too many errors, added workaround and additional hint in output.

January 11, 2017 - bake-toolkit 2.29.3
    * Bugfix: Some commandline checks in combination with --file-list were outdated.

January 10, 2017 - bake-toolkit 2.29.2
    * Changed: --file-list output now written into files instead of stdout, see "bake -h".
    * Bugfix: adapt condition "toolchain" not evaluated correctly in all cases

January 4, 2017 - bake-toolkit 2.29.0
    * Added: CleanSteps, executed only when calling bake with "-c" or "--rebuild".
    * Added: Wildcard "*" is allowed for project/config names in Adapt.
    * Bugfix: In certain circumstances an Adapt was not applied to subconfigs of the Project.meta where Adapt was defined.

January 4, 2017 - bake-toolkit 2.28.1
    * Bugfix: Build does not break anymore if "LintPolicy" is still defined in Project.meta. Now only a warning is printed out.

January 3, 2017 - bake-toolkit 2.28.0
    * Added: private flag for configs (cannot be referenced directly from outside of the project).
    * Added: attribute "echo: off" for CommandLine and Makefile.
    * Added: "--file-list" shows all files and headers of the projects.
    * Removed: lint support.
    * Bugfix: environment variables (specified with "Set") can now be set individually for different configs.
    * Changed: qac: again slightly modified cip workaround.

January 2, 2017 - bake-toolkit 2.27.0
    * Added: local *Adapt* with conditions (e.g. toolchain), see :ref:`adapt_reference`.
    * Changed: qac: cip workaround slightly adapted, removed temporary debug output.

December 23, 2016 - bake-toolkit 2.26.1
    * Changed: qac: next try to add a workaround for the cip file bug.
    * Cosmetic: fixed possible wrong message when reloading metas ("corrupt" instead of "changed")

December 20, 2016 - bake-toolkit 2.26.0
    * Changed: before this version, "-w" command line args (which define the workspace roots) have overwritten roots.bake file. Now these roots will be
      merged. First "-w", then roots.bake. Note: this will not break current builds.

December 16, 2016 - bake-toolkit 2.25.1
    * Bugfix: a null pointer exception could occur in 2.25.0, which happened in a complex scenario with multiple dependencies to a default config which extends another config with dependencies.
      Luckily, this bugfix goes along with a small performance improvement when loading uncached meta files.

December 15, 2016 - bake-toolkit 2.25.0
    * Changed (!): before this version, all "IncludeDir"s were evaluated prior to the "Dependency"s to calculate the include path string for the compiler. Now the line order
      is taken into account. To get the same include path string as in 2.24.x, shift all "IncludeDir"s in front of the first "Dependency".
    * Added: it is possible to mark an IncludeDir with "system: true", which means that e.g. for gcc "-isystem" is used instead of "-I". Very useful for third party libs.
    * Bugfix: qac: adapted parser to new gcc version strings. On some machines an incorrect CCT was chosen.
    * Bugfix: when building with "-p <projectname>", bake has not only built <projectname>, but also all injected dependencies of <projectname>, which was not intended.
    * Added: qac: additional step to generate reports, activate it manually with "--qacstep report", see documentation.
    * Cosmetic: Adapt.meta files are also cached now.
    * Temporary: cip bug workaround from 2.24.2 does not work, added some debug output to get more infos - sorry for the spam - will be removed soon.

December 5, 2016 - bake-toolkit 2.24.3
    * Added: qac: if "<mainConfigName>Qac" is found in main project, it will be used instead of "<mainConfigName>"
    * Added: First version of bake-format script, thanks to gizmomogwai

November 24, 2016 - bake-toolkit 2.24.2
    * Bugfix: qac: fixed recognition of platform for cygwin with gcc >= 5.0
    * Bugfix: qac: default folder of qacdata is now <main project>/.qacdata instead of <working dir>/.qacdata
    * Bugfix: qac: workaround for "qacli admin": retry up to 10 times if cip file is empty (getting compiler data)

November 16, 2016 - bake-toolkit 2.24.1
    * Bugfix: qac.cct was not appended if --cct is used.
    * Bugfix: qac: abort if QAC_HOME is set to empty string.
    * Bugfix: qac: improved recognition of gcc platform.
    * Changed: improved warning if the path in IncludeDir matches to several folders (warning will be shown in verbosity level 2 and above).

November 7, 2016 - bake-toolkit 2.24.0
    * Bugfix: qac: output was not synced immediately to the console on some systems.
    * Changed: qac: patching of cct introduced with 2.23.9 now opt-in via command line argument: --qaccctpatch.
    * Changed: qac: default build output directory is now "build/.qac/" instead of "build/" (which does not overwrite regular build output anymore).
    * Changed: if default build folder is used, the parent folder "build" will be also removed when the project is cleaned if the "build" folder will become empty.
    * Added: bakeclean script to delete all .bake, .bake/../build and .bake/../build_* folders
    * Added: prebuild feature now uses objects instead of the library if objects exist.
    * Changed: default executable file ending on non-Windows systems now "" (except Diab and Greenhills, here it is always ".elf").

October 26, 2016 - bake-toolkit 2.23.12
    * Bugfix: qac: now also files from .qacdata folder are filtered out.
    * Bugfix: qac: modules were not be filtered out correctly, e.g. swcAbcd was not filtered out if swcAbc was compiled.
    * Removed: qac: qac.rcf will not be searched anymore (most probably this feature was never used).
    * Added: qac: qac.cct will be searched up to root; if found, the content will be appended to the original cct unless specified otherwise.

October 26, 2016 - bake-toolkit 2.23.9
    * Bugfix: qac: command line options not correctly handed over to bake (bakeqac has been aborted in this case).
    * Bugfix: qac: On some systems some warnings were not suppressed. Added a few defines to cct which hopefully fixes this.
    * Bugfix: qac: --qacretry did not work with --qacnofilter.

October 20, 2016 - bake-toolkit 2.23.8
    * Bugfix: qac: "License Refused" for \*.c Files not treated as an error anymore, which was a problem for "--qacretry".
    * Changed: qac: default qacdata folder is now ".qacdata"
    * Changed: qac: warnings are now sorted by line numbers per file
    * Changed: qac: "--qacfilter off|on" (default on) was changed to "--qacnofilter" (if skipped, filters are active)
    * Changed: qac: "--qacnoformat was reanmed to "--qacrawformat"
    * Cosmetic: qac: if license retry timeout is reached, an additional info is printed.
    * Added: qac: With --qacdoc a link to the appropriate documentation page is printed for every warning.

October 17, 2016 - bake-toolkit 2.23.7
    * Changed: renamed qac build steps from create, build and result to admin, analyze and view (the original qac names).
    * Bugfix: qac view step might have been executed although build has been failed.
    * Bugfix: qac view step with never executed analyze step might have been crashed.
    * Bugfix: qac C++11 and C++14 switches were broken.

October 14, 2016 - bake-toolkit 2.23.6
    * Bugfix: qac license refused error now really shown.
    * Changed: QAC_RCF environment variable not supported anymore. Instead a file qac.rcf will be searched upwards from bake main project folder.
    * Changed: qac messages reformatted, MISRA rule now completely shown. For plain qac style use --qacnoformat.
    * Added: number of qac messages are printed at the end.
    * Added: bakeqac now supports -a <color> like bake.
    * Added: with --qacretry <seconds> a retry timeout can be specified if license is refused, default is no retry.

October 14, 2016 - bake-toolkit 2.23.5
    * Bugfix: qac cct auto detection fixed.
    * Bugfix: --prepro option fixed.

October 14, 2016 - bake-toolkit 2.23.4
    * Bugfix: qac during analyse step license error not detected properly.

October 13, 2016 - bake-toolkit 2.23.3
    * Bugfix: improved auto detection of cct for qac.
    * Bugfix: print qac output in case of error.
    * Changed: QAC_HOME can end now with a slash.
    * Changed: qacli call now relative to QAC_HOME.
    * Changed: qac create will now be done regardless if qacdata exists.

October 13, 2016 - bake-toolkit 2.23.2
    * Added: bakeqac, see documentation.

October 5, 2016 - bake-toolkit 2.22.0
    * Changed: when building, only the return value of the compiler is taken into account, not the result of the error parser anymore. Old behaviour can be switched on by command line argument.
    * Bugfix: again fixed reading of dependency files, added several unittests.
    * Internal: based on new rtext 0.9.0 and rgen 0.8.2 now.

September 30, 2016 - bake-toolkit 2.21.0
    * Changed: version and time infos are suppressed now per default. Version can be seen with --help or --version, time can be seen with --time.
    * Changed: option --writeCC2J renamed to --compilation-db, which has the default filename compilation-db.json now.
    * Added: option --incs-and-defs=json prints infos about includes and defines of all projects in json format.

September 28, 2016 - bake-toolkit 2.20.4
    * Bugfix: fixed auto-detected of dependency files

September 21, 2016 - bake-toolkit 2.20.3
    * Bugfix: reading dependency files was broken for TI compiler, format is now auto-detected independent from compiler version

September 13, 2016 - bake-toolkit 2.20.2
    * Bugfix: *prebuild* libs were not linked if all original sources were removed

September 5, 2016 - bake-toolkit 2.20.1
    * Added: inject feature for dependencies
    * Added: option to generate a dot graph file
    * Added: *prebuild* feature for distribution builds
    * Added: commandline option *--build_* to enable the old outputdir behaviour: *build_* instead of *build/*
    * Added: printing out more information when loading Project.metas in verbosity level 3
    * Changed: circular dependency warning moved from verbosity level 1 to 3
    * Added: ToolchainName is now a predefined variable for Project.meta
    * Added: --compile-only option (which is equal to the workaround -f ".")
    * Bugfix: --adapt commandline option accepts absolute paths now
    * Changed: removed the *bundle* feature

August 12, 2016 - bake-toolkit 2.19.2
    * Bugfix: fixed TI linker error parser

August 4, 2016 - Eclipse plugin 1.7.1
    * Bugfix: error markers may not created correctly if projects had "^" in the name

August 1, 2016 - bake-toolkit 2.19.1
    * Bugfix: made the new "listening to raw character 0x3" more robust

July 28, 2016 - bake-toolkit 2.19.0
    * Changed: default output dir is now build/<something> instead of build_<something>
    * Added: listening to raw character 0x3 on stdin to abort bake/bakery (needed for some Cygwin installations)
    * Internal: switching from rgen 0.8.0 to rgen 0.8.1 (which should have no functional impact)

June 22, 2016 - bake-toolkit 2.18.0
    * Bugfix: order if linker libs fixed. For compatibility, a new command line flag "--link-2-17" to get the old behaviour was added.

      ======================================  ======================================
      Example
      ======================================  ======================================
      Dependencies                            A->B->D and A->C->D
      New correct link order                  A, B, C, D
      Old wrong link order (--link-2-17)      A, B, D, C
      ======================================  ======================================


May 4, 2016 - bake-toolkit 2.17.4
    * Bugfix: bakery returned 1 for successful builds
    * Changed: bakery now lists all failed unit tests at the end

April 13, 2016 - bake-toolkit 2.17.3
    * Bugfix: Commands injected by adapt feature were executed in wrong directory
    * Bugfix: Added an error if two sources would result in the same object file

April 6, 2016 - bake-toolkit 2.17.2
    * Bugfix: "--link-only" option has ignored libraries from makefiles

March 15, 2016 - bake-toolkit 2.17.1
    * Bugfix: configs with inherited DefaultToolchains were not listed on command line (via "--list")
    * Changed: if build config name was omitted on commandline, a default config is specified and this default config has no DefaultToolchain, bake lists all possible build configs (same as "--list")
    * Added: warning if sources files were compiled several times for one binary

March 15, 2015 - Eclipse plugin 1.7.0
    * Bugfix: config names written in inverted commas or with special characters were not recognized by "Select bake Config" menu
    * Removed: multi-console option, which was rarely used and not working correctly anymore with latest Eclipse version
    * Added: option to disable/enable console scroll-lock/word-wrap when starting a build
    * Cosmetic: config names are now displayed in "Select bake Config" in the same order as in Project.meta
    * Cosmetic: bake console does not open automatically anymore when starting Eclipse

February 26, 2016 - bake-toolkit 2.16.1
    * Added: experimental bundle feature
    * Changed: "--threads" now deprected, use "-j" instead
    * Bugfix: in rare cases the cache from a copied/moved Project.meta file was reused instead of reloading the file. This could lead to errors.

February 11, 2016 - bake-toolkit 2.15.0
    * Added: multiple inheritance for configs
    * Added: ArtifactName can be specified for libraries
    * Added: Merged configs are printed out when running bake with --debug
    * Added: info output if "path magic" hides local paths for IncludeDir
    * Bugfix: fixed passing arguments from bakery to bake

January 14, 2016 - bake-toolkit 2.14.0
    * Added: possibility to change configs via command line, e.g. changing compiler, see "adapt" docu page
    * Changed: extending configs in a Project.meta file made more generic, see "derive" docu page
    * Changed: default order of filenames changed, now order in Project.meta has the highest priority as intended. Results of glob patterns are sorted alphabetically as before.
    * Changed: libraries from makefiles are linked now after other libraries defined from the same config
    * Added: IncludeDir now possible for CustomConfigs
    * Bugfix: --abs-paths now works with --incs-and-defs

December 23, 2015 - bake-toolkit 2.13.1
    * Bugfix: merging configs was extremely slow in 2.12.2 and 2.13.0

December 23, 2015 - bake-toolkit 2.13.0
    * Bugfix: It was possible that the archiver and linker were called for --prepro and --link-only builds
    * Added: possibility to specify minimum and maximum required bake version in Project.meta file
    * Added: option to omit -b when executing the bakery
    * Added: bakery now searches recursively for bake projects
    * Changed: some commandline arguments changed, deprecated arguments still supported

      ==================  =======================
      New argument        Deprecated argument
      ==================  =======================
      --do                --include_filter
      --omit              --exclude_filter
      --show_configs      --list
      --link-only         --link_only
      --generate-doc      --docu
      --lint-min          --lint_min
      --lint-max          --lint_max
      --ignore-cache      --ignore_cache
      --toolchain-info    --toolchain_info
      --toolchain-names   --toolchain_names
      --abs-paths         --show_abs_paths
      --no-autodir        --no_autodir
      --incs-and-defs     --show_incs_and_defs
      --conversion-info   --conversion_info
      --doc               --show_doc
      --license           --show_license
      ==================  =======================
December 16, 2015 - bake-toolkit 2.12.2
    * Bugfix: extending a client config (merging) could have broken the parent config
    * Changed: empty libraries will not be created and linked anymore
    * Changed: added inject as alias for infix
November 16, 2015 - bake-toolkit 2.12.1
    * Bugfix: inherit and infix features may have calculated wrong relative paths
October 26, 2015 - Eclipse plugin 1.6.0
    * Added: possibility to specify folders to exclude when importing projects
    * Bugfix: fixed exception when trying to build after starting eclipse with a closed project
October 14, 2015 - bake-toolkit 2.12.0
    * Changed: now ALL startup and exit steps are executed regardless if the previous steps were successful even if stopOnFirstError was configured
    * Bugfix: relative paths between roots based on roots.bake were calculated incorrectly
October 2, 2015 - bake-toolkit 2.11.4
    * Bugfix: bake aborted in larger workspaces with 2.11.3 right before linking
September 8, 2015 - bake-toolkit 2.11.3
    * Bugfix: linker executed even if a dependency has an error
    * Bugfix: now the new docu is really added to the gem
September 3, 2015 - bake-toolkit 2.11.2
    * Bugfix: all files were always be recompiled with ruby < 1.9.3
    * Changed: switched to new docu style, thanks Nico!
August 4, 2015 - bake-toolkit 2.11.1
    * Added: project dir output for conversion tool
    * Moved: wishlist to github
July 31, 2015 - bake-toolkit 2.11.0
    * Added: new parameters for includeDir: inherit and infix
    * Added: dependency output for conversion tool
    * Bugfix: makefile flags where not used when cleaning the workspace
July 6, 2015 - bake-toolkit 2.10.3
    * Bugfix: Build stopped unintentionally when using -r
July 3, 2015 - bake-toolkit 2.10.2
    * Bugfix: PostSteps were unintentionally executed if a dependent step (e.g. linking) was not executed due to an error in another project (e.g. compiler error)
July 1, 2015 - bake-toolkit 2.10.1
    * Added: Possibility to add descriptions for configs which will be printed when using --show_configs
    * Bugfix: link_only did not link only if not all sources of the main project were not built before
    * Bugfix: Ctrl-C on command line did not work properly under Linux
July 1, 2015 - Eclipse plugin 1.5.1
    * Bugfix: AdjustIncludes broken for subfolder projects (with a "^" in the name)
    * Bugfix: Error parser broken for subfolder projects (with a "^" in the name)
    * Bugfix: Configs with inherited DefaultToolchain were not selectable to build
June 10, 2015 - bake-toolkit 2.9.2
    * Cosmetic: Redundant include directories are now removed before calling the compiler
    * Bugfix: Moving cached meta files was not recognized correctly, wrong path references may have been used
June 8, 2015 - bake-toolkit 2.9.1
    * Changed: "--doc" replaced by "--show_doc" to avoid confusion
June 5, 2015 - bake-toolkit 2.9.0
    * Added: "--create" command line option to create project templates
    * Added: "--conversion_info" command line option for bake conversion tool
    * Cosmetic: made output clearer if "--link_only" is used for non ExecutableConfigs
June 5, 2015 - Eclipse plugin 1.4.5
    * Bugfix: input streams from bake were closed too early under Linux - console window output and AdjustCDT feature should work correctly now
    * Added: "Link This Project Only" shortcut added
    * Added: Files under "build_*" and ".bake" are now automatically marked as derived (not shown in "Open Resource" dialog)
    * Changed: error message dialog of AdjustCDT now displays the end instead of the beginning of very long error messages
May 19, 2015 - bake-toolkit 2.8.0
    * Bugfix: when building a project with -p name, not only name was built, but all projects which start with the string name
    * Added: more info why Project.meta files are reloaded
    * Added: createVSProjects can create VS2013 projects
April 22, 2015 - bake-toolkit 2.7.0
    * Added: possibility to use Eclipse file ordering for compilation (eclipseOrder attribute for DefaultToolchain)
    * Changed: $(:) and $(/) are now mapped to Ruby internal variables File::PATH_SEPARATOR and File::SEPARATOR.
    * This fixes the result in Cygwin/MinGW environments
    * Bugfix: cmdline files are now written even if the build step fails
April 14, 2015 - bake-toolkit 2.6.0
    * Added: validExitCodes attribute to steps (if a step has valid exit codes != 0)
    * Added: StartupSteps and ExitSteps (always executed before and after a build)
April 8, 2015 - bake-toolkit 2.5.0
    * Added: OS dependent variable $(:), which is used for setting the PATH variable
March 30, 2015 - bake-toolkit 2.4.3
    * Added: If Project.meta files are updated, sources will only be recompiled if necessary
    * Added: Set command in Project.meta has now an env attribute to store variables also in system environment which makes them accessible from user scripts
    * Added: GCC_ENV toolchain (uses environment variables)
    * Added: Improved MSVC support
March 16, 2015 - VS plugin 1.0.1
    * Added: Support for VS2013
March 12, 2015 - bake-toolkit 2.3.4
    * Changed: Clang command is now "clang" per default instead of llvm-gcc
    * Added: CLANG_ANALYZE toolchain
    * Added: MSVC toolchain
    * Bugfix: some minor fixes
February 27, 2015 - Eclipse plugin 1.3.0
    * Added: bake projects with equal names can be imported now
February 19, 2015 - bake-toolkit 2.2.2
    * Changed: output dirs are now prefixed with "build\_" per default
    * Changed: introduced complex variable $(OutputDir,projectName,configName)
    * Changed: reworked merge strategy of two configs, especially toolchain options
    * Added: variables can be nested now
    * Bugfix: fixed dependency header check for Unix when running Windows on a virtual machine
    * Bugfix: variable OutputDir did not take overwritten output directory from toolchain into account
    * Cosmetic: do not show internal pipes anymore when printing command lines
January 26, 2015 - bake-toolkit 2.1.1
    * Bugfix: dependent header file check in 2.1.0 was broken
    * Changed: files defined via glob pattern are sorted alphabetically now
January 23, 2015 - bake-toolkit 2.1.0
    * Bugfix: fixed crash in warning output if setting variable via cmd did not work
    * Workaround: dependent header files are now ignored on Windows if path starts with "/" and file cannot be found
    * Changed: output of lint is now ignored, linting will only fails if it cannot be executed
    * Changed: introduced new verbose mode -v3, shifted some output to this level
    * Added: a dependency project can be specified with parent folders if it is ambiguous, e.g. Dependency "my/folder/proj", config: lib
    * Added: experimental CC2J output
January 23, 2015 - Eclipse plugin 1.2.1
    * Bugfix: importing projects with existing .(c)project files may be placed in wrong folder
January 15, 2015 - bake-toolkit 2.0.10
    * Bugfix: spaces in paths were not handled correctly in all cases
    * Bugfix: dependency files of Keil compiler not treated correctly
    * Added: showing why files are built in verbose mode -v2
    * Added: whole workspace can be linted now (projects will be linted separately)
    * Changed: removed bake-doc command, use bake --doc instead
    * Changed: if no default project is specified, possible build configs are shown on command line again like in bake 1.x
January 7, 2015 - bake-toolkit 2.0.3
    * Changed: default configuration is chosen if configuration name is omitted. This applies to command line as well as to Dependency definitions, e.g.:
        * Project.meta

            .. code-block:: console

                Dependency canDriver        # no config attribute

        * Command line

            .. code-block:: console

                User@Host:~$ bake -m bla/myProj

        .. note::

            To show the possible configs of a project, use the `--show_configs` command line option.


    * Changed: more than one config of a project can be used in one build.

        Example:

        .. code-block:: console

            Dependency canDriver, config: C1
            Dependency canDriver, config: C2


        To reference a config of the current project, omit the project name, e.g.:

        .. code-block:: console

            Dependency config: C3

        To build a single project, you can still use -p command line argument:

        .. code-block:: console

            User@Host:~$ bake Debug -p canDriver

        However, if canDriver has more than one config in the workspace, all configs will be built. To build only a single config, use a comma separator like this:

        .. code-block:: console

            User@Host:~$ bake Debug -p canDriver,C1

    * Changed: the default output folder has been changed due to the new feature of having several configs of a project in one workspace.
        ============    =====================================    =======================================================
        \               Old                                                     New
        ============    =====================================    =======================================================
        Main project    $(MainConfigName)                        $(MainConfigName)

        Sub Project     $(MainConfigName)_$(MainProjectName)     $(ConfigName)_$(MainProjectName)_$(MainConfigName)
        ============    =====================================    =======================================================

        .. warning::
            Be careful if you have something like this in Project.meta:

            .. code-block:: console

                ExternalLibrary "bspCoreZ6/$(MainConfigName)_$(MainProjectName)/src/coreZ6/startup/startupCode.o", search:false

            This refers to the old output directory. Change it or if you want to support old and new bake versions,
            write a PreStep which copies the file from the new location to the old one.

    * Changed: with -f a pattern can be specified, not only a single file. All files matching this string will be compiled.
    * Changed: variables in Dependency definitions are not allowed anymore to avoid inconsistencies.
    * Changed: no error will be reported anymore if makefile has no clean target.
    * Changed: source files will now be compiled and archived ordered by the Files definition in Project.meta, not by a Eclipse-backward-compatibility-ordering.
    * Changed: reworked some error messages, more error annotations are shown in IDEs
    * Added: "--include_filter" and "--exclude_filter" also work for main step of CustomConfig
    * Added: possibility to add comments in roots.bake
    * Added: new variables CPPPath, CPath, ASMPath, ArchiverPath and LinkerPath. These variables can also be used in InternalDefines and InternalInclude files.
    * Added: lint is not restricted to GCC toolchain anymore.
    * Added: --docu option. Specify the docu command line in Docu tag of the (Default)Toolchain.
    * Removed: support for Ruby 1.8. Use Ruby 1.9 or higher.
    * Removed: dependencies to cxxproject and rake gems
    * Removed: "-j" as default flag when calling makefiles. This must be explicitly specified.
    * Removed: option to check for unnecessary includes
    * Removed: hardcoded TI compiler commands and flags
        =======================    ==========================================================================    ===========
        \                          Old                                                                           New
        =======================    ==========================================================================    ===========
        Compiler command           $(ti_home)/ccsv5/tools/compiler/tms470/bin/cl470                              ti_cl

        Compiler flags             -mv7A8 -g --include_path="#{ti_home}/ccsv5/tools/compiler/tms470/include"
                                   --diag_warning=225 -me --abi=eabi --code_state=32 --preproc_with_compile

        Archiver command           $(ti_home)/ccsv5/tools/compiler/tms470/bin/ar470                               ti_ar

        Linker command             $(ti_home)/ccsv5/tools/compiler/tms470/bin/cl470                               ti_cl

        Linker flags               -mv7A8 -g --diag_warning=225 -me --abi=eabi --code_state=32 -z
                                   --warn_sections -i"$(ti_home)/ccsv5/tools/compiler/tms470/lib"
                                   -i"$(ti_home)/ccsv5/tools/compiler/tms470/include"

        Linker lib prefix flags    -lDebug/configPkg/linker.cmd
        =======================    ==========================================================================    ===========

    * Bugfix: variables in add and remove attributes of Flags now work as intended
    * Bugfix: output folder was not created if no sources are specified for LibraryConfig and ExecutableConfig.
    * Bugfix: "-p" was not forwarded in bakery.
    * Cosmetic: bakery now calls bake with relative pathnames, which results in nicer outputs.
December 19, 2014 - Eclipse plugin 1.2.0
    * Bugfix: it is now ensured, that bake will be started from Eclipse working directory
    * Bugfix: projects created with the "new bake project wizard" are now placed in the correct folder.
    * Added: Eclipse working directory shown in bake preference dialog (important if -w option is used with relative paths)
    * Added: Options to recreate .(c)project files when importing bake projects
    * Changed: Eclipse configurations will be named "bake" and not "Do not use this config, use bake instead"
December 16, 2014 - Eclipse plugin 1.1.1
    * Bugfix: Adjust include and defines broken feature used wrong command line option.
November 7, 2014 - bake-toolkit 1.8.0, Eclipse plugin 1.1.0
    * Added: InternalIncludes and InternalDefines in DefaultToolchain, which are forwarded to the IDE.
    * Changed: No default options for PC-lint in combination with GCC will be provided anymore. Use the official way, see co-gcc.lnt in PC-lint installation.
    * Bugfix: verbose output for replacing non-existing environment variables broken.
November 4, 2014 - bake-toolkit 1.7.0
    * Added: Option to define output directory relative/absolute for each project or for all projects.
    * Added: --set command line option to set variables
    * Added: Optional "Description" tag for projects in Project.meta
    * Changed: Variables in DefaultToolchain will be substituted separately for each project.
August 8, 2014 - bake-toolkit 1.6.3
    * Fixed: possible uninitialized variable could lead to crash bake
August 6, 2014 - bake-toolkit 1.6.2
    * Fixed: clear clearn- and clobber-lists at startup
    * Fixed: Variables not substituted in ArtifactName and ArtifactNameBase
    * Added: Cyclic variable substitution
August 5, 2014 - bake-toolkit 1.6.1
    * Added: Fixed variable substitution
August 1, 2014 - bake-toolkit 1.6.0
    * Added: The value of a variable can be the result of a command line
July 18, 2014 - bake-toolkit 1.5.0
    * Added: Dependencies can be overwritten in inherited projects
    * Removed: defines cannot be filtered anymore via command line
June 6, 2014 - bake-toolkit 1.4.0
    * Bugfix: variables can be used in "Set" now
    * Added: variable "MainProjectDir"
May 23, 2014 - bake-toolkit 1.3.0
    * Added: defines can be filtered now via command line
May 2, 2014 - bake-toolkit 1.2.1
    * Added: Set keyword for defining variables
    * Changed: "executed in"-output now in separate line
March 14, 2014 - bake-toolkit 1.1.0
    * Added: Lint support
    * Added: $(ProjectDir) variable
March 7, 2014 - bake-toolkit 1.0.27
    * Cosmetic: some pictures in documentation were missing
March 5, 2014 - bake-toolkit 1.0.26
    * Bugfix: in rare cases invalid characters from compiler output were not handled correctly
    * Bugfix: changing workspace roots on command line now always regenerates build tree
    * Added: Variable $(Roots) for IncludeDir directives
    * Changed: dependency files for all compilers will be generated inclusive system headers
    * Changed: abort earlier if main directory has no Project.meta
    * Changed: every environment variable is expanded to an empty string if not defined
January 21, 2014 - bake-toolkit 1.0.25
    * Added: configs can now be inherited
    * Added: command bake-doc opens bake doc
    * Changed: dependency files for Greenhills compiler will be generated with -MD instead of -MMD
September 10, 2013 - bake-toolkit 1.0.24
    * Changed: Improved Keil linker error parser.
September 9, 2013 - bake-toolkit 1.0.23
    * Added: Keil support.
    * Bugfix: minor fixes.
August 21, 2013 - bake-toolkit 1.0.22
    * Bugfix: Searching for project folders did not work correctly.
August 20, 2013 - Eclipse plugin 1.0.5.0
    * Bugfix: Adjust includes in CDT is working again after Java Update.
August 1, 2013 - bake-toolkit 1.0.21
    * Bugfix: projects folders which are junctions were not found anymore after the last update.
July 25, 2013 - bake-toolkit 1.0.20, Eclipse plugin 1.0.4.0
    * Added: projects can be placed more than one level below workspaces roots
June 21, 2013 - bake-toolkit 1.0.19
    * Added: support for GreenHills compiler.
May 29, 2013 - bake-toolkit 1.0.18
    * Bugfix: typo in require, which has broken bake in case sensitive file systems.
May 28, 2013 - bake-toolkit 1.0.17
    * Bugfix: error levels greater than 255 of external processes were not be recognized correctly in some cases.
May 16, 2013 - Eclipse plugin 1.0.2.0
    * Bugfix: bake did not start correctly with latest Java version installed.
April 22, 2013 - bake-toolkit 1.0.16
    * Changed: default roots of bakery are now directory of Collection.meta and it's parent directory.
April 19, 2013 - bake-toolkit 1.0.15
    * Bugfix: bakery could not build projects with spaces in oathname.
April 19, 2013 - bake-toolkit 1.0.13
    * Bugfix: some bake options specified on bakery command line were not accepted.
April 17, 2013 - bake-toolkit 1.0.12
    * Changed: Output folders are not deleted and rebuilt if no source files are available but the archive file.
    * Added: Option --clobber deletes .bake cache file.
    * Added: Collections can reference collections.
    * Added: collection names can be specified without typing "-b"
April 4, 2013 - bake-toolkit 1.0.11
    * Bugfix: Executing batch files in CommandLine on Windows were broken.
    * April 2, 2013 - bake-toolkit 1.0.10
    * Bugfix: options "--toolchain_names" now working as intended
    * Bugfix: default flags for makefiles (-j) no longer ignored
    * Changed: flags for makefiles are now defined in subtags instead in attributes to be consistent with other flag definitions
    * Added: ".." in Files and ExcludeFiles now allowed
    * Added: command line switch to turn off "directory magic"
    * Added: build config can be specified without typing "-b"
    * Cosmetic: better error output if compiler not found
March 22, 2013 - bake-toolkit 1.0.9
    * Cosmetic: Changed option --print_less to -v0 and -v to -v2. Default is -v1.
March 7, 2013 - bake-toolkit 1.0.8
    * Added: Linkerscript can be referenced from other projects
February 13, 2013 - bake-toolkit 1.0.7
    * Added: OS dependent variable $(/)
January 21, 2013 - bake-toolkit 1.0.6
    * Added: support for Visual Studio
January 15, 2013 - bake-toolkit 1.0.5
    * Changed: no indirect dependency to progressbar gem anymore
January 14, 2013 - bake-toolkit 1.0.4
    * Added: a new cache validation check.
January 2, 2013 - bake-toolkit 1.0.3
    * Bugfix: option to build a single file did not accept a filename with absolute path.
October 7, 2012 - bake-toolkit 1.0.2
    * Changed: Renamed gem from "bake" to "bake-toolkit".
September 18, 2012 - bake 1.0.1
    * Changed: bake now based on rgen 0.6.0 and rtext 0.2.0, which are available on rubygems.
August 31, 2012 - bake 1.0.0
    * First official release
