require 'common/utils'
require 'bake/toolchain/provider'
require 'bake/toolchain/errorparser/error_parser'
require 'bake/toolchain/errorparser/keil_compiler_error_parser'
require 'bake/toolchain/errorparser/keil_linker_error_parser'

module Bake
  module Toolchain

    KeilChain = Provider.add("Keil")

    KeilChain[:COMPILER][:CPP].update({
      :COMMAND => "armcc",
      :DEFINE_FLAG => "-D",
      :OBJECT_FILE_FLAG => "-o",
      :OBJ_FLAG_SPACE => true,
      :INCLUDE_PATH_FLAG => "-I",
      :COMPILE_FLAGS => "-c ",
      :DEP_FLAGS => "--depend=",
      :DEP_FLAGS_SPACE => false,
      :PREPRO_FLAGS => "-E -P"
    })

    KeilChain[:COMPILER][:C] = Utils.deep_copy(KeilChain[:COMPILER][:CPP])
    KeilChain[:COMPILER][:C][:SOURCE_FILE_ENDINGS] = Provider.default[:COMPILER][:C][:SOURCE_FILE_ENDINGS]

    KeilChain[:COMPILER][:ASM] = Utils.deep_copy(KeilChain[:COMPILER][:C])
    KeilChain[:COMPILER][:ASM][:SOURCE_FILE_ENDINGS] = Provider.default[:COMPILER][:ASM][:SOURCE_FILE_ENDINGS]
    KeilChain[:COMPILER][:ASM][:COMMAND] = "armasm"
    KeilChain[:COMPILER][:ASM][:COMPILE_FLAGS] = ""

    KeilChain[:COMPILER][:DEP_FILE_SINGLE_LINE] = true

    KeilChain[:ARCHIVER][:COMMAND] = "armar"
    KeilChain[:ARCHIVER][:ARCHIVE_FLAGS] = "--create"

    KeilChain[:LINKER][:COMMAND] = "armlink"
    KeilChain[:LINKER][:SCRIPT] = "--scatter"
    KeilChain[:LINKER][:USER_LIB_FLAG] = ""
    KeilChain[:LINKER][:EXE_FLAG] = "-o"
    KeilChain[:LINKER][:LIB_FLAG] = ""
    KeilChain[:LINKER][:LIB_PATH_FLAG] = "--userlibpath="
    KeilChain[:LINKER][:MAP_FILE_FLAG] = "--map --list="
    KeilChain[:LINKER][:MAP_FILE_PIPE] = false
    KeilChain[:LINKER][:LIST_MODE] = true

    keilCompilerErrorParser =                   KeilCompilerErrorParser.new
    KeilChain[:COMPILER][:C][:ERROR_PARSER] =   keilCompilerErrorParser
    KeilChain[:COMPILER][:CPP][:ERROR_PARSER] = keilCompilerErrorParser
    KeilChain[:COMPILER][:ASM][:ERROR_PARSER] = keilCompilerErrorParser
    KeilChain[:ARCHIVER][:ERROR_PARSER] =       keilCompilerErrorParser
    KeilChain[:LINKER][:ERROR_PARSER] =         KeilLinkerErrorParser.new

  end
end
