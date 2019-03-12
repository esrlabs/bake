Merge Includes
**************

Some projects might compile faster if header files are copied into one folder.

A configuration, e.g. a LibraryConfig, can have a mergeInc flag:
    - "no" = none of the include folders of this config will ever be merged.
    - "yes" = all include folders inclusive inherited include folders will be merged when compiling this config (except include folders which configs have explicit mergeInc "no").
    - unset = when building THIS config no include folders are merged.

Usually only very few configs should have mergeInc "no". This might be necessary if source files have broken include directives.

To enable mergeInc via Adapt only for the main config:

.. code-block:: console

    Adapt {
      CustomConfig __MAIN__, project: __MAIN__, type: extend, mergeInc: "yes" # or replace instead of extend
    }

To enable mergeInc via Adapt for all configs:

.. code-block:: console

    Adapt {
      CustomConfig __ALL__, project: __ALL__, type: extend, mergeInc: "yes" # or replace instead of extend
    }

.. note::

    When mergeInc is set to "no", this cannot be overwritten by Adapt. In fact, this is the only thing which cannot be overwritten!

.. note::

    Not ALL files from an include folder are copied. The folder <projectDir>/build/ and everything beginning with <projectDir>/. will be ignored. Only files with ending h* and i* are copied.