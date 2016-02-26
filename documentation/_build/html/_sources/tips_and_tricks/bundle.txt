Bundle projects
***************

.. warning::

    This feature is experimental!

With

.. code-block:: console

    bake ... --bundle <outputDir>
       
the projects will be bundled. This means

* linked binaries are copied to <outputDir>/bin
* created libraries are copied to <outputDir>/lib
* sources from the main project are copied to <outputDir>
* includes needed by the main projects are copied to <outputDir>/inc
* A Project.meta will be created in <outputDir>.
  
This is a starting point for further manual adaptions.

Feedback welcome!
