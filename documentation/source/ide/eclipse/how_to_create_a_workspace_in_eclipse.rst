How to create a workspace in Eclipse
====================================

Using bake in Eclipse is very similar compared to the :any:`CDT build mechanism <how_to_convert_existing_cdt_workspace>`.

.. warning::
    One major difference is, that `.cproject` and `.project` files are just wrappers. Do not use the standard property pages,
    they will be simply ignored! Edit only the `Project.meta` files.
    The `.cprojec`t and `.project` files shall not be committed to your source control.

Import
******

If you have a workspace with no `.cproject` and `.project` files, but `Project.meta` files, you can import them to Eclipse.
You can also use the importer to import single projects.
The importer can be found unter `File->Import` or in the context menu of the Project Explorer.
All (sub)directories with a `Project.meta` are listed here. Choose the projects to import and press Finish.

============================================           =======================================
.. image:: ../../../_static/SelectImport.png           .. image:: ../../../_static/Import.png
============================================           =======================================

.. note::
    Note, that `.cproject` and `.project` files will not be overwritten per default. If e.g. a project is not a c-project,
    some bake features will not available. In this case, enable the recreate option.
    This is also a good idea, if you want to get rid of old configurations.

