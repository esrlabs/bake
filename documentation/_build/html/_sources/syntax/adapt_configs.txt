Adapt configs
==============

bake supports deriving configs, which allows you to put repetetive settings in a base config.

Adapting a config
*****************

Derving a config in bake is pretty straight forward, and looks like this:

.. code-block:: text

    ExecutableConfig A
    LibraryConfig    B, extends: A
    CustomConfig     C, extends: B
    ExecutableConfig D, extends: C

.. note::

    The config type of the parent config does not matter, but only settings which are valid in BOTH configs will be inherited.
    In the example above D gets the dependencies from A, because "Dependency" is valid in all configs, but D does not get 
    the "Files" from A, because "Files" is not valid in CustomConfig.


Inheritance implications
************************

============================        =========================================
Setting                             Derived
============================        =========================================
Set                                 parent + child

Dependency                          parent + child

ExternalLibrary                     parent + child
                                    (ordered by line number)

ExternalLibrarySearchPath           parent + child
                                    (ordered by line number)

UserLibrary                         parent + child
                                    (ordered by line number)

PreSteps                            parent + child

PostSteps                           parent + child

Makefile                            used from parent if not 
                                    in child

CommandLine                         used from parent if not
                                    in child 

Files                               parent + child

ExcludeFiles                        parent + child

IncludeDir                          parent + child

LinkerScript                        used from parent if not in child

ArtifactName                        used from parent if not in child

MapFile                             used from parent if not in child
============================        =========================================


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

