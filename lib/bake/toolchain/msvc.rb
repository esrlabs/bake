require_relative '../../common/utils'
require_relative '../toolchain/provider'
require_relative '../toolchain/errorparser/error_parser'
require_relative '../toolchain/errorparser/msvc_compiler_error_parser'
require_relative '../toolchain/errorparser/msvc_linker_error_parser'

module Bake
  module Toolchain

    MSVCChain = Provider.add("MSVC")

    MSVCChain[:COMPILER][:CPP].update({
      :COMMAND => "cl",
      :DEFINE_FLAG => "-D",
      :OBJECT_FILE_FLAG => "-Fo",
      :OBJ_FLAG_SPACE => false,
      :COMPILE_FLAGS => "-c -EHsc $(MSVC_FORCE_SYNC_PDB_WRITES)",
      :DEP_FLAGS_FILENAME => false,
      :DEP_FLAGS => "-showIncludes",
      :DEP_FLAGS_SPACE => true,
      :PREPRO_FLAGS => "-P",
      :PREPRO_FILE_FLAG => "-Fi"
    })

    MSVCChain[:COMPILER][:C] = Utils.deep_copy(MSVCChain[:COMPILER][:CPP])
    MSVCChain[:COMPILER][:C][:SOURCE_FILE_ENDINGS] = Provider.default[:COMPILER][:C][:SOURCE_FILE_ENDINGS]
    MSVCChain[:COMPILER][:C][:PREFIX] = Provider.default[:COMPILER][:C][:PREFIX]

    MSVCChain[:COMPILER][:ASM] = Utils.deep_copy(MSVCChain[:COMPILER][:C])
    MSVCChain[:COMPILER][:ASM][:COMMAND] = "ml"
    MSVCChain[:COMPILER][:ASM][:COMPILE_FLAGS] = "-c $(MSVC_FORCE_SYNC_PDB_WRITES)"
    MSVCChain[:COMPILER][:ASM][:SOURCE_FILE_ENDINGS] = Provider.default[:COMPILER][:ASM][:SOURCE_FILE_ENDINGS]
    MSVCChain[:COMPILER][:ASM][:PREFIX] = Provider.default[:COMPILER][:ASM][:PREFIX]

    MSVCChain[:ARCHIVER][:COMMAND] = "lib"
    MSVCChain[:ARCHIVER][:ARCHIVE_FLAGS] = "-out:"
    MSVCChain[:ARCHIVER][:ARCHIVE_FLAGS_SPACE] = false

    MSVCChain[:LINKER][:COMMAND] = "link"
    MSVCChain[:LINKER][:USER_LIB_FLAG] = ""
    MSVCChain[:LINKER][:EXE_FLAG] = "-out:"
    MSVCChain[:LINKER][:EXE_FLAG_SPACE] = false
    MSVCChain[:LINKER][:LIB_FLAG] = ""
    MSVCChain[:LINKER][:LIB_PATH_FLAG] = "-libpath:"
    MSVCChain[:LINKER][:MAP_FILE_FLAG] = "-map:"
    MSVCChain[:LINKER][:MAP_FILE_PIPE] = false
    MSVCChain[:LINKER][:SCRIPT] = "Linkerscript option not supported for MSVC"


    msvcCompilerErrorParser =                   MSVCCompilerErrorParser.new
    MSVCChain[:COMPILER][:C][:ERROR_PARSER] =   msvcCompilerErrorParser
    MSVCChain[:COMPILER][:CPP][:ERROR_PARSER] = msvcCompilerErrorParser
    MSVCChain[:COMPILER][:ASM][:ERROR_PARSER] = msvcCompilerErrorParser
    MSVCChain[:ARCHIVER][:ERROR_PARSER] =       msvcCompilerErrorParser
    MSVCChain[:LINKER][:ERROR_PARSER] =         MSVCLinkerErrorParser.new

  end
end

