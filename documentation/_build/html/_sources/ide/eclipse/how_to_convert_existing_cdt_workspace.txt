How to convert existing CDT workspaces
======================================
You only need to convert your workspace if CDT is still used to build your projects and the `Project.meta` files do not exist yet.
Only one developer in a team has to convert the workspace only once!
Conversion means, that Project.meta files are generated and filled with the informationen from the `.project` and `.cproject`
files. bake does not read the `.project` and `.cproject` files, only the `Project.meta` files.

The converter is an export wizard, which can be found under `File->Export` or in the context menu of the Project Explorer

=========================================           =======================================
.. image:: ../../_static/SelectExport.png           .. image:: ../../_static/Script.png
=========================================           =======================================

.. note::

    * The conversion is not a 1:1 conversion. That means, that the tool can only be 99% perfect. There might by some small issues, which have to be adapted manually. You can find it out by simply trying to build your project with bake.

    * It is possible to specify a ruby script in the wizard window, which can do these manual adaptions. This can make sense, if you want to convert the workspace several times before completely switching to bake.

    * To convert only a subset of projects instead of the whole workspace, select the appropriate projects in the Project Explorer before starting the export wizard. Ensure that the checkbox shown above is marked.

    * If you are satisfied with the results, replace the .cproject and .project files in your repository. (Steps to do with .cproject and .project files)
        * Delete the files
        * Remove the projects from your workspace in Eclipse (but do not delete the contents from your disk)
        * Import the projects again via the bake import wizard to generate wrapper files for Eclipse
        * Commit the change to your source control system

.. warning::
    Do not commit these `.projec`t and `.cproject` files anymore. Instead, commit the changes in `Project.meta` files.
    You still need `.cproject` and `.project` files for working under Eclipse,
    that's why you have to import the projects again via the bake import wizard.
