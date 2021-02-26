The Syntax of the Project.meta file
===================================

Config types
************

Three config types exist: ExecutableConfig, LibraryConfig and CustomConfig. Some elements are only valid for specific types.

Filter
******

Every element (except the Project element) in Project.meta has two attributes:

- default: if set to "off", this element is not taken into account. Default is "on".
- filter: The element can be removed/added explicitly regardless of the "default" attribute with the command line options

  - --do "filter name"
  - --omit "filter name"

Example:

.. code-block:: console

    PostSteps {
      CommandLine "$(OutputDir)/$(ArtifactName)", filter: run, default: off
    }

The executable is not executed by default unless "run" is specified on command line:

.. code-block:: console

    bake ... --do run

Notes
*****

- Specify the paths always relative to the current project root.
- Keep the variable substitution in Project.meta in mind.
- Use double quotes (") if the strings have spaces or slashes.
- Use hash marks (#) for comments.

Syntax
******

.. parsed-literal::

    :ref:`project` :ref:`default <defaultConfig>`: <name> {

      :ref:`description` <text>

      :ref:`requiredBakeVersion` minimum: <major.minor.patch>, maximum: <major.minor.patch>

      :ref:`responsible` {
        :ref:`person` <name>, :ref:`email`: <adr>
      }

      # 0..n configs
      :ref:`executableConfig` | :ref:`libraryConfig` | :ref:`customConfig` <name>, :ref:`extends`: <parent(s)>,
        :ref:`mergeInc`: yes|no, :ref:`private`: true|false {

        # Valid for all config types

        :ref:`description` <text>
        :ref:`includeDir` <dir>, :ref:`inherit`: true|false, :ref:`inject`: front|back, :ref:`system`: true|false
        :ref:`set` <variable>, value: <value> | cmd: <line>, :ref:`env`: true|false
        :ref:`Dependency` <project>, :ref:`config <configDependency>`: <name>
        :ref:`externalLibrary` <lib>, :ref:`searchExternalLibrary`: true|false
        :ref:`userLibrary` <lib>
        :ref:`externalLibrarySearchPath` <path>
        :ref:`preSteps` {
          :ref:`makefile` <file>, :ref:`makefileLib`: <lib>, :ref:`makefileTarget`: <target>, :ref:`makefilePathTo`: <paths>, :ref:`makefileNoClean`: true|false,
            :ref:`makefileChangeWorkingDir`: true|false, :ref:`echo <echoNonFileUtils>`: on|off, :ref:`independent`: true|false, :ref:`validExitCodes`: <[array]> {
            :ref:`Flags <makefileFlags>` <flags>
          }
          :ref:`commandLine` <line>, :ref:`echo <echoNonFileUtils>`: on|off, :ref:`independent`: true|false, :ref:`validExitCodes`: <[array]>
          :ref:`sleep` <seconds>, :ref:`echo <echoNonFileUtils>`: on|off, :ref:`independent`: true|false
          :ref:`makeDir` <directory>, :ref:`echo <echoFileUtils>`: on|off
          :ref:`remove` <file or directory>, :ref:`echo <echoFileUtils>`: on|off
          :ref:`touch` <file or directory>, :ref:`echo <echoFileUtils>`: on|off
          :ref:`copy` <file or directory>, to: <file or directory>, :ref:`echo <echoFileUtils>`: on|off
          :ref:`move` <file or directory>, to: <file or directory>, :ref:`echo <echoFileUtils>`: on|off
        }
        :ref:`postSteps` {
          # Same as for PreSteps
        }
        :ref:`startupSteps` {
          # Same as for PreSteps
        }
        :ref:`exitSteps` {
          # Same as for PreSteps
        }
        :ref:`cleanSteps` {
          # Same as for PreSteps
        }
        :ref:`defaultToolchain` <basedOn>, :ref:`outputDir`: <dir>, :ref:`outputDirPostfix`: <postfix>,
          :ref:`eclipseOrder`: true|false {
          :ref:`compiler` ASM | CPP | C, :ref:`command`: <cmd>, :ref:`prefix`: <prefix>, :ref:`keepObjFileEndings`: true|false {
            :ref:`Flags <defaultFlags>` <flags>
            :ref:`Flags <defaultDefine>` <define>
            :ref:`internalDefines` <file>
            SrcFileEndings <endings>
          }
          :ref:`archiver` :ref:`command`: <cmd>, :ref:`prefix`: <prefix> {
            :ref:`Flags <defaultFlags>` <flags>
          }
          :ref:`linker` :ref:`command`: <cmd>, :ref:`prefix`: <prefix>, :ref:`onlyDirectDeps`: true|false {
            :ref:`Flags <defaultFlags>` <flags>
            :ref:`libPrefixFlags` <flags>
            :ref:`libPostfixFlags` <flags>
          }
          :ref:`internalIncludes` <file>
          :ref:`docu` <cmdLine>
        }
        :ref:`toolchain` :ref:`outputDir`: <dir>, :ref:`outputDirPostfix`: <postfix> {
          :ref:`compiler` ASM | CPP | C, :ref:`command`: <cmd>, :ref:`cuda`: true|false, :ref:`prefix`: <prefix> {
            :ref:`Flags <toolchainFlags>` <flags>, add: <flags>, remove: <flags>
            :ref:`Flags <toolchainDefine>` <define> <define>
            :ref:`srcFileEndings` <file>
          }
          :ref:`archiver` :ref:`command`: <cmd>, :ref:`prefix`: <prefix> {
            :ref:`Flags <toolchainFlags>` <flags>, add: <flags>, remove: <flags>
          }
          :ref:`linker` :ref:`command`: <cmd>, :ref:`prefix`: <prefix>, :ref:`onlyDirectDeps`: true|false {
            :ref:`Flags <toolchainFlags>` <flags>, add: <flags>, remove: <flags>
            :ref:`libPrefixFlags` <flags>, add: <flags>, remove: <flags>
            :ref:`libPostfixFlags` <flags>, add: <flags>, remove: <flags>
          }
          :ref:`docu` <cmdLine>
        }
        :ref:`prebuild` {
            :ref:`except` <project>, :ref:`config <configExcept>`: <name>
        }
        :ref:`compilationDB` <filename>
        :ref:`compilationCheck` include: <pattern> exclude: <pattern> ignore: <pattern>

        # Valid for ExecutableConfig and LibraryConfig

        :ref:`files` <pattern>, :ref:`compileOnly`: true|false, :ref:`linkDirectly`: true|false {
          :ref:`Flags <filesFlags>` <define> <flags>, add: <flags>, remove: <flags>
          :ref:`Flags <filesDefine>` <define>
        }
        :ref:`excludeFiles` <pattern>
        :ref:`artifactName` <name>
        :ref:`artifactExtension` <ext>

        # Valid for ExecutableConfig

        :ref:`linkerScript` <script>
        :ref:`mapFile` <name>


        # Valid for CustomConfig

        :ref:`makefile` | :ref:`commandLine` | :ref:`sleep` | :ref:`makeDir` | :ref:`remove` | :ref:`touch` | :ref:`copy` | :ref:`move` ... # zero of one of these

      }
    }

    Adapt toolchain: <name>, os: <name>, mainProject: <name>, mainConfig: <name> {
      # See Adapt documention for details.
    }

.. _project:

Project
-------

| A bake project is very similar to a project in Eclipse, Visual Studio, etc.
| The name of the project is the directory name of the Project.meta file.

*Mandatory: yes, quantity: 1, default: -*

.. _defaultConfig:

default (Project)
-----------------

Attribute of :ref:`project`.

Default configuration which is used if not explicitly specified on command line or Dependency definition.

Examples::

    # Project.meta:
    Dependency canDriver # uses default config of canDriver project
    # Command line:
    bake -m folder/dir/projABC # builds default config of project projABC

*Mandatory: no, quantity: 0..1, default: -*

.. _description:

Description
-----------

Description of the project or config.

*Mandatory: no, quantity: 0..1, default: -*

.. _requiredBakeVersion:

RequiredBakeVersion
-------------------

| If specified, the build will be aborted if bake version is lower than mininum or greater than maximum.
| It is possible to define only minimum, only maximum or both version thresholds.
| Minor and patch version numbers are optional.

*Mandatory: no, quantity: 0..1, default: -*

.. _responsible:

Responsible
-----------

Specify all responsible persons of the project.

*Mandatory: no, quantity: 0..1, default: -*

.. _person:

Person
------

Person who is responsible for the project.

*Mandatory: no, quantity: 0..1, default: -*

.. _email:

email
-----

Attribute of :ref:`person`.

Use always double quotes (") for the email address.

*Mandatory: no, quantity: 0..1, default: -*

.. _executableConfig:

ExecutableConfig
----------------

This is usually the main config of an application.

*Mandatory: no, quantity: 0..n, default: -*


.. _libraryConfig:

LibraryConfig
-------------

This config is used for a source library. The library will be linked automatically to the executable.

*Mandatory: no, quantity: 0..n, default: -*

.. _customConfig:

CustomConfig
------------

| This config is used for special projects, e.g. for Makefile projects.
| It's valid to leave a CustomConfig completely empty - nothing will be done in that case.

*Mandatory: no, quantity: 0..n, default: -*

.. _extends:

extends
-------

Attribute of :ref:`executableConfig`, :ref:`libraryConfig` or :ref:`customConfig`.

Inherit settings from parent config(s). For more information see docu page :doc:`derive_configs`.

*Mandatory: no, quantity: 0..1, default: -*

.. _mergeInc:

mergeInc
--------

Attribute of :ref:`executableConfig`, :ref:`libraryConfig` or :ref:`customConfig`.

| If set to "no", the IncludeDirs will NEVER be merged.
| If set to "yes", inherited IncludeDirs will merged when compiling this config except for IncludeDirs which configs have mergeInc.
| If set to "all", all IncludeDirs will merged when compiling this config except for IncludeDirs which configs have mergeInc.
| If unset, IncludeDirs will not be merged when compiling this config.

See also :doc:`../concepts/merge`.

*Mandatory: no, quantity: 0..1, default: <unset>*

.. _private:

private
-------

Attribute of :ref:`executableConfig`, :ref:`libraryConfig` or :ref:`customConfig`.

If true, the config cannot be referenced directly outside of this project.

*Mandatory: no, quantity: 0..1, default: false*

.. _includeDir:

IncludeDir
----------

Specifies the include directories for the assembler, C and C++ compiler.

Use always relative paths, not absolute paths due to portability.

Use always "/" and not "\\".

| It is possible to work with different workspace roots. Do not include something like this:
| *IncludeDir "../abc/include"*
| but
| *IncludeDir "abc/include"*
| because it may happen, that abc does not exist in the same root as the current project. The path to abc will be calculated automatically.

| To include directories of the current project, the project name can be omitted like this:
| *IncludeDir "include"*
| *IncludeDir "generated/include"*

*Mandatory: no, quantity: 0..n, default: -*

.. _inherit:

inherit
-------

Attribute of :ref:`includeDir`.

Inherits the include to all projects, which depend on this project.

*Mandatory: no, quantity: 0..1, default: false*

.. _inject:

inject
------

Attribute of :ref:`includeDir` or :ref:`dependency`.

Injects the element to all childs, either at the front (e.g. for mocking code) or at the back.

Avoid to inject dependencies, it will get a mess.

*Mandatory: no, quantity: 0..1, default: -*

.. _system:

system
------

Attribute of :ref:`includeDir`.

| If supported from the compiler, the system include flag will be used instead of the normal include flag.
| For example in gcc "-isystem" instead of "-I" is used.
| Note: system include definition overrules normal include definition if both are defined.

*Mandatory: no, quantity: 0..1, default: false*

.. _set:

Set
---

| Sets a variable for this and all dependent projects.
| The variable can be a simple value or the result of a cmd, e.g. "cat myVar.txt".

*Mandatory: no, quantity: 0..n, default: -*

.. _env:

env
---

Attribute of :ref:`set`.

Stores the variable also in system environment, which makes it available in everything which is executed by bake, e.g. in Pre- and PostSteps.

*Mandatory: no, quantity: 0..1, default: false*

.. _dependency:

Dependency
----------

| Specifies another project to be built before this project.
| The archives, linker libs and search paths are inherited from this project automatically.

| If you omit the project, the current project will be used.
| If you omit the config name, the default config will be used.

| Examples:
| *Dependency gtest, config: lib*
| *Dependency "my/folder/proj"*

*Mandatory: no, quantity: 0..n, default: -*

.. _configDependency:

config (Dependency)
-------------------

Attribute of :ref:`dependency`.

Config name of the dependent project.

*Mandatory: no, quantity: 0..1, default: <default config of the dependent project>*


.. _externalLibrary:

ExternalLibrary
---------------

| Every config can specify libs which have to be linked to the executable.
| It's possible to add a path, e.g.:
| *ExternalLibrary "xy/z/ab"*
| In this case the lib "ab" is added to the linker command line as well as the lib search path "xy/z".
| Note, that the linker will look for "libab.a".'

*Mandatory: no, quantity: 0..n, default: -*

.. _searchExternalLibrary:

search
------

Attribute of :ref:`externalLibrary`.

| If the attribute "search: false" is specified, the lib will not be searched but linked with the full name, e.g.
| *ExternalLibrary "xy/z/libpq.a", search: false*
| will link "xy/z/libpq.a" to the executable.
| It's also possible to specify an object file when using "search: false".

*Mandatory: no, quantity: 0..n, default: -*

.. _userLibrary:

UserLibrary
-----------

| A user library will be linked *before* any other libraries or objects to the executable.
| It is also possible to specify an object file.
| The library will be searched like an ExternalLibrary, but with the full name, e.g.
| *UserLibrary "xy/z/libUser.a"*
| *UserLibrary "xy/z/something.o"*
| will link "libUser.a" and "something.o" before regular objects and libraries.
| "xy/z" will be added as an ExternalLibrarySearchPath.

*Mandatory: no, quantity: 0..n, default: -*

.. _externalLibrarySearchPath:

ExternalLibrarySearchPath
-------------------------

| The linker looks for libraries in search paths.
| Search paths can be defined implicitly by ExternalLibrary/UserLibrary or explicitly by this tag.

*Mandatory: no, quantity: 0..n, default: -*

.. _preSteps:

PreSteps
--------

| PreSteps are executed before compiling files of the config.
| The number of steps is not limited.
| If a step fails, all further steps of the config will be skipped.

*Mandatory: no, quantity: 0..1, default: -*

.. _postSteps:

PostSteps
---------

| PostSteps are executed after the main task of the project, e.g. linking an executable.
| The number of steps is not limited.
| If a step fails, all further steps of the config will be skipped.

*Mandatory: no, quantity: 0..1, default: -*

.. _startupSteps:

StartupSteps
------------

| StartupSteps of ALL configs are executed before building the first config.
| The number of steps is not limited.

*Mandatory: no, quantity: 0..1, default: -*

.. _exitSteps:

ExitSteps
---------

| ExitSteps of ALL configs are executed after building complete workspace even if the build has failed.
| The number of steps is not limited.

*Mandatory: no, quantity: 0..1, default: -*

.. _cleanSteps:

CleanSteps
----------

| CleanSteps are executed when calling bake with "-c" or "--rebuild".
| The number of steps is not limited.
| If a step fails, all further steps will be skipped.

*Mandatory: no, quantity: 0..1, default: -*





.. _makefile:

Makefile
--------

Makefile to be started, e.g.: *Makefile "subDir/makefile"*

Before executing the makefile, bake sets the environment variables $(BAKE_XX_COMMAND) and $(BAKE_XX_FLAGS),
whereas XX is one of CPP, C, ASM, AR or LD.

*Mandatory: no, quantity in steps: 0..n, quantity in CustomConfig: 0..1, default: -*

.. _makefileLib:

lib
---

Attribute of :ref:`makefile`.

If the result of the makefile is a library which shall be linked to the executable, name it here.

*Mandatory: no, quantity: 0..1, default: -*

.. _makefileTarget:

target
------

Attribute of :ref:`makefile`.

The target of the makefile.

*Mandatory: no, quantity: 0..1, default: all*

.. _makefilePathTo:

pathTo
------

Attribute of :ref:`makefile`.

| Comma separated list, e.g. "common, abc, xy".
| The makefile can use variables like $(PATH_TO_common). This is very useful if paths to other projects are needed in the makefile.
| Remember that more than one workspace root can exist and a hardcoded "../common" is not reliable in that case.
| $(PATH_TO_common) will result in the path from the parent directory of the current project to the common project without the common directory itself.
| If the current project and the common project have the same parent folder, the string will be empty.
| Example:
| makefile: *c:\\workspaceroot\\yourProject\\makefile*
| usage in makefile: *gcc -I$../../$(PATH_TO_common)common/include ...*

*Mandatory: no, quantity: 0..1, default: -*

.. _makefileNoClean:

noClean
-------

Attribute of :ref:`makefile`.

If project is cleaned (e.g. with command line argument -c), the target "clean" will be executed unless noClean is set to true.

*Mandatory: no, quantity: 0..1, default: false*

.. _makefileChangeWorkingDir:

changeWorkingDir
----------------

Attribute of :ref:`makefile`.

If set to false, the working directory will be the project directory instead of the makefile directory.

*Mandatory: no, quantity: 0..1, default: true*

.. _echoNonFileUtils:

echo (CommandLine, Makefile, Sleep)
-----------------------------------

Attribute of :ref:`makefile`, :ref:`commandLine` and :ref:`sleep`.

"on" means the command line is shown in output, "off" means the command line is not shown.

*Mandatory: no, quantity: 0..1, default: on*

.. _independent:

independent
-----------

Attribute of :ref:`makefile`, :ref:`commandLine` and :ref:`sleep`.

| "true" means the step can be built in parallel to other projects.
| "false" means everything before must be completed, the step runs exclusively.

*Mandatory: no, quantity: 0..1, default: false*

.. _validExitCodes:

validExitCodes
--------------

Attribute of :ref:`makefile` and :ref:`commandLine`.

| Define it as an array, e.g.:
| *..., validExitCodes: [200,201,202]*

*Mandatory: no, quantity: 0..1, default: [0]*

.. _makefileFlags:

Flags (makefile)
----------------

Additional makefile flags.

*Mandatory: no, quantity: 0..n, default: -j*

.. _commandLine:

CommandLine
-----------

A command to execute, e.g.:

.. code-block:: console

    CommandLine "ddump -Ruv -y 0xFFFFF -oRelease/application.bin Release/application.elf"
    CommandLine "echo Hello world!"

The command line string cannot be wrapped into multiple lines. If the command line gets long and
unreadable, use an array to split the string, e.g.

.. code-block:: console

    CommandLine ["myCommand --which is --very",
                 "--long and --can be splitted"]

The array is internally joined to an string again with spaces in between.

*Mandatory: no, quantity in steps: 0..n, quantity in CustomConfig: 0..1, default: -*

.. _sleep:

Sleep
-----

Sleep in seconds, floats are allowed.

*Mandatory: no, quantity: 0..n, default: 0.0*

.. _makeDir:

MakeDir
-------

A file or folder will be created.

*Mandatory: no, quantity: 0..n, default: -*

.. _remove:

Remove
------

A file or folder will be removed.

*Mandatory: no, quantity: 0..n, default: -*

.. _touch:

Touch
-----

A file or folder will be touched.

*Mandatory: no, quantity: 0..n, default: -*

.. _copy:

Copy
----

A file or folder will be moved.

*Mandatory: no, quantity: 0..n, default: -*

.. _move:

Move
----

A file or folder will be copied.

*Mandatory: no, quantity: 0..n, default: -*


.. _echoFileUtils:

echo (MakeDir, Remove, Touch, Copy, Move)
-----------------------------------------

Attribute of :ref:`makeDir`, :ref:`remove`, :ref:`touch`, :ref:`copy` and :ref:`move`.

"on" means a debug output is shown.

*Mandatory: no, quantity: 0..n, default: on*

.. _defaultToolchain:

DefaultToolchain
----------------

| Settings which are valid for all configs unless they will be overwritten.
| The attribute "basedOn" specifies the basic toolchain configuration provided by bake, e.g. "GCC", "Diab", etc.

*Mandatory: in main config, quantity: 1, default: -*

.. _toolchain:

Toolchain
---------

Toolchain settings for a specific config.'

*Mandatory: no, quantity: 0..1, default: the DefaultToolchain settings from the main config*

.. _outputdir:

outputdir
---------

Attribute of :ref:`defaultToolchain` and :ref:`toolchain`.

| Specifies the output folder.
| Use always relative paths, not absolute paths due to portability.
| Use always "/" and not "\\".

| If the first part of the path is equal to a project name, it is used as a shortcut to this project root.
| To avoid this magic, use something like this:
| *IncludeDir "./abc/include"*

| *Mandatory: no, quantity: 0..1,*
| *default for main config: <project root>/build/<configName>,*
| *default for every other config: <project root>/build/<configName>_<mainProjectName>_<mainConfigName>*

.. _outputdirPostfix:

outputdirPostfix
----------------

Attribute of :ref:`defaultToolchain` and :ref:`toolchain`.

| Specifies a postfix for the output folder.

| It's intended to be used by special builds like MISRA checks.

*Mandatory: no, quantity: 0..1,, default: -*

.. _eclipseOrder:

eclipseOrder
------------

Attribute of :ref:`defaultToolchain`.

| If not specified or false, all files are compiled in order of appearance in Project.meta.
| If the filename is a glob pattern, files are sorted alphabetically.

| If true, files are compiled in alphabetical order within a folder, but the folders are sorted in reverse alphabetical order.
| This is only used for backward compatibility. Will be removed in future.

*Mandatory: no, quantity: 0..1, default: false*

.. _compiler:

Compiler
--------

Flags and defines can be specified independently for each compiler type (ASM, CPP, C).

*Mandatory: no, quantity: 0..3, default: -*

.. _archiver:

Archiver
--------

Settings for the archiver.

*Mandatory: no, quantity: 0..1, default: -*

.. _linker:

Linker
------

Settings for the linker.

*Mandatory: no, quantity: 0..1, default: -*

.. _docu:

Docu
----

Command to build the documentation. e.g.: *doxygen main.cfg*

*Mandatory: no, quantity: 0..1, default: -*

.. _command:

command
-------

Attribute of :ref:`compiler`, :ref:`archiver`, :ref:`linker`.

Changes the predefined command, e.g. "gcc".

*Mandatory: no, quantity: 0..1, default: -*

.. _prefix:

prefix
------

Attribute of :ref:`compiler`, :ref:`archiver`, :ref:`linker`.

| Wrapper for the command, e.g. a (s)ccache.
| If variable is not set, no prefix is used.
| You can use the adapt feature to set the variable or overwrite the prefix.

*Mandatory: no, quantity: 0..1, default: $(CompilerPrefix), $(ArchiverPrefix) or $(LinkerPrefix)*

.. _keepObjFileEndings:

keepObjFileEndings
------------------

Attribute of :ref:`compiler`.

If false, the original source file endings will be cut off (e.g. file1.cpp to file1.o), otherwise kept (file1.cpp.o).

*Mandatory: no, quantity: 0..1, default: false*

.. _srcFileEndings:

SrcFileEndings
--------------

List of all source file endings with dot and comma separated which are handled by this CPP, C or ASM compiler,
e.g. ".cpp, .c, .cxx". The list must not be empty.

*Mandatory: no, quantity: 0..1, default: -*

.. _onlyDirectDeps:

onlyDirectDeps
--------------

Attribute of :ref:`linker`.

If set to true, only first level libraries will be linked (not sub-dependencies from dependencies).

*Mandatory: no, quantity: 0..1, default: false*

.. _cuda:

cuda
----

Attribute of :ref:`compiler`.

| Enables Cuda hack.
| Adds some prefixes in front of dependency flags.

*Mandatory: no, quantity: 0..1, default: false*

.. _defaultFlags:

Flags (DefaultToolchain)
------------------------

Default flags.

*Mandatory: no, quantity: 0..n, default: -*

.. _toolchainFlags:

Flags (Toolchain)
-----------------

Flags from the DefaultToolchain can be overwritten, extended or (partly) removed.

| For removing flags use plain strings or regular expressions which can be interpreted by ruby (both is checked).
| Flags will be only removed if matching completely (not only a substring).
| Flag strings are always splitted at spaces and computed individually.

| Examples:
| *Flags "-x -y"* overwrites the inherited flags
| *Flags add: "-x -y"* adds -x and -y if not exist
| *Flags remove: "-x -y"* removes -x and -y if exist
| It is possible to combine the attributes like this:
| *Flags remove: "-x", add: "-y"*
| To remove -g followed by any string, e.g. -g3, the command is:
| *Flags remove: "-g.\*"*
| An inherited flag string "-abc -g3 -xy" will end up in "-abc -xy".

*Mandatory: no, quantity: 0..n, default: Flags from DefaultToolchain"*

.. _filesFlags:

Flags (Files)
-------------

Flags from the Toolchain can be overwritten, extended or (partly) removed, see above.

*Mandatory: no, quantity: 0..n, default: -*

.. _defaultDefine:

Define (DefaultToolchain)
-------------------------

Defines which are valid for all files.

*Mandatory: no, quantity: 0..n, default: -*

.. _toolchainDefine:

Flags (Toolchain)
-----------------

Defines which are valid for the files of this config.

*Mandatory: no, quantity: 0..n, default: -*

.. _filesDefine:

Define (Files)
--------------

Defines which are valid only for these specific files.

*Mandatory: no, quantity: 0..n, default: -*

.. _libPrefixFlags:

LibPrefixFlags
--------------

Linker libs can be prefixed if needed, e.g. with "-Wl,--whole-archive".

*Mandatory: no, quantity: 0..n, default: -*

.. _libPostfixFlags:

LibPostfixFlags
---------------

Linker libs can be postfixed if needed, e.g. with "-Wl,--no-whole-archive".

*Mandatory: no, quantity: 0..n, default: -*

.. _internalDefines:

InternalDefines
---------------

| File with list of compiler internal defines.
| One define per line.
| Empty lines and comments with # are allowed.

*Mandatory: no, quantity: 0..1, default: -*

.. _internalIncludes:

InternalIncludes
----------------

| File with list of compiler internal include folders.
| One folder per line.
| Empty lines and comments with # are allowed.

*Mandatory: no, quantity: 0..1, default: -*

.. _files:

Files
-----

| Specifies the files to build.
| It's valid to specify a single file, e.g.
| *Files "src/abc/def.asm"*
| or a pattern, e.g.
| *Files "\*/\*\*/.cpp"*
| which builds all files with the ending ".cpp" in all subdirectories.
| Note: ".." is not allowed in the file path. All files must be located within the project.

*Mandatory: no, quantity: 0..n, default: -*

.. _excludeFiles:

ExcludeFiles
------------

| Used to ignore files or directories.
| ExcludeFiles has higher priority than Files.

*Mandatory: no, quantity: 0..n, default: -*

.. _compileOnly:

compileOnly
-----------

Attribute of :ref:`files`.

If set to true, the files will not be archived or linked.

*Mandatory: no, quantity: 0..1, default: false*

.. _linkDirectly:

linkDirectly
------------

Attribute of :ref:`files`.

If set to true, the files will not be archived but linked directly to the executable.

*Mandatory: no, quantity: 0..1, default: false*

.. _prebuild:

Prebuild
--------

| If defined, all configs of the workspace will be skipped per default.
| Must be activated by the commandline option "--prebuild".

*Mandatory: no, quantity: 0..1, default: No project/config is skipped*

.. _except:

Except
------

Defines a project which shall not be skipped. If project name is omitted, the current project is used.

*Mandatory: no, quantity: 0..n, default: Every project is skipped*

.. _configExcept:

config (Except)
---------------

Attribute of :ref:`except`.

Defines a config which shall not be skipped. If omitted, all configs of the appropriate project are not skipped.

*Mandatory: no, quantity: 0..1, default: Every config is skipped*

.. _compilationDB:

CompilationDB
-------------

| Generates a compilation database in json.
| Example:
| *CompilationDB "$(ProjectDir)/db.json"*

*Mandatory: no, quantity: 0..1, default: None. If CompilationDB is specified without an explicit filename, $(WorkspaceDir)/compile_commands.json is used.*

.. _compilationCheck:

CompilationCheck
----------------

| Checks if files are included or excluded in build.
| Priority if files are mentioned multiple times: ignore > exclude > include.
| In case a check fails, bake will print a warning.
| Examples:
| *CompilationCheck include: "include/\*.h", ignore: "include/ignoreThis.h"*
| *CompilationCheck include: "$(ProjectDir, anotherLib)/src/important"*

*Mandatory: no, quantity: 0..n, default: -*

.. _linkerScript:

LinkerScript
------------

Specifies the name including path of the linker script.

*Mandatory: no, quantity: 0..1, default: -*

.. _mapFile:

MapFile
-------

| A mapfile will be written by the linker.
| If name attribute is omitted, the mapfile will be "$(OutputDir)/$(ArtifactNameBase).map".

*Mandatory: no, quantity: 0..1, default: No mapfile will be written*

.. _artifactName:

ArtifactName
------------

| The artifact name inclusive file ending.
| The artifact will be placed in the output directory.

*Mandatory: no, quantity: 0..1, default executable: project name + toolchain dependent file ending, default library: 'lib' + project name + '.a'*

.. _artifactExtension:

ArtifactExtension
-----------------

| The artifact extension, e.g. "exe".
| If ArtifactName is also specified, ArtifactExtension has no effect.

*Mandatory: no, quantity: 0..1, default: toolchain dependent file ending*
