Adapt configs
==============

If you want to manipulate existing configs without changing them, you can "adapt" them via command line.

.. code-block:: console

    User@Host:~$ bake test --adapt abc

bake searched for abc/Adapt.meta within the workspace roots. If found the configs from the adapt file are parsed:

.. code-block:: text

    Adapt {
      ExecutableConfig ... # 0..n
      LibraryConfig ... # 0..n
      CustomConfig ... # 0..n
    }

Here is an example to change the DefaultToolchain

.. code-block:: text

    Adapt {
      ExecutableConfig test, project: __MAIN__, type: replace {
        DefaultToolchain GCC
      }
    }

The adapt configs can be applied to all configs from regular build. This can be controlled by the config names and the project attribute. The exaxmple above
is adapted only the to config "test" of the main project. __MAIN__ and __ALL__ are keywords here. __MAIN__ means the main project or config, __ALL__ means all
projects or configs. If you want to apply the changes only to the top level config, write:

.. code-block:: text

      ExecutableConfig __MAIN__, project: __MAIN__, ...

If you want to apply the changes to all configs, write:

.. code-block:: text

      ExecutableConfig __ALL__, project: __ALL__, ...

It is possible to mix the keywords with reals project or config names.

The type of the config influences the the adaption. Only contents which are valid in the original config and the adapt config are changed. For example
"Dependency"s are changed regardless the types, because "Dependency"s are valid in every config. "ArtifactName" will only bee adapted if both configs are
ExecutableConfigs. Well, this should be very obvious.

It is possible to specify the type of adaption:

.. code-block:: text

      ExecutableConfig ..., type: replace
    
The type can be "replace", "remove" or "extend". See the table below how this works in detail.

You can specify more configs in one adapt file and you can specify more than one adapt file:

.. code-block:: text

    Adapt {
      ExecutableConfig ..., project: ..., type: ... {
        ...
      }
      ExecutableConfig ..., project: ..., type: ... {
        ...
      }
      LibraryConfig ..., project: ..., type: ... {
        ...
      }
      ...
    }


.. code-block:: console

    User@Host:~$ bake test --adapt abc --adapt xy


Type: remove
************

Note, that only parts of the attributes are evaluated to decide, if content shall be removed.

==============================        =================================================
Setting                               When removed
==============================        =================================================
Toolchain (completely)                If existing in adapt config

DefaultToolchain (completely)         If existing in adapt config

StartupSteps                          Steps are separately, see Makefile/CommandLine 

PreSteps                              Steps are separately, see Makefile/CommandLine 

PostSteps                             Steps are separately, see Makefile/CommandLine 

ExitSteps                             Steps are separately, see Makefile/CommandLine 

Dependency                            If project name and name matches

ExternalLibrary                       If name matches

ExternalLibrarySearchPath             If path matches

UserLibrary                           If name matches

Set                                   If variable name matches
									
Files                                 If filename or glob pattern matches

ExcludeFiles                          If filename or glob pattern matches

IncludeDir                            If include dir matches

LinkerScript                          If name matches

ArtifactName                          If name matches

MapFile                               If name matches

MapFile                               If name matches

Makefile                              If makefile name matches
                                    
CommandLine                           If commandline matches

==============================        =================================================



============================        =========================================
Toolchain Setting                   Derived
============================        =========================================
basedOn                             used from parent if not in child

outputDir                           used from parent if not in child

command                             used from parent if not in child

LibPrefixFlags                      parent + child

LibPostfixFlags                     parent + child

Flags                               parent + child

Define                              parent + child

InternalDefines                     used from parent if not in child

InternalIncludes                    used from parent if not in child

LintPolicy                          parent + child

Docu                                used from parent if not in child
============================        =========================================

