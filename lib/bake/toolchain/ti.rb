require_relative '../../common/utils'
require_relative '../toolchain/provider'
require_relative '../toolchain/errorparser/error_parser'
require_relative '../toolchain/errorparser/ti_compiler_error_parser'
require_relative '../toolchain/errorparser/ti_linker_error_parser'

module Bake
  module Toolchain

    TiChain = Provider.add("TI")

    TiChain[:COMPILER][:CPP].update({
      :COMMAND => "ti_cl",
      :FLAGS => "",
      :DEFINE_FLAG => "--define=",
      :OBJECT_FILE_FLAG => "--output_file=",
      :INCLUDE_PATH_FLAG => "--include_path=",
      :SYSTEM_INCLUDE_PATH_FLAG => "--include_path=",
      :COMPILE_FLAGS => "-c ",
      :DEP_FLAGS => "--preproc_dependency=",
      :DEP_FLAGS_SPACE => false
    })

    TiChain[:COMPILER][:C] = Utils.deep_copy(TiChain[:COMPILER][:CPP])
    TiChain[:COMPILER][:C][:SOURCE_FILE_ENDINGS] = Provider.default[:COMPILER][:C][:SOURCE_FILE_ENDINGS]

    TiChain[:COMPILER][:ASM] = Utils.deep_copy(TiChain[:COMPILER][:C])
    TiChain[:COMPILER][:ASM][:SOURCE_FILE_ENDINGS] = Provider.default[:COMPILER][:ASM][:SOURCE_FILE_ENDINGS]
    TiChain[:COMPILER][:ASM][:PREFIX] = Provider.default[:COMPILER][:ASM][:PREFIX]

    TiChain[:COMPILER][:DEP_FILE_SINGLE_LINE] = true

    TiChain[:ARCHIVER][:COMMAND] = "ti_ar"
    TiChain[:ARCHIVER][:ARCHIVE_FLAGS] = "r"

    TiChain[:LINKER][:COMMAND] = "ti_cl"
    TiChain[:LINKER][:FLAGS] = ""
    TiChain[:LINKER][:MAP_FILE_FLAG] = '-m'
    TiChain[:LINKER][:EXE_FLAG] = "-o"
    TiChain[:LINKER][:LIB_FLAG] = "-l"
    TiChain[:LINKER][:LIB_PATH_FLAG] = "-i"

    tiCompilerErrorParser =                   TICompilerErrorParser.new
    TiChain[:COMPILER][:C][:ERROR_PARSER] =   tiCompilerErrorParser
    TiChain[:COMPILER][:CPP][:ERROR_PARSER] = tiCompilerErrorParser
    TiChain[:COMPILER][:ASM][:ERROR_PARSER] = tiCompilerErrorParser
    TiChain[:ARCHIVER][:ERROR_PARSER] =       tiCompilerErrorParser
    TiChain[:LINKER][:ERROR_PARSER] =         TILinkerErrorParser.new

  end
end
