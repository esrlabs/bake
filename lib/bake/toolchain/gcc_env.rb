require_relative '../../common/utils'
require_relative '../toolchain/provider'
require_relative '../toolchain/errorparser/error_parser'
require_relative '../toolchain/errorparser/gcc_compiler_error_parser'
require_relative '../toolchain/errorparser/gcc_linker_error_parser'

module Bake
  module Toolchain

    GCCENVChain = Provider.add("GCC_ENV")

    GCCENVChain[:COMPILER][:CPP].update({
      :COMMAND => "$(CXX)",
      :DEFINE_FLAG => "-D",
      :OBJECT_FILE_FLAG => "-o",
      :OBJ_FLAG_SPACE => true,
      :COMPILE_FLAGS => "-c ",
      :DEP_FLAGS => "-MD -MF",
      :DEP_FLAGS_SPACE => true,
      :PREPRO_FLAGS => "-E -P",
      :FLAGS => "$(CXXFLAGS)"
    })

    GCCENVChain[:COMPILER][:C] = Utils.deep_copy(GCCENVChain[:COMPILER][:CPP])
    GCCENVChain[:COMPILER][:C][:SOURCE_FILE_ENDINGS] = Provider.default[:COMPILER][:C][:SOURCE_FILE_ENDINGS]
    GCCENVChain[:COMPILER][:C][:COMMAND] = "$(CC)"
    GCCENVChain[:COMPILER][:C][:FLAGS] = "$(CFLAGS)"

    GCCENVChain[:COMPILER][:ASM] = Utils.deep_copy(GCCENVChain[:COMPILER][:C])
    GCCENVChain[:COMPILER][:ASM][:COMMAND] = "$(AS)"
    GCCENVChain[:COMPILER][:ASM][:SOURCE_FILE_ENDINGS] = Provider.default[:COMPILER][:ASM][:SOURCE_FILE_ENDINGS]
    GCCENVChain[:COMPILER][:ASM][:FLAGS] = "$(ASFLAGS)"

    GCCENVChain[:ARCHIVER][:COMMAND] = "$(AR)"
    GCCENVChain[:ARCHIVER][:ARCHIVE_FLAGS] = "-rc"
    GCCENVChain[:ARCHIVER][:FLAGS] = "$(ARFLAGS)"

    GCCENVChain[:LINKER][:COMMAND] = "$(CXX)"
    GCCENVChain[:LINKER][:SCRIPT] = "-T"
    GCCENVChain[:LINKER][:USER_LIB_FLAG] = "-l:"
    GCCENVChain[:LINKER][:EXE_FLAG] = "-o"
    GCCENVChain[:LINKER][:LIB_FLAG] = "-l"
    GCCENVChain[:LINKER][:LIB_PATH_FLAG] = "-L"
    GCCENVChain[:LINKER][:FLAGS] = "$(LDFLAGS)"

    gccCompilerErrorParser =                      GCCCompilerErrorParser.new
    GCCENVChain[:COMPILER][:C][:ERROR_PARSER] =   gccCompilerErrorParser
    GCCENVChain[:COMPILER][:CPP][:ERROR_PARSER] = gccCompilerErrorParser
    GCCENVChain[:COMPILER][:ASM][:ERROR_PARSER] = gccCompilerErrorParser
    GCCENVChain[:ARCHIVER][:ERROR_PARSER] =       gccCompilerErrorParser
    GCCENVChain[:LINKER][:ERROR_PARSER] =         GCCLinkerErrorParser.new

  end
end
