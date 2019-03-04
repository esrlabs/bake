require 'rgen/metamodel_builder'
require 'rgen/metamodel_builder/data_types'

module Bake

  module Metamodel
    extend RGen::MetamodelBuilder::ModuleExtension

    class ModelElement < RGen::MetamodelBuilder::MMBase
      abstract
      has_attr 'default', String, :defaultValueLiteral => "on"
      has_attr 'filter', String, :defaultValueLiteral => ""
      has_attr 'line_number', Integer do
        annotation :details => {'internal' => 'true'}
      end
      module ClassModule
        def fragment_ref=(fref)
          @fname = fref.fragment.location
        end

        def file_name
          @fname
        end

        def file_name=(name)
          @fname = name
        end
      end
    end

    CompilerType = RGen::MetamodelBuilder::DataTypes::Enum.new( :name => "CompilerType", :literals => [:CPP, :C, :ASM])

    class Flags < ModelElement
      has_attr 'overwrite', String, :defaultValueLiteral => ""
      has_attr 'add', String, :defaultValueLiteral => ""
      has_attr 'remove', String, :defaultValueLiteral => ""
    end
    class LibPrefixFlags < ModelElement
      has_attr 'overwrite', String, :defaultValueLiteral => ""
      has_attr 'add', String, :defaultValueLiteral => ""
      has_attr 'remove', String, :defaultValueLiteral => ""
    end
    class LibPostfixFlags < ModelElement
      has_attr 'overwrite', String, :defaultValueLiteral => ""
      has_attr 'add', String, :defaultValueLiteral => ""
      has_attr 'remove', String, :defaultValueLiteral => ""
    end
    class Define < ModelElement
      has_attr 'str', String, :defaultValueLiteral => ""
    end

    class SrcFileEndings < ModelElement
      has_attr 'endings', String, :defaultValueLiteral => ""
    end

      class InternalIncludes < ModelElement
        has_attr 'name', String, :defaultValueLiteral => ""
      end

      class InternalDefines < ModelElement
        has_attr 'name', String, :defaultValueLiteral => ""
      end

      class Archiver < ModelElement
        has_attr 'command', String, :defaultValueLiteral => ""
        has_attr 'prefix', String, :defaultValueLiteral => ""
        contains_many 'flags', Flags, 'parent'
      end

      class Linker < ModelElement
        has_attr 'command', String, :defaultValueLiteral => ""
        has_attr 'prefix', String, :defaultValueLiteral => ""
        has_attr 'onlyDirectDeps', Boolean, :defaultValueLiteral => "false"
        contains_many 'flags', Flags, 'parent'
        contains_many 'libprefixflags', LibPrefixFlags, 'parent'
        contains_many 'libpostfixflags', LibPostfixFlags, 'parent'
      end

      class Compiler < ModelElement
        has_attr 'ctype', CompilerType
        has_attr 'command', String, :defaultValueLiteral => ""
        has_attr 'cuda', Boolean, :defaultValueLiteral => "false"
        has_attr 'prefix', String, :defaultValueLiteral => ""
        contains_many 'define', Define, 'parent'
        contains_many 'flags', Flags, 'parent'
        contains_one 'internalDefines', InternalDefines, 'parent'
        contains_one 'fileEndings', SrcFileEndings, 'parent'
      end

      class LintPolicy < ModelElement
        has_attr 'name', String, :defaultValueLiteral => ""
      end

      class Docu < ModelElement
        has_attr 'name', String, :defaultValueLiteral => ""
      end

      class DefaultToolchain < ModelElement
        has_attr 'basedOn', String, :defaultValueLiteral => ""
        has_attr 'outputDir', String, :defaultValueLiteral => ""
        has_attr 'eclipseOrder', Boolean, :defaultValueLiteral => "false"
        has_attr 'keepObjFileEndings', Boolean, :defaultValueLiteral => "false"
        contains_many 'compiler', Compiler, 'parent'
        contains_one 'archiver', Archiver, 'parent'
        contains_one 'linker', Linker, 'parent'
        contains_many 'lintPolicy', LintPolicy, 'parent'
        contains_one 'internalIncludes', InternalIncludes, 'parent'
        contains_one 'docu', Docu, 'parent'
      end

      class Toolchain < ModelElement
        has_attr 'outputDir', String, :defaultValueLiteral => ""
        contains_many 'compiler', Compiler, 'parent'
        contains_one 'archiver', Archiver, 'parent'
        contains_one 'linker', Linker, 'parent'
        contains_many 'lintPolicy', LintPolicy, 'parent'
        contains_one 'docu', Docu, 'parent'
      end

      class Person < ModelElement
        has_attr 'name', String, :defaultValueLiteral => ""
        has_attr 'email', String, :defaultValueLiteral => ""
      end

      class Description < ModelElement
        has_attr 'text', String, :defaultValueLiteral => ""
      end

      class RequiredBakeVersion < ModelElement
        has_attr 'minimum', String, :defaultValueLiteral => ""
        has_attr 'maximum', String, :defaultValueLiteral => ""
      end

      class Responsible < ModelElement
        contains_many "person", Person, 'parent'
      end

      class Files < ModelElement
        has_attr 'name', String, :defaultValueLiteral => ""
        contains_many 'define', Define, 'parent'
        contains_many 'flags', Flags, 'parent'
      end

      class ExcludeFiles < ModelElement
        has_attr 'name', String, :defaultValueLiteral => ""
      end

      class BaseElement < ModelElement
      end

      class LibStuff < BaseElement
      end

      class IncludeDir < BaseElement
        has_attr 'name', String, :defaultValueLiteral => ""
        has_attr 'infix', String, :defaultValueLiteral => ""
        has_attr 'inject', String, :defaultValueLiteral => ""
        has_attr 'inherit', Boolean, :defaultValueLiteral => "false"
        has_attr 'system', Boolean, :defaultValueLiteral => "false"
      end



      class ExternalLibrary < LibStuff
        has_attr 'name', String, :defaultValueLiteral => ""
        has_attr 'search', Boolean, :defaultValueLiteral => "true"
      end

      class ExternalLibrarySearchPath < LibStuff
        has_attr 'name', String, :defaultValueLiteral => ""
      end

      class UserLibrary < LibStuff
        has_attr 'name', String, :defaultValueLiteral => ""
      end

      class Dependency < LibStuff
        has_attr 'name', String, :defaultValueLiteral => ""
        has_attr 'config', String, :defaultValueLiteral => ""
        has_attr 'inject', String, :defaultValueLiteral => ""
        has_attr 'system', Boolean, :defaultValueLiteral => "false"
      end

      class Except < ModelElement
        has_attr 'name', String, :defaultValueLiteral => ""
        has_attr 'config', String, :defaultValueLiteral => ""
      end

      class Prebuild < ModelElement
        contains_many 'except', Except, 'parent'
      end

      class Step < ModelElement
        has_attr 'name', String, :defaultValueLiteral => ""
        has_attr 'echo', String, :defaultValueLiteral => "on"
        has_attr 'independent', Boolean, :defaultValueLiteral => "false"
        has_many_attr 'validExitCodes', Integer
      end

      class Makefile < Step
        has_attr 'lib', String, :defaultValueLiteral => ""
        has_attr 'target', String, :defaultValueLiteral => ""
        has_attr 'pathTo', String, :defaultValueLiteral => ""
        has_attr 'changeWorkingDir', Boolean, :defaultValueLiteral => "true"
        has_attr 'noClean', Boolean, :defaultValueLiteral => "false"
        contains_many 'flags', Flags, 'parent'
      end

      class MakeDir < Step
      end

      class Remove < Step
      end

      class Copy < Step
        has_attr 'to', String, :defaultValueLiteral => ""
      end

      class Move < Step
        has_attr 'to', String, :defaultValueLiteral => ""
      end

      class Touch < Step
      end

      class Sleep < Step
        has_attr 'name', String, :defaultValueLiteral => "0.0"
      end

      class CommandLine < Step
      end

      class PreSteps < ModelElement
        contains_many 'step', Step, 'parent'
      end

      class PostSteps < ModelElement
        contains_many 'step', Step, 'parent'
      end

      class ExitSteps < ModelElement
        contains_many 'step', Step, 'parent'
      end

      class CleanSteps < ModelElement
        contains_many 'step', Step, 'parent'
      end

      class StartupSteps < ModelElement
        contains_many 'step', Step, 'parent'
      end

      class LinkerScript < ModelElement
        has_attr 'name', String, :defaultValueLiteral => ""
      end

      class MapFile < ModelElement
        has_attr 'name', String, :defaultValueLiteral => ""
      end

      class ArtifactName < ModelElement
        has_attr 'name', String, :defaultValueLiteral => ""
      end

      class Set < ModelElement
        has_attr 'name', String, :defaultValueLiteral => ""
        has_attr 'value', String, :defaultValueLiteral => ""
        has_attr 'cmd', String, :defaultValueLiteral => ""
        has_attr 'env', Boolean, :defaultValueLiteral => "false"
      end

      class BaseConfig_INTERNAL < ModelElement
        has_attr 'name', String, :defaultValueLiteral => ""
        has_attr 'extends', String, :defaultValueLiteral => ""
        has_attr 'type', String, :defaultValueLiteral => ""
        has_attr 'project', String, :defaultValueLiteral => ""
        has_attr 'private', Boolean, :defaultValueLiteral => "false"
        has_attr 'mergeInc', String, :defaultValueLiteral => ""
        contains_one 'description', Description, 'parent'
        contains_one 'startupSteps', StartupSteps, 'parent'
        contains_one 'preSteps', PreSteps, 'parent'
        contains_one 'postSteps', PostSteps, 'parent'
        contains_one 'exitSteps', ExitSteps, 'parent'
        contains_one 'cleanSteps', CleanSteps, 'parent'
        contains_many 'baseElement', BaseElement, 'parent'
        contains_one 'defaultToolchain', DefaultToolchain, 'parent'
        contains_one 'toolchain', Toolchain, 'parent'
        contains_many 'set', Set, 'parent'
        contains_many 'prebuild', Prebuild, 'parent'

        module ClassModule
          def ident
            s = file_name.split("/")
            s[s.length-2] + "/" + name
          end
        end

      end

      class BuildConfig_INTERNAL < BaseConfig_INTERNAL
        contains_many 'files', Files, 'parent'
        contains_many 'excludeFiles', ExcludeFiles, 'parent'
        contains_one 'artifactName', ArtifactName, 'parent'
      end

      class ExecutableConfig < BuildConfig_INTERNAL
        contains_one 'linkerScript', LinkerScript, 'parent'
        contains_one 'mapFile', MapFile, 'parent'
        module ClassModule
          def color
            "green"
          end
        end
      end

      class LibraryConfig < BuildConfig_INTERNAL
        module ClassModule
          def color
            "cyan"
          end
        end
      end

      class CustomConfig < BaseConfig_INTERNAL
        contains_one 'step', Step, 'parent'
        module ClassModule
          def color
            "red"
          end
        end
      end

      class Adapt < ModelElement
        has_attr 'toolchain', String, :defaultValueLiteral => ""
        has_attr 'os', String, :defaultValueLiteral => ""
        has_attr 'mainProject', String, :defaultValueLiteral => ""
        has_attr 'mainConfig', String, :defaultValueLiteral => ""
        contains_many 'config', BaseConfig_INTERNAL, 'parent'
      end

      class If < Adapt
      end

      class Unless < Adapt
      end

      class Project < ModelElement
        has_attr 'default', String, :defaultValueLiteral => ""
        contains_one 'description', Description, 'parent'
        contains_one 'requiredBakeVersion', RequiredBakeVersion, 'parent'
        contains_one 'responsible', Responsible, 'parent'
        contains_many 'config', BaseConfig_INTERNAL, 'parent'

        module ClassModule
           def name
            splitted = file_name.split("/")
            x = splitted[splitted.length-2]
            x
          end
        end

      end

  end

end
