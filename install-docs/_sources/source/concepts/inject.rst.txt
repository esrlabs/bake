Injection and inheritance of IncludeDir and Dependency
======================================================

It is possible to inject and inherit "includes" and inject "dependencies".

Inherit IncludeDir
------------------

.. code-block:: console

    IncludeDir include, inherit: true

This is typically used to make include directories available to upper levels, e.g.:


.. code-block:: console

    # in MyLib/Project.meta
    LibraryConfig Lib {
      ...
      IncludeDir include, inherit: true
    }

    # in main/Project.meta
    ExecutableConfig Debug {
      ...
      Dependency MyLib, config: Lib
      # IncludeDir "MyLib/include" - not needed because this IncludeDir is inherited
    }

Inject IncludeDir
-----------------

.. code-block:: console

    IncludeDir "mock/include", inject: front

"front" is used for mocking IncludeDirs, e.g. if a library shall include a mocked class instead of the original one in UnitTest context.

.. code-block:: console

    IncludeDir include, inject: back

"back" is used if the lower levels do not know by themselves what to include. So this has to be configured from the outside, typically in the main project.

Inject Dependency
-----------------

.. code-block:: console

    Dependency MyLib, inject: front # or back

This is used if a component cannot have this dependency hard coded, because it shall not know the concrete implementation or the dependency is only used for unittesting.

Example:

.. code-block:: console

    ExecutableConfig UnitTest {
      ...
      Dependency config: Lib
      Dependency googleTest, inject: front
    }

In this example the config Lib depends on googleTest. If googleTest inherits an IncludeDir, this would be known by Lib.
