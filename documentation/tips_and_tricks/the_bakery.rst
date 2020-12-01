The Bakery
==========

What is the Bakery
******************
bakery is part of the bake-toolkit distribution and it is used to build several independent projects at once.
It's very useful for e.g. compiling and running all unit tests.
The collections are specified in Collection.meta files.

How to use the Bakery on the commandline
****************************************
Call *bakery -h* to display the command line options.
The most important options are the collection name (*-b*) and the collection directory (*-m*, default is current directory).

Examples:

Build all unit tests:

.. code-block:: console

    bakery -b AllUnitTests

It is possible to omit *-b*:

.. code-block:: console

    bakery AllUnitTests

Clean all unit tests:

.. code-block:: console

    bakery -b AllUnitTests -c

Build all unit tests, workspace checked out into two roots, console supports colors, stop on first error, run the unittests after build:

.. code-block:: console

    bakery -b AllUnitTests -m w:/root1/mainProj -w w:/root2 -r -a black --do run


Syntax of Collection.meta
*************************

Note: use hash marks (#) for comments.

.. parsed-literal::


    :ref:`collection` <name> {
      :ref:`Project <projectCollection>` <name>, config: <name>, args: <arguments>
      :ref:`exclude` <name>, config: <name>
      :ref:`excludeDir` <name>
      :ref:`subCollection` <name>
    }

.. _collection:

Collection
----------

This is a collection of builds. The name must be unique within this file.

*Mandatory: yes, quantity: 1..n, default: -*

.. _projectCollection:

Project
-------

Specify the projects with it's configs to build. It is possible to use "*" as wildcards.

*Mandatory: yes, quantity: 1..n, default: -*

.. _exclude:

Exclude
-------

Specify the projects with it's configs to exclude from build. It is possible to use "*" as wildcards.

*Mandatory: no, quantity: 0..n, default: -*

.. _excludeDir:

ExcludeDir
----------

Specify the directory relative to the Collection.meta. All projects inside it will be excluded from the build.

*Mandatory: no, quantity: 0..n, default: -*

.. _subCollection:

SubCollection
-------------

This references another collection.

*Mandatory: no, quantity: 0..n, default: -*

Example of Collection.meta
**************************

.. code-block:: text

    Collection AllUnitTests {
        Project "*", config: UnitTest
    }
    Collection UnitTestLibsWithoutBsp {
        Project "*", config: "UnitTestLib*"
        Exclude "bsp*", config: "*"
        EcludeDir "path/to/some/folder"
    }
    Collection MySpecialCollection {
        Project Main1, config: Debug
        Project Main2, config: Release
        Project Sub3, config: Debug
        SubCollection UnitTestLibsWithoutBsp
    }
    Collection MainWithBakeArgs {
        Project Main, config: Debug, args: "--adapt Debug --rebuild"
    }


