Compiler settings via environment variables
===========================================

bake has internal defaults for compiler settings (see e.g. "bake --toolchain-info GCC").
The commands and flags can be overwritten via environment variables.

Note that toolchain settings in Project.meta still have higher priority.

The supported environment variables are:

- BAKE_C_COMPILER
- BAKE_CPP_COMPILER
- BAKE_ASM_COMPILER
- BAKE_ARCHIVER
- BAKE_LINKER
- BAKE_C_FLAGS
- BAKE_CPP_FLAGS
- BAKE_ASM_FLAGS
- BAKE_ARCHIVER_FLAGS
- BAKE_LINKER_FLAGS

The internal defaults for flags are always empty. The internal defaults for commands differ depending on the toolchain. For GCC these are "gcc", "g++" and "ar".

Example:

.. code-block:: text

    export BAKE_CPP_COMPILER="gcc-9"
    bake Debug