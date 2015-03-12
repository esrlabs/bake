require 'common/utils'
require 'bake/toolchain/provider'

module Bake
  module Toolchain
    CLANG_ANALYZE_CHAIN = Provider.add("CLANG_ANALYZE")

    CLANG_ANALYZE_CHAIN[:COMPILER][:CPP].update({
      :COMMAND => "clang++",
      :DEFINE_FLAG => "-D",
      :OBJECT_FILE_FLAG => "-o",
      :OBJ_FLAG_SPACE => true,
      :OBJECT_FILE_ENDING => ".plist",
      :INCLUDE_PATH_FLAG => "-I",
      :COMPILE_FLAGS => "-cc1 -analyze -analyzer-output=plist ",
      :DEP_FLAGS => "",
      :DEP_FLAGS_FILENAME  => false,
      :ERROR_PARSER => nil
    })

    CLANG_ANALYZE_CHAIN[:COMPILER][:C] = Utils.deep_copy(CLANG_ANALYZE_CHAIN[:COMPILER][:CPP])
    CLANG_ANALYZE_CHAIN[:COMPILER][:C][:SOURCE_FILE_ENDINGS] = Provider.default[:COMPILER][:C][:SOURCE_FILE_ENDINGS]
    CLANG_ANALYZE_CHAIN[:COMPILER][:C][:COMMAND] = "clang"

    CLANG_ANALYZE_CHAIN[:COMPILER][:ASM] = Utils.deep_copy(CLANG_ANALYZE_CHAIN[:COMPILER][:C])
    CLANG_ANALYZE_CHAIN[:COMPILER][:ASM][:SOURCE_FILE_ENDINGS] = Provider.default[:COMPILER][:ASM][:SOURCE_FILE_ENDINGS]

    CLANG_ANALYZE_CHAIN[:ARCHIVER][:COMMAND] = ""
    CLANG_ANALYZE_CHAIN[:LINKER][:COMMAND] = ""
  end
end
