Parallel build
******************************************************

Files within a project will be built in parallel. The number of threads can be defined on command line via the "-j" parameter. "-j8" is the default.

Since bake 2.33.0, **projects are built also in parallel**.

Note: if there is a CommandLine/Makefile step or an ExecutableConfig, the build will not proceed until all stuff prior to this has been finished. Exception: CommandLine/Makefile have an attribute "independent: true".

To synchronize the output, use the parameter "-O".

Example:
--------

ExecutableConfig A depends on libraries B and C (without any additional steps).

.. code-block:: console

    # project A
    LibraryConfig ... {
      ...
    }

    # project B
    LibraryConfig ... {
      ...
    }

    # project C
    ExecutableConfig ... {
      Dependency A
      Dependency B
      ...
    }

A, B and C can be built in parallel, at the end C is linked.

Example:
--------

Same as above, but B has a PreStep (e.g. to generate something).

.. code-block:: console

    # project A
    LibraryConfig ... {
      ...
    }

    # project B
    LibraryConfig ... {
      ...
      PreSteps {
        CommandLine ...
      }
    }

    # project C
    ExecutableConfig ... {
      Dependency A
      Dependency B
      ...
    }

First, project A will be built completely. After the PreStep of B has been executed,
the files of projects B/C can be built in parallel. At the end, C is linked.

Example:
--------

B has a PostStep instead of a PreStep.

.. code-block:: console

    # project A
    LibraryConfig ... {
      ...
    }

    # project B
    LibraryConfig ... {
      ...
      PostSteps {
        CommandLine ...
      }
    }

    # project C
    ExecutableConfig ... {
      Dependency A
      Dependency B
      ...
    }

First project A will be built completely. In parallel the library of B will be built, but the PostStep is not executed before A is completed and the library of B is created.
Then C is built and linked.

Example:
--------

PostStep of B is independent:

.. code-block:: console

    # project A
    LibraryConfig ... {
      ...
    }

    # project B
    LibraryConfig ... {
      ...
      PostSteps {
        CommandLine ..., independent: true
      }
    }

    # project C
    ExecutableConfig ... {
      Dependency A
      Dependency B
      ...
    }

A, B and C can be built in parallel, at the end C is linked.
