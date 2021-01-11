bakeclean
*********

With bakeclean you can cleanup your workspace from .bake, .bake/../build and .bake/../build_* folders.

Folders are searched recursively from current working directory. Call it without any parameters to start the procedure.

To preview the deleted folders, use "--preview" as argument. The filesystem will not be changed in preview mode.

.. warning::
    Folders will be deleted without any warning. They will be deleted even if they are not empty.
