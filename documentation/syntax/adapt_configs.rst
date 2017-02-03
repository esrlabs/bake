.. _adapt_reference:

Adapt configs
=============

Introduction
------------

There are two major use cases:

- Changing the configs from outside, e.g. injecting a toolchain.
- Changing the configs depending on variables like the operating system.

Both is possible with the *Adapt* feature.

From command line
-----------------

If you want to manipulate existing configs without changing them, you can "adapt" them via command line.

.. code-block:: console

    User@Host:~$ bake test --adapt abc

bake searches for abc/Adapt.meta within the workspace roots. If found, the configs from the Adapt.meta are parsed:

.. code-block:: text

    Adapt {
      ExecutableConfig ... # 0..n
      LibraryConfig ... # 0..n
      CustomConfig ... # 0..n
    }

Here is an example to change the DefaultToolchain (details explained below):

.. code-block:: text

    Adapt {
      ExecutableConfig test, project: __MAIN__, type: replace {
        DefaultToolchain GCC
      }
    }

From Project.meta
-----------------

You can do the same within the Project.meta:

.. code-block:: text

    Project {
      ...
    }
    Adapt {
      ...
    }
    Adapt {
      ...
    }

Conditions and effectiveness
----------------------------

Be aware, these are two different things but look very similar.

Condition
~~~~~~~~~

An *Adapt* can have up to four attributes:

- **toolchain**: e.g. GCC
- **os**: can be Windows, Mac, Linux, Unix (which is != Linux)
- **mainConfig**: name of the main config
- **mainProject**: name of the main project

The "Adapt* configs will be only applied if all these attributes are either empty or true ("AND" operation). Example:

.. code-block:: text

    Adapt toolchain: GCC, os: Windows {
      ...
    }

Here the *Adapt* configs will be applied if toolchain is GCC on Windows.

.. note::

    You can write "If" instead of "Adapt":

.. code-block:: text

    If toolchain: GCC, os: Windows {
      ...
    }

.. note::

    It is possible to negate the conditions with "Unless":

.. code-block:: text

    Unless toolchain: GCC, os: Windows {
      ...
    }

The adapt block in the example above will be applied if the toolchain is not GCC AND if the OS is not Windows, e.g. for GCC on Linux or Diab Compiler on Mac.


Effectiveness
~~~~~~~~~~~~~

The *Adapt* configs can be applied to all configs from regular build. This can be controlled by the config names and the project attributes.
Remember the example from the beginning?

.. code-block:: text

    Adapt {
      ExecutableConfig test, project: __MAIN__, type: replace {
        DefaultToolchain GCC
      }
    }

This config is applied only to the config "test" of the main project.

__MAIN__, __ALL__ and __THIS__ are keywords:

- **__MAIN__** means the main project or main config
- **__ALL__** means all projects or configs
- **__THIS__** is only valid for project name, which can be used for *Adapts* within a Project.meta to restrict the adaption to the current project. This is the default for *Adapts* in Project.meta.

If you want to apply the changes only to the top level config, write:

.. code-block:: text

      ExecutableConfig __MAIN__, project: __MAIN__, ...

If you want to apply the changes to all configs, write:

.. code-block:: text

      ExecutableConfig __ALL__, project: __ALL__, ...

It is possible to mix the keywords with reals project or config names.

Occurrences
-----------

You can specify more configs in one *Adapt* and you can specify more than one Adapt.meta file:

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

Apply order
-----------

The *Adapt* configs will be applied in the order in which they were parsed. First the Adapt.metas referenced from the command line are read. Then the Project.metas are read
one by one as usual. If an *Adapt* is found, it will be appended to the list of *Adapts*. Note, *Adapts* will be applied immediately when a Project.meta is read.

If you inject a Toolchain from outside, e.g. "--adapt gcc", you can use the toolchain info for local *Adapts*:

.. code-block:: text

    Project {
      ...
    }
    Adapt toolchain: GCC {
      ...
    }

Types
-----

It is possible to specify the type of adaption:

.. code-block:: text

      ExecutableConfig ..., type: replace

The type can be

- **replace**
- **remove**
- **extend**
- **push_front**

Type: extend
~~~~~~~~~~~~

This works exactly like for :doc:`derive_configs`.

Type: push_front
~~~~~~~~~~~~~~~~

This works like extend, but elements which can be contained multiple times are pushed to front.

Example project config:

.. code-block:: text

    Project {
      LibraryConfig test {
        IncludeDir "abc"
        ...
      }
    }

    Adapt ... {
      LibraryConfig test, project: __THIS__, type: push_front {
        IncludeDir "mock"
      }
    }

The resulting include path order will be "-Imock -Iabc".

Type: remove
~~~~~~~~~~~~

If parent elements can be found which matches to the child elements, they will be removed.

Example project config:

.. code-block:: text

    ExecutableConfig test {
      DefaultToolchain GCC
    }

Example *Adapt* configs:

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
~~~~~~~~~~~~~

This is for convenience. "replace" will remove all elements with the same type and extends the configs.

Example:

.. code-block:: text

    ExecutableConfig __ALL__, project: __ALL__, type: replace {
      Files "*.cpp"
      DefaultToolchain GCC {
        Linker command: "link.exe"
      }
    }

This removes all "Files" and the "DefaultToolchain" from the original config regardless their attributes and replaces them by the elements of the *Adapt* config.

Wildcards
---------

The "*" wildcard is allowed:

.. code-block:: text

    Adapt mainProject: HERE, mainConfig: HERE ... {
      SomeConfig HERE, project: HERE ... {
        ....
      }
    }

Example (the configs of the Adapt are applied if the main config name starts with "UnitTest"):

.. code-block:: text

    Adapt mainConfig: "UnitTest*" {
      ...
    }
