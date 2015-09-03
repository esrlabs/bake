How to use bake in Visual Studio
================================

#. Select a build configuration of the main project

    Right click on the main project and select a bake build configuration. 

    .. image:: ../../_static/vs_select_config.png
        :width: 100 %
        :scale: 50 %

    .. note::

        Only configurations with a DefaultToolchain will be displayed.

#. You can see the selected config in the last line of the Build menu.

    .. image:: ../../_static/vs_show_config.png
        :width: 100 %
        :scale: 50 %

    If you click on this menu item, you can deselect the build config, which disables bake as long as no other config will be selected.

#. You can specify additional command line parameters via the Options menu.

    .. image:: ../../_static/vs_options.png
        :width: 100 %
        :scale: 50 %

#. The build result will be shown in the Output window, errors will be shown in the Error window and annotated in the sources.

    .. image:: ../../_static/vs_error.png
        :width: 100 %
        :scale: 50 %

