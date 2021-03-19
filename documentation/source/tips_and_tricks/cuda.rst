Cuda
====

bake supports Cuda!

Example:

.. code-block:: console

    LibraryConfig cuda {
      Files "src**/*.cu"
      IncludeDir "include"
      Toolchain {
        Compiler C, command: "nvcc", cuda: true
      }
    }

For this config, the compiler command is set to "nvcc".

One problem with Cuda is, that the nvcc does not create dependency files, which are necessary for bake.
With "cuda: true" some flags are added to the command which triggers the creation of these files.
