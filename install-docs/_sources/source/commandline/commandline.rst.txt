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
----------------------------------
Assuming the project name to build s myProj.

.. code-block:: console

    User@Host:~$ bake Debug -m w:/root1/myProj -p myProj

Building specific projects with different roots
-----------------------------------------------
Assuming mainProj has several configs really included in the build (which is uncommon), you can choose one of the configs.


.. code-block:: console

    User@Host:~$ bake Debug -m w:/root1/myProj -p myProj,abc


Building a project which has more than one root
-----------------------------------------------
Assuming code has been checked out into two roots, the console supports ansi colors, you want to stop on first error and build only the project bspAbc.

.. code-block:: console

    User@Host:~$ bake Debug -m w:/root1/myProj -w w:/root1 -w w:/root2 -r -a black -p bspAbc

Search depth
------------

Projects and Adaptions are searched recursively within the roots. Specify the maximum search depth like this:

.. code-block:: console

    User@Host:~$ bake Debug -m w:/root1/myProj -w w:/root1,3 -w w:/root2/libA,0 -r -a black -p bspAbc

In this example the following folders are checked:
    - w:/root1/Project.meta
    - w:/root1/\*/Project.meta
    - w:/root1/\*/\*/Project.meta
    - w:/root1/\*/\*/\*/Project.meta
    - w:/root2/libA/Project.meta

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


Roots file (roots.bake)
***********************

If a workspace has many roots, it's cumbersome to specify all root folders with -w.
Instead, you can write them into a file. This file can be also specified with -w:

.. code-block:: console

    User@Host:~$ bake Debug ... -w myRootsFile.txt

The content of the file is simply one root per line, e.g.:

.. code-block:: console

    ../..
    C:/another/root # comments written like this
    something/else, 3 # maximum search depth = 3, same as for "-w" arguments on command line

You can specify more than one roots file or mix it with root folders if you like.

.. note::

    *IN ANY CASE* an additional **roots.bake** file is searched from the main folder upwards. The first file found is used.

If one or more -w are specified and a roots.bake is found, they will be merged. First -w, then roots.bake.

.. note::

    If -w and roots.bake are neither specified nor found, the **default workspace root** is the parent directory of the main project.
