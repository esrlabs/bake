Adapt configs
=============

Introduction
************

If you want to manipulate existing configs without changing them, you can "adapt" them via command line.

.. code-block:: console

    User@Host:~$ bake test --adapt abc

bake searches for abc/Adapt.meta within the workspace roots. If found, the configs from the adapt file are parsed:

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

Effectiveness
*************

The adapt configs can be applied to all configs from regular build. This can be controlled by the config names and the project attributes. The example above
is adapted only to the config "test" of the main project. __MAIN__ and __ALL__ are keywords. __MAIN__ means the main project or config, __ALL__ means all
projects or configs. If you want to apply the changes only to the top level config, write:

.. code-block:: text

      ExecutableConfig __MAIN__, project: __MAIN__, ...

If you want to apply the changes to all configs, write:

.. code-block:: text

      ExecutableConfig __ALL__, project: __ALL__, ...

It is possible to mix the keywords with reals project or config names.

Occurrences
***********

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

They will be applied in the specified order.

Types
*****

It is possible to specify the type of adaption:

.. code-block:: text

      ExecutableConfig ..., type: replace

The type can be "replace", "remove" or "extend".

Type: extend
------------

This works exactly like for :doc:`derive_configs`.

Type: remove
------------

If parent elements can be found which matches to the child elements, they will be removed.

Example project config:

.. code-block:: text

    ExecutableConfig test {
      DefaultToolchain GCC
    }

Example adapt configs:

.. code-block:: text

    ExecutableConfig __ALL__, project: __ALL__, type: remove {
      DefaultToolchain # remove ok
    }

    ExecutableConfig __ALL__, project: __ALL__, type: remove {
      DefaultToolchain GCC # remove ok
    }

    ExecutableConfig __ALL__, project: __ALL__, type: remove {
      DefaultToolchain Diab # remove NOT ok
    }

    ExecutableConfig __ALL__, project: __ALL__, type: remove {
      DefaultToolchain GCC, eclipseOrder: true # remove NOT ok
    }

Type: replace
-------------

This is for convenience. "replace" will remove all elements with the same type and extends the configs.

Example:

.. code-block:: text

    ExecutableConfig __ALL__, project: __ALL__, type: replace {
      Files "*.cpp"
      DefaultToolchain GCC {
        Linker command: "link.exe"
      }
    }

This removes all "Files" and the "DefaultToolchain" from the original config regardless their attributes and replaces them by the elements of the adapt config.
