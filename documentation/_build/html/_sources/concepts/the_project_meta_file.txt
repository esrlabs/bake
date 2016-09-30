The Project.meta file
=====================

What is the Project.meta file
*****************************
The `Project.meta` file is bakes configuration file.

* Every project has a Project.meta file in the project root directory.
* A Project.meta file contains one or more build configurations.
* A build configuration consists of toolchain settings, files to build, custom steps, etc.

Example
*******

=============================================         =============================================
Project.meta file of Main project                     Project.meta file of Sub project
=============================================         =============================================
.. literalinclude:: ../_static/PMetaMain.meta         .. literalinclude:: ../_static/PMetaSub.meta
=============================================         =============================================

Let's assume that Main and Sub are located in the same workspace root.
To build the executable, bake can be called from the Main directory.

    .. code-block:: console

        User@Host:~/my_project$ bake -b Debug

What happens now?

    #. Reading Project.meta of Main
    #. Reading Project.meta of dependencies (Sub)
    #. Compiling sources of Sub, e.g.:
        .. code-block:: console

            User@Host:~$ g++ -c -Wall -g3 -Iinclude -I../Main/include -o Debug_Main/src/xy.o src/xy.cpp

        * Wall is taken from the DefaultToolchain and -g3 is added by the toolchain of the Sub project.

        * The include path to Main is automatically adjusted.

        * The order of includes is the same as in Project.meta.

        * g++, -c and -I are used, because GCC was specified in the DefaultToolchain.

    #. Archiving the library, e.g.:

        .. code-block:: console

            User@Host:~$ ar -rc Debug_Main/libSub.a Debug_Main/src/xy.o

    #. Compiling sources of Main, e.g.:

        .. code-block:: console

            User@Host:~$ g++ -c -Wall -Iinclude -o Debug/src/main.o src/main.cpp

    #. Linking executable, e.g.:

        .. code-block:: console

            User@Host:~$ g++ -o Debug/Main.exe Debug/src/main.o ../Sub/Debug_Main/libSub.a -L../Sub/lib -la -lb

        The library search paths and libraries are added in the specified order.

    #. Executing the post step

        .. code-block:: console

            User@Host:~$ echo Main.exe built.

        The variable was automatically substituted.

