require 'common/utils'
require 'bake/toolchain/provider'
require 'bake/toolchain/errorparser/lint_error_parser'

module Bake
  module Toolchain

    LintChain = Provider.add("Lint")

    LintChain[:COMPILER][:CPP].update({
      :COMMAND => "lint-nt.exe",
      :DEFINE_FLAG => "-D",
      :INCLUDE_PATH_FLAG => "-I",
      :COMPILE_FLAGS => ["-b","-\"format=%f%(:%l:%) %t %n: %m\"", "-width(0)", "-hF1", "-zero"], # array, not string!
    })

    LintChain[:COMPILER][:CPP][:ERROR_PARSER] = LintErrorParser.new

  end
end
