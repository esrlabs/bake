Commandline
===========

How to get help
***************

.. code-block:: console

    User@Host:~$ bake -h
    
The most important options
**************************

#. *-b* the build configuration name

#. *-m* the main project directory (default is current directory)

#. *-p* the project to build (if not specified, the main project will be built with all dependencies) 

   .. note::
    
        All configs of the project will be built, which is usually just one config, but if you have more than one config of the project in the workspace, use a comma separator.

Examples
********

Building an application
-----------------------

    .. code-block:: console

        User@Host:~$ bake -b Debug

    .. note::

        It is possible to omit *-b*:

        .. code-block:: console

            User@Host:~$ bake Debug

Building from within an arbitrary directory
-------------------------------------------

    .. code-block:: console

        User@Host:~$ bake Debug -m w:/root/mainProj

Building just one specific project
-----------------------------------
Assuming the project name to build s myProj.

    .. code-block:: console

        User@Host:~$ bake Debug -m w:/root1/myProj -p myProj

Building specific projects with differnt roots
----------------------------------------------
Assuming mainProj has several configs really included in the build (which is uncommon), you can choose one of the configs.


    .. code-block:: console

        User@Host:~$ bake Debug -m w:/root1/myProj -p myProj,abc


Building a project which has more than one root
-----------------------------------------------
Assuming code has been checked out into two roots, the console supports ansi colors, you want to stop on first error and build only the project bspAbc.
   
    .. code-block:: console

        User@Host:~$ bake Debug -m w:/root1/myProj -w w:/root1 -w w:/root2 -r -a black -p bspAbc


Clean a project(s)
------------------

    .. code-block:: console

        User@Host:~$ bake Debug -m w:/root1/myProj -w w:/root1 -w w:/root2 -r -a black -p bspAbc -c

Build a single file(s)
----------------------
    .. code-block:: console

        User@Host:~$ bake Debug -p bspAbc -f main.cpp
        User@Host:~$ bake Debug -f .asm

    .. note::

        All files matching the pattern will be compiled (no wildcards allowed)


roots.bake
**********

Workspace roots can be defined in a file called "roots.bake", which will be searched from main project directory to root folder.
Example:

    .. code-block:: console
	
        ../..
        C:/another/root # comments written like this
        something/else
	
If -w and roots.bake are not specified, the default workspace root is the parent directory of the main project.
