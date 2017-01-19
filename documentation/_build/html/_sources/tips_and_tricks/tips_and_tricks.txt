Additional features
===================

.. toctree::
    :maxdepth: 1

    the_bakery
    how_to_use_bake_with_cygwin
    the_clang
    dot
    qac
    bakeclean


Unnecessary includes
********************

If a library or executable is successfully build with "-v", unnecessary includes are printed out:

.. code-block:: console

    Info: Include to ../sub1/include/ seems to be unnecessary
    Info: Include to ../sub2/include/ seems to be unnecessary

This features depends on the compiler dependency files. For projects with assembler files, the list might be incorrect.
However, remove the IncludeDir statements from the Project.meta and check it out.

Symlinks and junctions
**********************

It is possible to use symlinks (Linux) or junctions (Windows) when working with git. Best practice:
    * Link all used projects into _one_ directory (e.g. from application repository and basis software repository).
    * Use this directory when working with bake, Eclipse, etc.
    * Specify "-w <absolute_path_to_working_dir>.
    * To sync/commit from/to svn, use the original directories created by git.
