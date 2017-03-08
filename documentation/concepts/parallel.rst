Parallel build
******************************************************

Since the beginning of bake, files within a project will be built in parallel. The number of threads can be defined on command line via the "-j" parameter. "-j 8" is the default.

Since bake 2.33.0, **projects are built also in parallel**. Note: if there is a CommandLine/Makefile step or an ExecutableConfig, the build will not proceed until all stuff prior to this has been finished.

To synchronize the output, use the parameter "-O".

Example:
--------

ExecutableConfig A depends on libraries B and C (without any additional steps).

.. code-block:: console

    # project C
    ExecutableConfig ... {
      Dependency A
      Dependency B
      ...
    }

This means all files of A, B and C can be built in parallel. When all files of A/B have been successfully compiled,
the archive of A/B can be created in parallel with the other archive and the remaining files) . When **everything has been finished**, C can be linked.

Example:
--------

Same as above, but B has be PreStep (e.g. to generate something).

.. code-block:: console

    # project B
    LibraryConfig ... {
      ...
      PreSteps {
        CommandLine ...
      }
    }


First project A will be built completely. After the PreStep of B has been executed,
the files of projects B/C can be built in parallel. Rest is the same as above.
