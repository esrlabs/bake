Changelog
=========

January 14, 2015 - bake-toolkit 2.14.0
    * Added: possibility to change configs via command line, e.g. changing compiler, see "adapt" docu page
    * Changed: extending configs in a Project.meta file made more generic, see "derive" docu page
    * Changed: default order of filenames changed, now order in Project.meta has the highest priority. Results of glob patterns are sorted alphabetically as before.
    * Changed: libraries from makefiles now are linked after other libraries defined from the same config
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
    * Bugfix: relative pathes between roots based on Roots.bake were calculated incorrectly
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
