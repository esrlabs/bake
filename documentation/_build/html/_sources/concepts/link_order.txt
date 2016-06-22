The link order
==============

The link order depends on the order of library definitions and dependencies in the Project.meta files.

In general, if a library X depends on a library Y, the library X must be linked before Y.

Example:
********

.. code-block:: console

    Project A:

    Dependency B
    Dependency C

.. code-block:: console

    Project B:

    Dependency D

.. code-block:: console

    Project C:

    Dependency D

.. code-block:: console

    Project D:

The link order will be

- Objects of A
- B
- C
- D

Same example but with external libraries:
*****************************************

.. code-block:: console

    Project A:

    ExternalLibrary a1
    Dependency B
    ExternalLibrary a2
    Dependency C
    ExternalLibrary a3

.. code-block:: console

    Project B:

    ExternalLibrary b1
    Dependency D
    ExternalLibrary b2

.. code-block:: console

    Project C:

    ExternalLibrary c1
    Dependency D
    ExternalLibrary c2

.. code-block:: console

    Project D:

    ExternalLibrary d1
    ExternalLibrary d2

The link order will be

- Objects of A
- a1
- B
- b1
- b2
- a2
- C
- c1
- D
- d1
- d2
- c2
- a3
