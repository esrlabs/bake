The build hierarchy
===================

Build graph
***********

Depending on the contents of the Project.meta files, a build graph will be generated:
    * An ExecutableConfig usually specifies files to compile, dependencies to other projects and linker stuff.
    * A LibraryConfig usually specifies files to compile and archive.
    * A CustomConfig usually defines a custom step.

Every config type can be equipped with pre and post steps like shell commands or makefiles.

All these steps will be combined to a build graph.

Example
*******

The main project has dependencies to the projects A, B and C:

    .. image:: ../_static/bake_build_hierachy.png
        :width: 100 %
        :scale: 75 %

Steps are executed bottom-up. If one step fails, all steps above won't be executed.

If for example:
    * PreStepMain 2 fails
    * at least one file of library B does not compile
then:
    * library B will not be created
    * files of the main project will not be compiled
    * main project will not be linked
    * post step of main project will not be executed
