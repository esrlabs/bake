Prebuild configurations for distributions
*****************************************

This is a useful feature if you want to make a part of workspace available for third party without changing the configuration.

There are two major use cases:

- Only a few projects shall be closed source (e.g. to hide some algorithms)
- Only a few projects shall be open source (e.g. if a supplier has integrate a library)

Both is possible with bake, but the current UI is optimized for the latter one.

Add in the Project.meta the following code:

.. code-block:: console

    Prebuild {
      Except main, config: Debug
      Except newLib, config: Debug
      Except setup, config: Release
    }

It is possible to specify the Prebuild tags in all configurations, not only in the main configuration. Logically they will be merged.

In the example above, no configurations will be built - except those three. The prebuild output is used directly.

To reference a configuration of the same project, omit the project name, e.g.:

.. code-block:: console

    Except config: Base

To reference all configuration of a project, omit the config name, e.g.:

.. code-block:: console

    Except newLib


This prebuild behaviour must be explicitly turned on by using the following the command line argument:

.. code-block:: console

    --prebuild

Note, that if objects files exist, the library will be built from existing object files (glob for \*.o in appropriate build folder). If only the archive exists, the archive will be used without building it.

Typical workflow
----------------

1. Compiling the workspace completely without prebuild feature.
2. Executing a distribution script which copies all relevant files to a distribution directory.
   Make sure to add all header files of prebuild libraries if they are needed for other non-prebuild libraries.
   You may use the dependency files in the output directory for that script.
3. In the distribution folder use "--prebuild" when compiling the workspace.


