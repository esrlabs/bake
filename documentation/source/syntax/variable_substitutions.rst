Variables in Project.meta
=========================
bake allows you to use

- user defined
- predefined
- environment

variables in your Project.meta file. Every environment and predefined variable can be overwritten by the user.
If a variable is not found at all, it will be set to an empty string (see below how to change that default behaviour).

Using variables
***************

Variables can be used using the following syntax:

.. code-block:: console

   $(ABC)

The variable ABC will be substituted by its value, therefore a real life usage would look
something like this:

.. code-block:: console

   IncludeDir "$(ABC)"

User defined variables
**********************

There are two ways to create user defined variables.

#. The variable is defined with the `--set` command line option:

.. code-block:: console

    User@Host:~$ bake ... --set MyVar="Hello world!"

#. The variable is defined directly in the Project.meta file.

.. code-block:: console

    Set MyVar, value: "Hello world!"
    Set MyVar, cmd: "ruby calcVar.rb"

In the latter one the variable is set to the output of the command.

Predefined bake environment variables
*************************************

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

*$(OutputDir)*                              Evaluates to the full path of the output            build/lib_bootloader_Debug
                                            directory of the current config

*$(OutputDir,projName,confName)*            Evaluates to the output dir of a specific           build/lib_some_Debug
                                            config

*$(WorkingDir)*                             Directory from which bake is called                 c:/Workspaces/Project

*$(OriginalDir)*                            Directory of the containing meta file.              c:/Root/admin/adapt/coverage
                                            Useful for relative paths from Adapt files.

*$(ArtifactName)*                           Evaluates to the artifact.                          bootloader_1.0.elf

*$(ArtifactNameBase)*                       Evaluates to the base artifact name                 bootloader_1.0
                                            (Without file exension)

*$(Time)*                                   Evaluates to the current time                       2012-12-24 20:00:00 +0200

*$(Hostname)*                               Evaluates to the hostname                           MY_COMPUTER

*$(Uid)*                                    CRC32 over relative path to MainProjectDir          03FAB429
                                            plus MainConfigName, e.g.
                                            "../libs/utils,Debug"

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

*$(ToolchainName)*                          Names of the used DefaultToolchain                  GCC

*$(/)*                                      Evalutes to the directory path seperator of         Windows: \\, Other: /
                                            the current platform

*$(:)*                                      Evaluates to the path variable seperator            Windows: ;, Other: :
                                            of the current platform

*$(QacActive)*                              Evaluates to "yes" if QAC is running (via           yes, no
                                            bakeqac), otherwise "no".
========================================    ===============================================     ========================================

Environment variables
*********************

Usually used if system dependent stuff is needed like path to a specific tool etc.

Nested variables
****************
It is also possible to nest variables.

Example:

.. code-block:: console

    $(ABC$(DEF)GH)


Complex variables
*****************

bake supports three complex variables:

.. code-block:: console

    $(OutputDir, <project name>, <config name>)
    e.g.:
    $(OutputDir, MyGreatLib, Debug)

This will evaluate to the output directory of a specific configuration.

.. code-block:: console

    $(ProjectDir, <project name>)

This will evaluate to the directory of a specific project.

.. code-block:: console

    $(FilterArguments, <filterName>)

If a filter is specified, the argument of the filter is returned.

Example:

- cmd: "bake ... --do run=--gtest_repeat=2"
- Project.meta: $(FilterArguments, --gtest_repeat)
- result: 2

Mandatory variables
*******************

If a variable is not found at all, it will be set to an empty string.
This can be changed to an error with a "!" sign:

.. code-block:: console

    $(PATH_TO_ABC!)
    $(OutputDir!, application, Debug)

For convenience, the "!" can be used on every parameter (which means exactly the same as using on the first parameter).

.. code-block:: console

    $(OutputDir, application!, Debug)
    $(OutputDir, application, Debug!)

Notes and warnings
******************

Equal variables in the main config:

========================================    ========================================
Variable                                    Is equal to
========================================    ========================================
$(MainConfigName)                           $(ConfigName)

$(MainProjectName)                          $(ProjectName)
========================================    ========================================

.. warning::

    Variables in Dependency definitions are not allowed!