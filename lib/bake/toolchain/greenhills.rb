require_relative '../toolchain/provider'
require_relative '../../common/utils'
require_relative '../toolchain/errorparser/greenhills_compiler_error_parser'
require_relative '../toolchain/errorparser/greenhills_linker_error_parser'

module Bake
  module Toolchain

    GreenHillsChain = Provider.add("GreenHills")

    GreenHillsChain[:COMPILER][:C].update({
      :COMMAND => "cxppc",
      :FLAGS => "",
      :DEFINE_FLAG => "-D",
      :OBJECT_FILE_FLAG => "-o",
      :OBJ_FLAG_SPACE => true,
      :COMPILE_FLAGS => "-c",
      :DEP_FLAGS => "-MD",
      :DEP_FLAGS_FILENAME => false,
      :PREPRO_FLAGS => "-P"
    })

    GreenHillsChain[:COMPILER][:CPP] = Utils.deep_copy(GreenHillsChain[:COMPILER][:C])
    GreenHillsChain[:COMPILER][:CPP][:SOURCE_FILE_ENDINGS] = Provider.default[:COMPILER][:C][:SOURCE_FILE_ENDINGS]

    GreenHillsChain[:COMPILER][:ASM] = Utils.deep_copy(GreenHillsChain[:COMPILER][:C])
    GreenHillsChain[:COMPILER][:ASM][:SOURCE_FILE_ENDINGS] = Provider.default[:COMPILER][:ASM][:SOURCE_FILE_ENDINGS]
    GreenHillsChain[:COMPILER][:ASM][:PREPRO_FLAGS] = ""
    GreenHillsChain[:COMPILER][:ASM][:PREFIX] = Provider.default[:COMPILER][:ASM][:PREFIX]

    GreenHillsChain[:ARCHIVER][:COMMAND] = "cxppc"
    GreenHillsChain[:ARCHIVER][:ARCHIVE_FLAGS] = "-archive -o"

    GreenHillsChain[:LINKER][:COMMAND] = "cxppc" # ??
    GreenHillsChain[:LINKER][:SCRIPT] = "-T" # -T file.ld
    GreenHillsChain[:LINKER][:USER_LIB_FLAG] = "-l" # user lib not supported? same as lib...
    GreenHillsChain[:LINKER][:EXE_FLAG] = "-o"
    GreenHillsChain[:LINKER][:LIB_FLAG] = "-l"
    GreenHillsChain[:LINKER][:LIB_PATH_FLAG] = "-L"
    GreenHillsChain[:LINKER][:MAP_FILE_FLAG] = "-map=" # -map=filename
    GreenHillsChain[:LINKER][:MAP_FILE_PIPE] = false
    GreenHillsChain[:LINKER][:OUTPUT_ENDING] = ".elf"

    GreenHillsCompilerErrorParser =                   GreenHillsCompilerErrorParser.new
    GreenHillsChain[:COMPILER][:C][:ERROR_PARSER] =   GreenHillsCompilerErrorParser
    GreenHillsChain[:COMPILER][:CPP][:ERROR_PARSER] = GreenHillsCompilerErrorParser
    GreenHillsChain[:COMPILER][:ASM][:ERROR_PARSER] = GreenHillsCompilerErrorParser
    GreenHillsChain[:ARCHIVER][:ERROR_PARSER] =       GreenHillsCompilerErrorParser
    GreenHillsChain[:LINKER][:ERROR_PARSER] =         GreenHillsLinkerErrorParser.new

  end
end
