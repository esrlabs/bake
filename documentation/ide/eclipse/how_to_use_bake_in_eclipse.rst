How to use bake in Eclipse
==========================

Choose the C/C++ perspective
****************************

The menu items described on this page only appear in the C/C++ perspective.

Select a build configuration of the main project
************************************************

#. Right click on the main project and select a bake build configuration. 
  
    .. image:: ../../_static/FirstSelect.png
        :width: 100 %
        :scale: 50 %

    .. note::

        * That only configurations with a DefaultToolchain will be displayed.

#. If no Project.meta or configuration with a DefaultToolchain exist, an error item will be displayed like this

    .. image:: ../../_static/WrongSelect.png
        :width: 100 %
        :scale: 50 %

#. The chosen config is marked with a filled circle before the config name.You can also see it directly in the project explorer

    .. image:: ../../_static/SecondSelect.png
        :width: 100 %
        :scale: 50 %

    .. note::

        * This label decoration can be switched off and on via Window->Preferences->General->Appearance->Label Decoration

Adjust includes and defines for CDT
***********************************
s you might have already seen, a new menu item for the main project is enabled now: Adjust includes and defines for CDT.
All CDT features work out-of-the-box except those about the `#include` and `#define` statements e.g. auto-completion of includes. 
To import the includes and defines into the CDT .cproject files, simply click on this menu item.

Compiler internal includes and defines must be specified in InternalInclude and InternalDefine files. 
See "Syntax" help page how to set the name of these files. Note, that the variables CPPPath, CPath, ASMPath, 
ArchiverPath and LinkerPath can be used in these files.

Adjusting can take between a few seconds and a minute depending on the size of the workspace and the number of 
project settings which have to be written.

Build/Clean Projects/Files
**************************
Now you can build or clean a project by clicking on the appropriate menu items.

=========================================           =======================================
Project                                             File
=========================================           =======================================
.. image:: ../../_static/buildMain.png              .. image:: ../../_static/buildFile.png
=========================================           =======================================

.. note::
    * Build File always rebuilds the file

Result
******

The result of the build will be shown in the Console and Problems View as usual

.. image:: ../../_static/console.png
    :width: 100 %
    :scale: 50 %

.. image:: ../../_static/problem.png
    :width: 100 %
    :scale: 50 %


Preferences
***********

Via `Window->Preferences->bake` some settings can be changed and the bake command line can be extended

.. image:: ../../_static/pref.png
    :width: 100 %
    :scale: 50 %

