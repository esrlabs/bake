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
Move the mouse cursor over the blue elements to display more information.

.. raw:: html
    :file: ../_static/syntax_collection_meta.html

.. note::

    * Use double quotes (") if the strings have wildcards
    * Use hash marks (#) for comments.

Example:

    .. code-block:: text

        Collection AllUnitTests {
            Project "*", config: UnitTest
        }
        Collection UnitTestLibsWithoutBsp {
            Project "*", config: "UnitTestLib*"
            Exclude "bsp*", config: "*"
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


