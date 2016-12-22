require 'common/utils'
require 'bake/toolchain/provider'
require 'bake/toolchain/errorparser/error_parser'
require 'bake/toolchain/errorparser/gcc_compiler_error_parser'
require 'bake/toolchain/errorparser/gcc_linker_error_parser'

module Bake
  module Toolchain
    gccCompilerErrorParser = GCCCompilerErrorParser.new

    CLANG_CHAIN = Provider.add("CLANG")

    CLANG_CHAIN[:COMPILER][:CPP].update({
      :COMMAND => "clang++",
      :DEFINE_FLAG => "-D",
      :OBJECT_FILE_FLAG => "-o",
      :OBJ_FLAG_SPACE => true,
      :COMPILE_FLAGS => "-c ",
      :DEP_FLAGS => "-MD -MF",
      :DEP_FLAGS_SPACE => true,
      :ERROR_PARSER => gccCompilerErrorParser
    })

    CLANG_CHAIN[:COMPILER][:C] = Utils.deep_copy(CLANG_CHAIN[:COMPILER][:CPP])
    CLANG_CHAIN[:COMPILER][:C][:SOURCE_FILE_ENDINGS] = Provider.default[:COMPILER][:C][:SOURCE_FILE_ENDINGS]
    CLANG_CHAIN[:COMPILER][:C][:COMMAND] = "clang"

    CLANG_CHAIN[:COMPILER][:ASM] = Utils.deep_copy(CLANG_CHAIN[:COMPILER][:C])
    CLANG_CHAIN[:COMPILER][:ASM][:SOURCE_FILE_ENDINGS] = Provider.default[:COMPILER][:ASM][:SOURCE_FILE_ENDINGS]

    CLANG_CHAIN[:ARCHIVER][:COMMAND] = "ar"
    CLANG_CHAIN[:ARCHIVER][:ARCHIVE_FLAGS] = "r"
    CLANG_CHAIN[:ARCHIVER][:ERROR_PARSER] = gccCompilerErrorParser

    CLANG_CHAIN[:LINKER][:COMMAND] = "clang++"
    CLANG_CHAIN[:LINKER][:SCRIPT] = "-T"
    CLANG_CHAIN[:LINKER][:USER_LIB_FLAG] = "-l:"
    CLANG_CHAIN[:LINKER][:EXE_FLAG] = "-o"
    CLANG_CHAIN[:LINKER][:LIB_FLAG] = "-l"
    CLANG_CHAIN[:LINKER][:LIB_PATH_FLAG] = "-L"

    CLANG_CHAIN[:LINKER][:ERROR_PARSER] = GCCLinkerErrorParser.new
  end
end
