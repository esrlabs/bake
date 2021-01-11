Auto-adjustment of paths to existing projects
=============================================

If paths to other projects are needed, e.g. to "bootloaderUpdater", don't write a hard coded relative path like this:

.. code-block:: text

    CommandLine "../bootloaderUpdater/tools/PrimaryBootloader2Include.exe

If paths to other projects are needed, e.g. to "bootloaderUpdater" just reference it starting from the project folder.

Example:

.. code-block:: text

    CommandLine "bootloaderUpdater/tools/PrimaryBootloader2Include.exe

or:

.. code-block:: text

    IncludeDir "myProjectName/bootloaderUpdater/whatever"



bake recognizes that the first part of the path is a valid project name and calculates the relative path to the project automatically.
If you have the special case that the referenced project is contained in an other workspace root, you can use the
`-w` parameter or you define a `roots.bake`.

.. note::

    The path auto adjustment is applied for the following elements:

    * IncludeDir

    * ExternalLibrary

    * ExternalLibrarySearchPath

    * UserLibrary

    * CommandLine

