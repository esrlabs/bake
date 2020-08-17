require_relative'../../common/utils'
require_relative '../toolchain/provider'
require_relative '../toolchain/errorparser/error_parser'
require_relative '../toolchain/errorparser/gcc_compiler_error_parser'
require_relative '../toolchain/errorparser/gcc_linker_error_parser'

module Bake
  module Toolchain
    CLANG_BITCODE_CHAIN = Provider.add("CLANG_BITCODE")

    CLANG_BITCODE_CHAIN[:COMPILER][:CPP].update({
      :COMMAND => "clang++",
      :DEFINE_FLAG => "-D",
      :OBJECT_FILE_FLAG => "-o",
      :OBJ_FLAG_SPACE => true,
      :OBJECT_FILE_ENDING => ".bc",
      :COMPILE_FLAGS => "-emit-llvm -c ",
      :ERROR_PARSER => nil,
      :DEP_FLAGS => "-MD -MF",
      :DEP_FLAGS_SPACE => true,
    })

    CLANG_BITCODE_CHAIN[:COMPILER][:C] = Utils.deep_copy(CLANG_BITCODE_CHAIN[:COMPILER][:CPP])
    CLANG_BITCODE_CHAIN[:COMPILER][:C][:SOURCE_FILE_ENDINGS] = Provider.default[:COMPILER][:C][:SOURCE_FILE_ENDINGS]
    CLANG_BITCODE_CHAIN[:COMPILER][:C][:COMMAND] = "clang"

    CLANG_BITCODE_CHAIN[:ARCHIVER][:COMMAND] = "llvm-link"
    CLANG_BITCODE_CHAIN[:ARCHIVER][:ARCHIVE_FLAGS] = "-o"
    CLANG_BITCODE_CHAIN[:ARCHIVER][:ARCHIVE_FILE_ENDING] = ".bc"

    CLANG_BITCODE_CHAIN[:LINKER][:COMMAND] = "llvm-link"
    CLANG_BITCODE_CHAIN[:LINKER][:EXE_FLAG] = "-o"
  end
end
