Known Issues
============

* Issue: If an archive or executable has been built successfully and one source file will be deleted without changing anything else, bake will leave the archive/executable unchanged when rebuilding.
    * Workaround 1: Clean the project.
    * Workaround 2: Delete the archive/executable manually.
    * Workaround 3: Touch, edit, create another source file.
