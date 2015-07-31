The main project
================
The concept of the main project is different to many other build systems like Eclipse CDT.
In these build systems everything which is needed for a project is configured in the project itself.
In bake the main project can predefine stuff for all subprojects.
The main project can have a DefaultToolchain definition, which is valid for all projects and files referenced by the main project. Subprojects can overwrite or adjust these definitions.

Projects are always built in context of the main project.

To build a project, you have to specify

    * the main project
    * the config of the main project which references the project to build
    * the (sub)project to build if applicable

Advantages
**********

Reducing the number of build configurations (toolchain settings like debug or release flags can be set outside of the project)
Most projects do not have any compiler definitions anymore
Only flags which must be used or flags which must not be used have to be specified in the projects
Changing compiler definitions for all projects can be done easily in the main project build configuration

Example
*******

==============================================   ==============================================
Project.meta of Main (Debug and Release)         Project.meta of Sub (only one build config!)
==============================================   ==============================================
.. literalinclude:: ../_static/Main.meta         .. literalinclude:: ../_static/Lib.meta
==============================================   ==============================================

.. note::

    A main project must have a DefaultToolchain - but it's allowed to leave that definition empty.

Output directory
****************

A project in a specific build configuration can be build in different contexts. 
That's why the output directory of a project cannot be simply the build configuration name of the project to avoid inconsistencies. 
Therefore the output directory names are.

    * Main project: $(MainConfigName) like in regular Eclipse CDT builds
    * Subprojects: $(MainConfigName)_$(MainProjectName) instead of the config name of the subproject
