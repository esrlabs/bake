require_relative '../toolchain/provider'
require_relative '../../common/utils'
require_relative '../toolchain/errorparser/tasking_compiler_error_parser'
require_relative '../toolchain/errorparser/tasking_linker_error_parser'

module Bake
  module Toolchain

    TaskingChain = Provider.add("Tasking")

    TaskingChain[:COMPILER][:C].update({
      :COMMAND => "cctc",
      :FLAGS => "",
      :DEFINE_FLAG => "-D",
      :OBJECT_FILE_FLAG => "-o",
      :OBJ_FLAG_SPACE => true,
      :COMPILE_FLAGS => "-c",
      :DEP_FLAGS => "--dep-file=",
      :DEP_FLAGS_SPACE => false,
      :PREPRO_FLAGS => "-P"
    })

    TaskingChain[:COMPILER][:CPP] = Utils.deep_copy(TaskingChain[:COMPILER][:C])
    TaskingChain[:COMPILER][:CPP][:SOURCE_FILE_ENDINGS] = Provider.default[:COMPILER][:CPP][:SOURCE_FILE_ENDINGS]

    TaskingChain[:COMPILER][:ASM] = Utils.deep_copy(TaskingChain[:COMPILER][:C])
    TaskingChain[:COMPILER][:ASM][:COMMAND] = "astc"
    TaskingChain[:COMPILER][:ASM][:COMPILE_FLAGS] = ""
    TaskingChain[:COMPILER][:ASM][:SOURCE_FILE_ENDINGS] = Provider.default[:COMPILER][:ASM][:SOURCE_FILE_ENDINGS]
    TaskingChain[:COMPILER][:ASM][:PREPRO_FLAGS] = ""

    TaskingChain[:ARCHIVER][:COMMAND] = "artc"
    TaskingChain[:ARCHIVER][:ARCHIVE_FLAGS] = "-rcu"

    TaskingChain[:LINKER][:COMMAND] = "cctc"
    TaskingChain[:LINKER][:SCRIPT] = "--lsl-file="
    TaskingChain[:LINKER][:SCRIPT_SPACE] = false
    TaskingChain[:LINKER][:USER_LIB_FLAG] = "-l"
    TaskingChain[:LINKER][:EXE_FLAG] = "-o"
    TaskingChain[:LINKER][:LIB_FLAG] = "-l"
    TaskingChain[:LINKER][:LIB_PATH_FLAG] = "-L"
    TaskingChain[:LINKER][:MAP_FILE_PIPE] = false
    TaskingChain[:LINKER][:MAP_FILE_FLAG] = "--map-file="
    TaskingChain[:LINKER][:OUTPUT_ENDING] = ".elf"

    taskingCompilerErrorParser =                   TaskingCompilerErrorParser.new
    TaskingChain[:COMPILER][:C][:ERROR_PARSER] =   taskingCompilerErrorParser
    TaskingChain[:COMPILER][:CPP][:ERROR_PARSER] = taskingCompilerErrorParser
    TaskingChain[:COMPILER][:ASM][:ERROR_PARSER] = taskingCompilerErrorParser
    TaskingChain[:ARCHIVER][:ERROR_PARSER] =       taskingCompilerErrorParser
    TaskingChain[:LINKER][:ERROR_PARSER] =         TaskingLinkerErrorParser.new

    TaskingChain[:COMPILER][:DEP_FILE_SINGLE_LINE] = true
  end
end
