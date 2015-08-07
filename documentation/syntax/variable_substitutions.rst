Variables in Project.meta
=========================
Bake allows you to use pre defined and/or user defined variables in your Project.meta file.
Defined variables then can be used using the following syntax:

.. code-block:: console
    
   $(MyIncludes)

The variable MyIncludes will be substitued by its value, therefore a real life usage would look
something like this:

.. code-block:: console
    
   IncludeDir "$(MyIncludes)"

User defined variables
**********************

There are two ways to create user defined variables.

#. The variable is defined with the `--set` command line option:

.. code-block:: console
 
    User@Host:~$ bake ... --set MyVar="Hello world!"

#. THe variable is defined directly in the Project.meta file.

.. code-block:: console

    Set MyVar, value: "Hello world!"              


Pre defined bake environment variables 
**************************************

========================================    ===============================================     ========================================
Variable                                    Description                                         Example
========================================    ===============================================     ========================================
*$(MainConfigName)*                         Evaluates to the main config name                   Debug

*$(MainProjectName)*                        Evaluates to the main project name                  bootloader

*$(ConfigName)*                             Evaluates to the config name                        lib

*$(ProjectName)*                            Evaluates to the project name                       canDriver

*$(ProjectDir)*                             Evaluates to the full path of the project           C:/Root/MyProject
                                            directory

*$(MainProjectDir)*                         Evaluates to the full path of the root projec       C:/Root/Main
                                            directory                                           

*$(OutputDir)*                              Evaluates to the full path of the output            build_lib_bootloader_Debug
                                            directory of the current config

*$(OutputDir,projName,confName)*            Evaluates to the output dir of a specific           build_lib_some_Debug
                                            config

*$(ArtifactName)*                           Evaluates to the artifact.                          bootloader_1.0.elf

*$(ArtifactNameBase)*                       Evaluates to the base artifact name                 bootloader_1.0
                                            (Without file exension)

*$(Time)*                                   Evaluates to the current time                       2012-12-24 20:00:00 +0200

*$(Hostname)*                               Evaluates to the hostname                           MY_COMPUTER

*$(CPPPath)*                                Evaluates to the base path of the                   /usr/bin
                                            c++ compiler

*$(CPath)*                                  Evaluates to the base path of the                   /usr/bin
                                            c compiler

*$(ASMPath)*                                Evaluates to the base path of the                   /usr/bin
                                            assembler

*$(ArchiverPath)*                           Evaluates to the base path of the                   /usr/bin
                                            archiver

*$(LinkerPath)*                             Evaluates to the base path of the                   /usr/bin
                                            linker

*$(/)*                                      Evalutes to the directory path seperator of         Windows: \\, Other: /
                                            the current platform

*$(:)*                                      Evaluates to the path variable seperator            Windows: ;, Other: :
                                            of the current platform
========================================    ===============================================     ========================================

.. tip:: 

    It is also possible to retrieve arbitrary an *environment variable* using the following syntax:

    .. code-block:: console
        
        $(EnvironmentVariable)

    Evaluates to the Environment with the specified name, if the specified environment variable does not exists
    it will be substituted by an empty string.

.. note::

    Equal variables in the main config

    ========================================    ========================================
    Variable                                    Is equal to 
    ========================================    ========================================
    $(MainConfigName)                           $(ConfigName)

    $(MainProjectName)                          $(ProjectName)
    ========================================    ========================================

.. warning::

    Variables in Dependency definitions are not allowed!


Nested variables
****************
It is also possible to nest variables.

Example:

.. code-block:: console
    
    $(OutputDir,$(TheProject),$(TheConfig))
    $(ABC$(DEF)GH)


Auto-adjustment of paths to existing projects
*********************************************
.. warning::

    If paths to other projects are needed, e.g. to "bootloaderUpdater", don't write a hard coded relative path like this:
    
    .. code-block:: plain

        CommandLine "../bootloaderUpdater/tools/PrimaryBootloader2Include.exe

If paths to other projects are needed, e.g. to "bootloaderUpdater" just reference it starting from the project folder.

Example:

.. code-block:: plain

    CommandLine "bootloaderUpdater/tools/PrimaryBootloader2Include.exe

or:

.. code-block:: plain

    IncludeDir "myProjectName/bootloaderUpdater/whatever"



Bake recognizes that the first part of the path is a valid project name and calculates the relative path to the project automatically.
If you have the special case that the referenced project is contained in an other workspace root, you can use the 
`-w` parameter or you define a `roots.bake`_.

.. note::

    The path auto adjustment is applied for the following elements:

    * IncludeDir

    * ExternalLibrary

    * ExternalLibrarySearchPath

    * UserLibrary
      
    * CommandLine

