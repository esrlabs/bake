QACPP for MISRA and cyclomatic complexity
*****************************************

bakeqac is a convenience wrapper for QACPP with some nice features.

Without bakeqac
===============

QACPP can be called directly from command line:

.. code-block:: console

    qacli admin --qaf-project-config --qaf-project qacdata --cct <cct> --rcf <rcf> --acf <acf>
    qacli analyze -P qacdata -b <bake call>
    qacli view -P qacdata -m STDOUT
    qacli report -P qacdata -t SUR # or -t RCR, which generates reports of MISRA warnings
    qacli report -P qacdata -t MDR # generates report of cyclomatic complexity

- The first command creates the qac project database.
- The second command builds and analyzes the files.
- The third command prints out the result unfiltered.
- The forth and fifth commands generate reports. You may replace the python scripts in PRQA to adapt the output.

Please note, that "view" is not necessary to generate the reports.

With bakeqac
============

Instead of writing

.. code-block:: console

    bake <options>

for regular build, simply write:

.. code-block:: console

    bakeqac <options>

bakeqac will automatically do the first three steps mentioned above. If one of these steps fails, the consecutive steps will be dismissed.

You can also choose certain steps (can be combined with ","):

.. code-block:: console

    bakeqac <options> --qacstep admin,analyze,view,report,mdr
    bakeqac <options> --qacstep admin
    etc.

Example output:

.. image:: ../../_static/misra.png
    :scale: 100 %

Step 1: admin
=============

You have to set the environment variable QAC_HOME, e.g. to *c:\\tools\\prqa\\PRQA-Framework-2.1.0*.
MCPP has to installed next to *PRQA-Framework-2.x.x* (in this case MCPP_HOME is set automatically to this directory).
Alternatively set the MCPP_HOME variable explicitly when MCPP is installed somewhere else.

If not specified otherwise, cct, rcf and acf will be automatically chosen.

- Configuration compiler template (cct): Only GCC is supported. bakeqac tries to get the platform and the GCC version and calculates the path to the right cct file. To overwrite this behaviour, specify one or more ccts:

  .. code-block:: console

      bakeqac <options> --cct <first> --cct <second>

  Alternatively, you can add

  .. code-block:: console

      bakeqac <options> --c++11
      bakeqac <options> --c++14

  to enforce bakeqac choosing the C++11 or C++14 toolchain.

  If --cct is not used, bakeqac uses a built-in cct file as mentioned above. Additionally, it searched for a file named qac.cct up to root and appends the content to the original cct file.
  This may be used to add additional configuration parameters which are compiler independent, e.q. "-n 1234" suppresses warning 1234.

- Rule configuration file (rcf): Can be specified with:

  .. code-block:: console

      bakeqac <options> --rcf <rcf>

  If not specified, bakeqac uses $(MCPP_HOME)/config/rcf/mcpp-1_5_1-en_US.rcf.

- Analysis configuration file (acf): Can be specified with:

  .. code-block:: console

      bakeqac <options> --acf <acf>

  If not specified, $(QAC_HOME)/config/acf/default.acf will be used.

- You can also specify the qacdata folder, default is *.qacdata*:

  .. code-block:: console

      bakeqac <options> --qacdata anotherFolder


Step 2: analyze
===============

This is the main step. Use exactly the same options for bakeqac as for bake. A few things have to be mentioned:

- *--compile-only* will be automatically added
- *--rebuild* will be automatically added

The output will be filtered per default (warnings) . To get unfiltered output, write:

.. code-block:: console

    bakeqac <options> --qacnomsgfilter

Step 3: view
============

Results are also filtered in this step if not specified otherwise:

- Only results from compiled bake projects will be shown (which does not apply to e.g. compiler libraries). To narrow the results, use the *-p* option.
- Files from subfolders test and mock will be filtered out.
- Files from projects gtest and gmock will be filtered out.

To shall ALL files:

.. code-block:: console

    bakeqac <options> --qacnofilefilter


bakeqac slightly reformats the output (originally the violated MISRA rule numbers are printed out incomplete). To switch back to raw format, use:

.. code-block:: console

    bakeqac <options> --qacrawformat

To get additional links to the appropriate documentation pages use:

.. code-block:: console

    bakeqac <options> --qacdoc

Colored output is also supported similar to bake:

.. code-block:: console

    bakeqac <options> -a <color_scheme>

Step 4: report
==============

Reports about the warnings and suppressed warnings are be generated.

Step 5: mdr
===========

Reports about cyclomatic complexity of functions.

Per default, every function with cyclomatic complexity > 10 produces a warning. To suppress this warning, the code can be annotated:

.. code-block:: console

    // METRIC STCYC 20
    int func()
    {
        // complex function
    }

In the example above the complexity can be up to 20 without a warning.
The suppression syntax is "METRIC STCYC <accepted complexity>" and must be placed above the function.

STCYC is the name of this metric in QAC.

In case of a warning or if the accepted complexity is changed, an additional info is printed out, see example output below:

.. image:: ../../_static/cyclo.png

Additional options
==================

QACPP needs a license. If floating licenses are not available, bakeqac can retry to checkout them:

.. code-block:: console

    bakeqac <options> --qacretry <seconds>

Steps "analyze" and "view" are retried until timeout is reached.

Notes
=====

If "<mainConfigName>Qac" is found in main project, it will be used instead of "<mainConfigName>. This is useful if the unit test has to be built different to MISRA.

bakeqac can suppress unsuppressible errors with "PRQA S <num>" syntax in the same line. Currently the affected error numbers are:

.. code-block:: console

    ["0019", "0020", "0031", "0034", "0035", "0036", "0061", "0098", "0099", "0224",
     "0622", "0800", "0801", "0802", "0996", "1950", "1951", "1962", "1963", "1964",
     "1965", "1966", "1967", "1968", "1969", "1970", "1971", "1972", "1973", "1974",
     "1975", "1976", "1977", "1978", "1979", "1980", "1982", "1984", "1985", "1986",
     "1987", "1989", "1990", "1991", "3104", "0014", "0015", "0016", "0021", "0022",
     "0028", "0032", "0039", "0043", "0045", "0046", "0050", "0052", "0053", "0054",
     "0058", "0059", "0079", "0083", "0101", "0133", "0150", "0165", "0170", "0174",
     "0175", "0177", "0200", "0201", "0208", "0217", "0231", "0246", "0248", "0251",
     "0253", "0255", "0257", "0271", "0276", "0278", "0279", "0282", "0284", "0285",
     "0286", "0287", "0307", "0313", "0320", "0321", "0322", "0323", "0333", "0334",
     "0335", "0336", "0339", "0400", "0401", "0403", "0404", "0405", "0415", "0424",
     "0429", "0439", "0440", "0441", "0445", "0448", "0450", "0453", "0454", "0455",
     "0456", "0457", "0458", "0459", "0469", "0481", "0482", "0483", "0484", "0491",
     "0492", "0493", "0494", "0496", "0497", "0498", "0600", "0601", "0602", "0607",
     "0608", "0611", "0616", "0617", "0619", "0620", "0621", "0627", "0631", "0632"]

