require 'common/utils'
require 'bake/toolchain/provider'
require 'bake/toolchain/errorparser/error_parser'
require 'bake/toolchain/errorparser/gcc_compiler_error_parser'
require 'bake/toolchain/errorparser/gcc_linker_error_parser'

module Bake
  module Toolchain

    def self.getGccRawVersionInfo
      `g++ --version`
    end

    def self.getGccVersion
      gccVersionStr = getGccRawVersionInfo()
      splitted = gccVersionStr.split("\n")[0].split(" ")
      vSubstr = splitted[splitted.length-1]
      vSubstr = splitted[splitted.length-2] if ((!vSubstr.include?(".") || vSubstr.match(/[a-z\-]/)) && (splitted.length >= 2))
      return vSubstr.split(".").map { |v| v.to_i }
    end

    def self.getGccPlatform
      `g++ -dumpmachine`
    end

    GCCChain = Provider.add("GCC")

    GCCChain[:COMPILER][:CPP].update({
      :COMMAND => "g++",
      :DEFINE_FLAG => "-D",
      :OBJECT_FILE_FLAG => "-o",
      :OBJ_FLAG_SPACE => true,
      :SYSTEM_INCLUDE_PATH_FLAG => "-isystem",
      :COMPILE_FLAGS => "-c ",
      :DEP_FLAGS => "-MD -MF",
      :DEP_FLAGS_SPACE => true,
      :PREPRO_FLAGS => "-E -P"
    })

    GCCChain[:COMPILER][:C] = Utils.deep_copy(GCCChain[:COMPILER][:CPP])
    GCCChain[:COMPILER][:C][:SOURCE_FILE_ENDINGS] = Provider.default[:COMPILER][:C][:SOURCE_FILE_ENDINGS]
    GCCChain[:COMPILER][:C][:COMMAND] = "gcc"

    GCCChain[:COMPILER][:ASM] = Utils.deep_copy(GCCChain[:COMPILER][:C])
    GCCChain[:COMPILER][:ASM][:SOURCE_FILE_ENDINGS] = Provider.default[:COMPILER][:ASM][:SOURCE_FILE_ENDINGS]

    GCCChain[:ARCHIVER][:COMMAND] = "ar"
    GCCChain[:ARCHIVER][:ARCHIVE_FLAGS] = "-rc"

    GCCChain[:LINKER][:COMMAND] = "g++"
    GCCChain[:LINKER][:SCRIPT] = "-T"
    GCCChain[:LINKER][:SCRIPT_SPACE] = (Bake::Utils::OS.name == "Mac" ? false : true)

    GCCChain[:LINKER][:USER_LIB_FLAG] = "-l:"
    GCCChain[:LINKER][:EXE_FLAG] = "-o"
    GCCChain[:LINKER][:LIB_FLAG] = "-l"
    GCCChain[:LINKER][:LIB_PATH_FLAG] = "-L"
    GCCChain[:LINKER][:MAP_FILE_FLAG] = (Bake::Utils::OS.name == "Mac" ? "-Wl,-map," : "-Wl,-Map=")
    GCCChain[:LINKER][:MAP_FILE_PIPE] = false

    gccCompilerErrorParser =                   GCCCompilerErrorParser.new
    GCCChain[:COMPILER][:C][:ERROR_PARSER] =   gccCompilerErrorParser
    GCCChain[:COMPILER][:CPP][:ERROR_PARSER] = gccCompilerErrorParser
    GCCChain[:COMPILER][:ASM][:ERROR_PARSER] = gccCompilerErrorParser
    GCCChain[:ARCHIVER][:ERROR_PARSER] =       gccCompilerErrorParser
    GCCChain[:LINKER][:ERROR_PARSER] =         GCCLinkerErrorParser.new

  end
end
