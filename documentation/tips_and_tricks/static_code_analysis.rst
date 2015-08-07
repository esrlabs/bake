Static Code Analysis
====================

Static code analysis often is part or a pre step of the build, even though bake provides presteps which can be used to 
add customized steps, we choose to add explicit support for static code analysis due to the fact that the analysis often
depends on information well known by the build system (include pahts, compiler flags, etc.). Currently bake has  built in
support for *Pc-Lint*. 

Lint
****

With bake you can lint LibraryConfigs, ExecutableConfigs, single files and the complete workspace (in this case the projects are linted separately). 
The CPP Toolchain settings of the project are used regardless of the file type and file specific options. 
It is possible to specify lnt-files with LintPolicy, but you can add every other lint command line option as well.

Basic Setup
-----------

#. Install `lint  <http://www.gimpel.com/html/products.htm>`_.
#. Make sure the The lint executable 'lint-nt.exe' is in the path.

.. attention::

    even though there is a unix version of pc-lint the asscoated binary name must be lint-nt.exe otherwise
    it won't be recorgnized by the bake build system.

After doing this steps you are able to lint your build configurations (LibraryConfigs and ExecutableConfigs) using the *--lint* flag on the command line.

Example
+++++++
.. code-block:: console

    User@Host:~$ bake Debug -p MyLibraryProject --lint


Configuring Lint
----------------

In order to configure lint in the Project.meta file, just use the *LintPolicy* command, which forwards the supplied
the parameters to lint.

.. code-block:: text

    DefaultToolchain GCC {
        ...
        LintPolicy "$(ProjectDir)/lint/misra.lnt"
        LintPolicy "$(ProjectDir)/lint/suppressions.lnt"
    }

Example
+++++++

This exmample shows how to redirect the output to single xml files placed into the main project folder.

.. code-block:: text

    DefaultToolchain GCC {
        LintPolicy "-os($(MainProjectDir)/$(ProjectName)_$(ConfigName)_lintout.xml)"
        LintPolicy "-v"
        LintPolicy "+xml(doc)"
        LintPolicy "-format=%f %l %t %n %m"
        LintPolicy "-format_specific= "
        LintPolicy "-pragma(message)"
        ...
    }


Known Issues
------------
Bake only searches for lint-nt.exe
+++++++++++++++++++++++++++++++++++
    **Issue:**
    Bake currently does not search for all possible names of the lint application, it only searches for a file called *lint-nt.exe*.

    **Solution:**
    If you have another lint command (e.g. because you are using flexe lint on unix)
    just create an symlink/alias which is called *lint-nt.exe*.

Lint fails due to missing compiler includes and defines 
+++++++++++++++++++++++++++++++++++++++++++++++++++++++
    **Issue:**
    Lint will fail if compiler internal includes and defines are missing. 

    **Solution:**
       
    Lint comes with some helper files, handle this issue. In order to get a list of all needed
    helper files e.g. for GCC, use the following command. 

    .. code-block:: console

        User@Host:~$ make -f .../PcLint/../lnt/co-gcc.mak

    You will get a output like this:

    .. code-block:: text

        gcc-include-path.lnt, lint_cmac.h, lint_cppmac.h and size-options.lnt.

    You can now add the needed includes and LintPolicies (.lnt files) to your bake 
    configuration.

Lint error due to too many includes
+++++++++++++++++++++++++++++++++++

    **Issue:**
    In rare cases lint has problems if it has to open too many (include) files. 

    **Solution:**
    You can use the *--lint_max* and the *--lint_min* options to get around this issue.

    Example:

    .. code-block:: console

        User@Host:~$ bake Debug -p MyLibraryProject --lint --lint_max 50                 #(lints the first 51 files)
        User@Host:~$ bake Debug -p MyLibraryProject --lint --lint_min 51 --lint_max 100  #(lints the next 50 files)
        User@Host:~$ bake Debug -p MyLibraryProject --lint --lint_min 101                #(lints the rest of the files)


.. Clang Analyze
.. *************

