Prefix compiler, archiver and linker
====================================

Why
---

The most important reason is to use a compiler cache like ccache or sccache. This will improve your compilation times.

How to
------

You can wrap the compiler, archiver and linker by using the "prefix" element in Project.meta:

.. code-block:: text

    Compiler CPP, prefix: "sccache"
    ..

This can be also done via an adapt config:

.. code-block:: text

    Adapt {
      ExecutableConfig __MAIN__, project: __MAIN__, type: extend {
        DefaultToolchain {
          Compiler CPP, prefix: "some prefix"
        }
      }
    }

The defaults are $(CompilerPrefix), $(ArchiverPrefix) and $(LinkerPrefix), so you can also do something like this:

.. code-block:: text

    Set CompilerPrefix, value: "some other prefix"

Or simply define an environment variable in your system.
