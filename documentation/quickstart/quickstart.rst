Quickstart
==========

#. Create a project directory.
    .. code-block:: console

        User@Host:~$ mkdir my_project


#. Switch to the project directory.
    .. code-block:: console

        User@Host:~$ cd my_project


#. Use the bake --create option to auto generate a basic project.
    .. code-block:: console

        User@Host:~/my_project$ bake --create exe
        -- bake 2.10.3, ruby 2.1.2p95, platform x86_64-darwin13.0 --
        Project created.

        Time: 00:00 minutes

    This will provide you with the follwing basic project structure which is ready to use

    .. code-block:: console

       my_project
       |
       |-- Project.meta
       |-- include
       `-- src
            `-- main.cpp

                     
#. Build the project.
    .. code-block:: console

        User@Host:~/my_project$ bake 
        -- bake 2.10.3, ruby 2.1.2p95, platform x86_64-darwin13.0 --
        Info: cache not found, reloading meta information
        Loading /Users/NiCoretti/my_project/Project.meta
        **** Building 1 of 1: my_project (main) ****
        Compiling src/main.cpp
        Linking build_main/my_project.exe

        Building done.

        Time: 00:00 minutes

    If you want a more detailed and colored output use the following command:

    .. code-block:: console

        User@Host:~/my_project$ bake -v2 -a black
        -- bake 2.10.3, ruby 2.1.2p95, platform x86_64-darwin13.0 --
        **** Building 1 of 1: my_project (main) ****

        g++ -c -MD -MF build_main/src/main.d -Iinclude -o build_main/src/main.o src/main.cpp

        g++ -o build_main/my_project.exe build_main/src/main.o

        Building done.

        Time: 00:00 minutes

    .. warning::
        The default main.cpp which is created by bake does nothing except returning the exit code 0.

