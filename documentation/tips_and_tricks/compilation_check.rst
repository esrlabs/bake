Compilation Check
*****************

To ensure that files are included in or excluded from the build, use CompilationCheck.

Usage
*****

.. code-block:: console
  
  ExecutableConfig {
    ...
    CompilationCheck include: "{src,include}/**/*", ignore: "include/internal/*", exclude: "src/test.cpp"
  }

It can be used multiple times, e.g.:

.. code-block:: console
  
  CompilationCheck include: "{src,include}/**/*"
  CompilationCheck ignore:  "{src,include}/**/*.{md,inc,s,hpp,lnk,org,per}"
  CompilationCheck ignore:  "{src,include}/**/documentation.h"  }

It is also possible to reference different projects:

.. code-block:: console
  
  CompilationCheck exclude: "$(ProjectDir, anotherLib)/src/nope.cpp"

Every CompilationCheck from all used configs are taken into account.

The attributes:

- include: Files must be included in the build.
- exclude: Files must be excluded from the build. This overrules include.
- ignore: Overrules include and exclude.

If a check fails, bake will print out a warning, e.g.:

.. code-block:: console
  
  **** Building 3 of 3: main (test) ****
  Compiling main (test): src/main.cpp
  Linking   main (test): build/test/main.exe
  Warning: file not included in build: src/someFile.cpp
  Warning: file not included in build: src/anotherFile.cpp

Adapt
*****

The typical use case is to include files in a general Adapt.meta file and to ignore them locally in a Project.meta file, e.g.:

.. code-block:: console

  # in ccheck/Adapt.meta  
  Adapt {
    RequiredBakeVersion minimum: "2.64.0"
    ExecutableConfig "UnitTestBase*", project: __MAIN__, type: extend {
      CompilationCheck include: "{src,include}/**/*"
    }
  }
  
  ...

  # in a Project.meta
  ExecutableConfig UnitTestBase {
    ...
    CompilationCheck ignore: "include/draft/**/*"
  }

  # in the shell
  bake UnitTestBase --adapt ccheck ...
