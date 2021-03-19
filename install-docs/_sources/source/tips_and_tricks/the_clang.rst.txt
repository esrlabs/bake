Clang Analyze
=============

bake can be easily used to analyze source files with Clang. It works simliar to regular compiling, but instead of
invoking the compiler, the Clang Analyzer will be called.

Imagine you have a workspace with the following "main" project:

    .. code-block:: console

		Project {
          ...
          ExecutableConfig Debug {
            ...
            DefaultToolchain GCC
          }
        }

Either edit this Project.meta or create a new "analyze" project:

    .. code-block:: console

        Project {
          CustomConfig Analyze {
            Dependency main, config: Debug
            DefaultToolchain CLANG_ANALYZE {
              Compiler CPP {
                Flags "-analyzer-checker=deadcode,security,alpha,unix,cplusplus"
              }
              Compiler C {
                Flags "-analyzer-checker=deadcode,security,alpha,unix"
              }
            }
          }
        }

As you can see the DefaultToolchain GCC is replaced with CLANG_ANALYZE. Call bake like this:

    .. code-block:: console

        bake Analyze -f .

"-f" means that only the compilation step will take place. The "." means files with a "." in the name will be compiled (= all files). If you want to analyze only C++ files, you can write "-f .cpp"
