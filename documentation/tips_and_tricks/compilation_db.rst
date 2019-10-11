Compilation Database
********************

With --compilation-db [<fn>] a json file with compilation infos can be generated. The filename is optional. If not specified, "compile_commands.json"
will be used.

Example output:

.. code-block:: console
  
  [
    {
      "directory": "C:/test/sub",
      "command": "g++ -c -MD -MF build/test_main_test/src/lib.d -o build/test_main_test/src/lib.o src/lib.cpp",
      "file": "src/lib.cpp"
    },
    {
      "directory": "C:/test/main",
      "command": "g++ -c -MD -MF -D TEST build/test/src/main.d -o build/test/src/main.o src/main.cpp",
      "file": "src/main.cpp"
    }
  ]
