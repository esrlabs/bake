How to debug in Eclipse
=======================

The following example is made with Eclipse Mars, **Cygwin**, **gcc** and **gdb**. However, the same applies to all other compilers and
environments, too.

1. Compile with debug information
*********************************

Don't forget this. Otherwise sources symbols cannot not mapped.

.. image:: ../../../_static/debug_flag.png

2. Create a debug configuration for a C++ application
*****************************************************

This options can be found under Run->Debug Configurations... or click on the arrow next to the green spider.

.. image:: ../../../_static/debug_app.png

|  Choose a suitable name and the executable.

3. Add path mapping
*******************

.. image:: ../../../_static/debug_path.png

.. image:: ../../../_static/debug_map.png

|  Note that this must be done if the compiler uses different paths than Eclipse. In this example I have used gcc under Cygwin,
|  which typically uses "/cygdrive/c" for "c:\\". I always mount "c:\\" to "/c".
|
|  Also note, that my Eclipse changes "/c" to "\\c" in the dialog box automatically, but it works nevertheless.

4. Now you can debug your code
******************************

.. image:: ../../../_static/debug_debug.png
