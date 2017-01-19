How to Debug in Visual Studio
=============================

Natively you can only debug the output from the Microsoft VC compiler with Visual Studio. There are some plugins available for e.g. debugging gcc output. Another option is to use the MSVC toolchain from bake, which is described on this help page.
Add debug flags to the MSVC toolchain:


.. code-block:: text

    DefaultToolchain MSVC {

        Compiler CPP {
            Flags "-Zi"
        }
        Linker {
            Flags "-Debug"
        }
    }

Start Visual Studio with e.g. a batch file shown below and choose the appropriate solution. If you don't have a solution yet, check out How to create a solution / projects in Visual Studio.

.. code-block:: console

    set PATH=%PATH%;C:\tools\Microsoft Visual Studio 11.0\VC\bin
    call "C:\tools\Microsoft Visual Studio 11.0\VC\vcvarsall.bat"
    "C:\tools\Microsoft Visual Studio 11.0\Common7\IDE\devenv.exe"

This adds the compiler, linker, etc. to the path. vcvarsall.bat setups the environment and the last line starts Visual Studio. As a test, just execute the first two lines and check if "cl.exe" can be executed without any errors. In Visual Studio, you have to define the executable you like to debug. Add the executable in the project properties:

.. image:: ../../_static/vs_debug.png
    :width: 100 %
    :scale: 50 %

You can also define command line arguments here.
Start debugging as usual...
