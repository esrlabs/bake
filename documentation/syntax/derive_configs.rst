Derive configs
==============

bake supports deriving configs, which allows you to put repetetive settings in a base config.

Deriving a config
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
    the "Files" from A and B, because "Files" is not valid in CustomConfig.


Inheritance implications
************************

In general it is very easy.

- Elements which can exist more than once (e.g. "Files"), are simply concatenated. First the parent elements, then the client elements.
- Elements which can exist only once:
 
  - if it exists in EITHER child OR parent, use this one
  - is it exists in BOTH, attributes are merged (child attributes have high priority) and sub elements are inherited recursively

The following example

.. code-block:: text

    ExecutableConfig A {
      Files "x.cpp"
      Files "y.cpp"
      ArtifactName "z.exe"
      DefaultToolchain GCC {
        Linker {
          Flags "-O3"
        }
      }
    }
    ExecutableConfig B, extends: A {
      Files "z.cpp"
      IncludeDir "inc"
      ArtifactName "a.exe"
      DefaultToolchain Diab {
        Compiler CPP {
          Define "TEST"
        }
      }
    }
    
results implicitly in:

.. code-block:: text

    ExecutableConfig B {
      Files "x.cpp"
      Files "y.cpp"
      Files "z.cpp"
      IncludeDir "inc"
      ArtifactName "a.exe"
      DefaultToolchain Diab {
        Compiler CPP {
          Define "TEST"
        }
        Linker {
          Flags "-O3"
        }
      }
    }
    

