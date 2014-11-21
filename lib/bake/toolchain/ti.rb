require 'imported/utils/utils'
require 'bake/toolchain/provider'
require 'bake/toolchain/errorparser/error_parser'
require 'bake/toolchain/errorparser/ti_compiler_error_parser'
require 'bake/toolchain/errorparser/ti_linker_error_parser'

module Bake
  module Toolchain

    TiChain = Provider.add("TI")

    ti_home = ENV['TI_HOME'] 

    TiChain[:COMPILER][:CPP].update({
      :COMMAND => "#{ti_home}/ccsv5/tools/compiler/tms470/bin/cl470",
      :FLAGS => "-mv7A8 -g --include_path=\"#{ti_home}/ccsv5/tools/compiler/tms470/include\" --diag_warning=225 -me --abi=eabi --code_state=32 --preproc_with_compile",
      :DEFINE_FLAG => "--define=",
      :OBJECT_FILE_FLAG => "--output_file=",
      :INCLUDE_PATH_FLAG => "--include_path=",
      :COMPILE_FLAGS => "-c ",
      :DEP_FLAGS => "--preproc_dependency=",
      :DEP_FLAGS_SPACE => false
    })

    TiChain[:COMPILER][:C] = Utils.deep_copy(TiChain[:COMPILER][:CPP])
    TiChain[:COMPILER][:C][:SOURCE_FILE_ENDINGS] = Provider.default[:COMPILER][:C][:SOURCE_FILE_ENDINGS]

    TiChain[:COMPILER][:ASM] = Utils.deep_copy(TiChain[:COMPILER][:C])
    TiChain[:COMPILER][:ASM][:SOURCE_FILE_ENDINGS] = Provider.default[:COMPILER][:ASM][:SOURCE_FILE_ENDINGS]

    TiChain[:ARCHIVER][:COMMAND] = "#{ti_home}/ccsv5/tools/compiler/tms470/bin/ar470"
    TiChain[:ARCHIVER][:ARCHIVE_FLAGS] = "r"

    TiChain[:LINKER][:COMMAND] = "#{ti_home}/ccsv5/tools/compiler/tms470/bin/cl470"
    TiChain[:LINKER][:FLAGS] = "-mv7A8 -g --diag_warning=225 -me --abi=eabi --code_state=32 -z --warn_sections -i\"#{ti_home}/ccsv5/tools/compiler/tms470/lib\" -i\"#{ti_home}/ccsv5/tools/compiler/tms470/include\""
    TiChain[:LINKER][:MAP_FILE_FLAG] = '-m'
    TiChain[:LINKER][:EXE_FLAG] = "-o"
    TiChain[:LINKER][:LIB_PREFIX_FLAGS] = '-lDebug/configPkg/linker.cmd'
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
