QACPP
*****

Without bake
------------

You can use QACPP from command line:

.. code-block:: console

    qacli admin --qaf-project-config --qaf-project qacdata --cct <cct> --rcf <rcf> --acf <acf>
    qacli analyze -P qacdata -b <bake call>
    qacli view -P qacdata -m STDOUT

- The first command creates the qac database. This is needed only once.
- The second command builds the files.
- The third command prints out the result.

To make it easier, bake toolkit provides *bakeqac*. Instead of writing

.. code-block:: console

    bake <options>

simply write:

.. code-block:: console

    bakeqac <options>

bake will automatically do these three steps. If one of the steps fails, the consecutive steps will be dismissed.

You can also choose certain steps (can be combined with "|"):

.. code-block:: console

    bakeqac <options> --qacstep create|build|result
    bakeqac <options> --qacstep build
    etc.

Step 1: create
--------------

You have to set the environment variable QAC_HOME, e.g. to *c:\\tools\\prqa\\PRQA-Framework-2.1.0*. If not specified otherwise, cct, rcf and acf will be automatically chosen.

- Configuration compiler template (cct): Only GCC is supported. bakeqac tries to get the platform and the GCC version and calculates the path to the right cct file. To overwrite this behaviour, specify one or more ccts:

  .. code-block:: console

      bakeqac <options> --cct <first> --cct <second>

  Alternativly, you can add

  .. code-block:: console

      bakeqac <options> --c++11
      bakeqac <options> --c++14

  to enforce bake choosing the C++11 or C++14 toolchain.

- Rule configuration file (rcf): Can be specified with:

  .. code-block:: console

      bakeqac <options> --rcf <rcf>

  If not specified, bakeqac searches for qac.rcf upwards from bake main project folder. If also not found, bake uses $(QAC_HOME)/config/rcf/mcpp-1_5_1-en_US.rcf.

- Analysis configuration file (acf): Can be specified with:

  .. code-block:: console

      bakeqac <options> --acf <acf>

  If not specified, $(QAC_HOME)/config/acf/default.acf will be used.

- You can also specify the qacdata folder, default is *qacdata*:

  .. code-block:: console

      bakeqac <options> --qacdata anotherFolder


Step 2: build
-------------

Use exactly the same options as for bake. A few things have to be mentioned:

- *--compile-only* will be automatically added
- *--rebuild* will be automatically added

The output will be filtered per default (QAC internal warnings) . To get unfiltered output, write:

.. code-block:: console

    bakeqac <options> --qacfilter off

Step 3: result
--------------

Results are also filtered in this step if not specified otherwise:

- Only results from files within used bake projects will be shown (which does not apply to e.g. compiler libraries). To narrow the results, use the *-p* option.
- Files from subfolders test and mock will be filtered out.
- Files from projects gtest and gmock will be filtered out.
