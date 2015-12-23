How to create VS-Projects using bake
====================================

bake projects are Makefile projects (NMake). When creating a new project, you can just create a new Makefile project and add a Project.meta.
The recommended way is to use a script which comes with bake-toolkit:

    .. image:: ../../_static/cvsp.png
        :width: 100 %
        :scale: 50 %

Example:

.. code-block:: console

    C:\MyProj>  createVSProjects --version 2012 --rewrite
