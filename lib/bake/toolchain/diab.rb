require_relative '../toolchain/provider'
require_relative '../../common/utils'
require_relative '../toolchain/errorparser/diab_compiler_error_parser'
require_relative '../toolchain/errorparser/diab_linker_error_parser'

module Bake
  module Toolchain

    DiabChain = Provider.add("Diab")

    DiabChain[:COMPILER][:C].update({
      :COMMAND => "dcc",
      :FLAGS => "",
      :DEFINE_FLAG => "-D",
      :OBJECT_FILE_FLAG => "-o",
      :OBJ_FLAG_SPACE => true,
      :COMPILE_FLAGS => "-c",
      :DEP_FLAGS => "-Xmake-dependency=5 -Xmake-dependency-savefile=",
      :DEP_FLAGS_SPACE => false,
      :PREPRO_FLAGS => "-P"
    })

    DiabChain[:COMPILER][:CPP] = Utils.deep_copy(DiabChain[:COMPILER][:C])
    DiabChain[:COMPILER][:CPP][:SOURCE_FILE_ENDINGS] = Provider.default[:COMPILER][:CPP][:SOURCE_FILE_ENDINGS]
    DiabChain[:COMPILER][:C][:PREFIX] = Provider.default[:COMPILER][:C][:PREFIX]

    DiabChain[:COMPILER][:ASM] = Utils.deep_copy(DiabChain[:COMPILER][:C])
    DiabChain[:COMPILER][:ASM][:COMMAND] = "das"
    DiabChain[:COMPILER][:ASM][:COMPILE_FLAGS] = ""
    DiabChain[:COMPILER][:ASM][:SOURCE_FILE_ENDINGS] = Provider.default[:COMPILER][:ASM][:SOURCE_FILE_ENDINGS]
    DiabChain[:COMPILER][:ASM][:PREPRO_FLAGS] = ""
    DiabChain[:COMPILER][:ASM][:PREFIX] = Provider.default[:COMPILER][:ASM][:PREFIX]

    DiabChain[:ARCHIVER][:COMMAND] = "dar"
    DiabChain[:ARCHIVER][:ARCHIVE_FLAGS] = "-rc"

    DiabChain[:LINKER][:COMMAND] = "dcc"
    DiabChain[:LINKER][:SCRIPT] = "-Wm"
    DiabChain[:LINKER][:USER_LIB_FLAG] = "-l:"
    DiabChain[:LINKER][:EXE_FLAG] = "-o"
    DiabChain[:LINKER][:LIB_FLAG] = "-l"
    DiabChain[:LINKER][:LIB_PATH_FLAG] = "-L"
    DiabChain[:LINKER][:MAP_FILE_FLAG] = "-Wl,-m6" # no map file if this string is empty, otherwise -Wl,-m6>abc.map
    DiabChain[:LINKER][:OUTPUT_ENDING] = ".elf"

    diabCompilerErrorParser =                   DiabCompilerErrorParser.new
    DiabChain[:COMPILER][:C][:ERROR_PARSER] =   diabCompilerErrorParser
    DiabChain[:COMPILER][:CPP][:ERROR_PARSER] = diabCompilerErrorParser
    DiabChain[:COMPILER][:ASM][:ERROR_PARSER] = diabCompilerErrorParser
    DiabChain[:ARCHIVER][:ERROR_PARSER] =       diabCompilerErrorParser
    DiabChain[:LINKER][:ERROR_PARSER] =         DiabLinkerErrorParser.new

  end
end
