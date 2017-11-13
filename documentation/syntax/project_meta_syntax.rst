The Syntax of the Project.meta file
===================================

Instructions for the Interactive Syntax Viewer
**********************************************

* Move the mouse cursor over the blue elements to display more information.

* Three config types exist: ExecutableConfig, LibraryConfig and CustomConfig. Move the mouse cursor over these elements to display the supported content.

Filter
******

Every element (except the Project element) in Project.meta has two attributes:

- default: if set to "off", this element is not taken into account. Default is "on".
- filter: The element can be removed/added explicitly regardless of the "default" attribute with the command line options

  - --do "filter name"
  - --omit "filter name"

Example:

.. code-block:: console

    PostSteps {
      CommandLine "$(OutputDir)/$(ArtifactName)", filter: run, default: off
    }

The executable is not executed by default unless "run" is specified on command line:

.. code-block:: console

    bake ... --do run

Notes
*****

- Specify the paths always relative to the current project root.
- Keep the variable substitution in Project.meta in mind.
- Use double quotes (") if the strings have spaces or slashes.
- Use hash marks (#) for comments.

Syntax
******

.. raw:: html
    :file: ../_static/syntax.html
