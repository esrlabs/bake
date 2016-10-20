QACPP
*****

bakeqac is a convenience wrapper for QACPP with some nice features.

Without bakeqac
---------------

QACPP can be called directly from command line:

.. code-block:: console

    qacli admin --qaf-project-config --qaf-project qacdata --cct <cct> --rcf <rcf> --acf <acf>
    qacli analyze -P qacdata -b <bake call>
    qacli view -P qacdata -m STDOUT

- The first command creates the qac project database.
- The second command builds and analyzes the files.
- The third command prints out the result unfiltered.

With bakeqac
------------

Instead of writing

.. code-block:: console

    bake <options>

for regular build, simply write:

.. code-block:: console

    bakeqac <options>

bakeqac will automatically do the three steps mentioned above. If one of these steps fails, the consecutive steps will be dismissed.

You can also choose certain steps (can be combined with "|"):

.. code-block:: console

    bakeqac <options> --qacstep admin|analyze|view
    bakeqac <options> --qacstep admin
    etc.

Step 1: admin
-------------

You have to set the environment variable QAC_HOME, e.g. to *c:\\tools\\prqa\\PRQA-Framework-2.1.0*. If not specified otherwise, cct, rcf and acf will be automatically chosen.

- Configuration compiler template (cct): Only GCC is supported. bakeqac tries to get the platform and the GCC version and calculates the path to the right cct file. To overwrite this behaviour, specify one or more ccts:

  .. code-block:: console

      bakeqac <options> --cct <first> --cct <second>

  Alternatively, you can add

  .. code-block:: console

      bakeqac <options> --c++11
      bakeqac <options> --c++14

  to enforce bakeqac choosing the C++11 or C++14 toolchain.

- Rule configuration file (rcf): Can be specified with:

  .. code-block:: console

      bakeqac <options> --rcf <rcf>

  If not specified, bakeqac searches for qac.rcf upwards from bake main project folder. If also not found, bakeqac uses $(QAC_HOME)/config/rcf/mcpp-1_5_1-en_US.rcf.

- Analysis configuration file (acf): Can be specified with:

  .. code-block:: console

      bakeqac <options> --acf <acf>

  If not specified, $(QAC_HOME)/config/acf/default.acf will be used.

- You can also specify the qacdata folder, default is *.qacdata*:

  .. code-block:: console

      bakeqac <options> --qacdata anotherFolder


Step 2: analyze
---------------

This is the main step. Use exactly the same options for bakeqac as for bake. A few things have to be mentioned:

- *--compile-only* will be automatically added
- *--rebuild* will be automatically added

The output will be filtered per default (e.g. some warnings) . To get unfiltered output, write:

.. code-block:: console

    bakeqac <options> --qacnofilter

Step 3: view
------------

Results are also filtered in this step if not specified otherwise:

- Only results from compiled bake projects will be shown (which does not apply to e.g. compiler libraries). To narrow the results, use the *-p* option.
- Files from subfolders test and mock will be filtered out.
- Files from projects gtest and gmock will be filtered out.

bakeqac slightly reformats the output (originally the violated MISRA rule numbers are printed out incomplete). To switch back to raw format, use:

.. code-block:: console

    bakeqac <options> --qacrawformat

To get additional links to the appropriate documentation pages use:

.. code-block:: console

    bakeqac <options> --qacdoc

Colored output is also supported similar to bake:

.. code-block:: console

    bakeqac <options> -a <color_scheme>


Additional options
------------------

QACPP needs a license. If floating licenses are not available, bakeqac can retry to checkout them:

.. code-block:: console

    bakeqac <options> --qacretry <seconds>

Step 2 and 3 are retried until timeout is reached.

Example output
--------------

.. image:: ../_static/misra.png