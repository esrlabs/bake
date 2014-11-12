require 'imported/toolchain/colorizing_formatter'

module Bake
  module Toolchain

    class Provider
      @@settings = {}
      @@default = {
        :COMPILER =>
        {
          :CPP => {
            :COMMAND => "",
            :DEFINE_FLAG => "",
            :OBJECT_FILE_FLAG => "",
            :INCLUDE_PATH_FLAG => "",
            :COMPILE_FLAGS => "",
            :DEFINES => [],
            :FLAGS => "",
            :SOURCE_FILE_ENDINGS => [".cxx", ".cpp", ".c++", ".cc", ".C"],
            :DEP_FLAGS => "",
            :DEP_FLAGS_SPACE => false,
            :DEP_FLAGS_FILENAME => true,
            :ERROR_PARSER => nil,
            :PREPRO_FLAGS => ""
          },
          :C => {
            :COMMAND => "",
            :DEFINE_FLAG => "",
            :OBJECT_FILE_FLAG => "",
            :INCLUDE_PATH_FLAG => "",
            :COMPILE_FLAGS => "",
            :DEFINES => [],
            :FLAGS => "",
            :SOURCE_FILE_ENDINGS => [".c"],
            :DEP_FLAGS => "",
            :DEP_FLAGS_SPACE => false,
            :DEP_FLAGS_FILENAME => true,
            :ERROR_PARSER => nil,
            :PREPRO_FLAGS => ""
          },
          :ASM => {
            :COMMAND => "",
            :DEFINE_FLAG => "",
            :OBJECT_FILE_FLAG => "",
            :INCLUDE_PATH_FLAG => "",
            :COMPILE_FLAGS => "",
            :DEFINES => [],
            :FLAGS => "",
            :SOURCE_FILE_ENDINGS => [".asm", ".s", ".S"],
            :DEP_FLAGS => "",
            :DEP_FLAGS_SPACE => false,
            :DEP_FLAGS_FILENAME => true,
            :ERROR_PARSER => nil,
            :PREPRO_FLAGS => ""
          }
        },

        :ARCHIVER =>
        {
          :COMMAND => "",
          :ARCHIVE_FLAGS => "",
          :FLAGS => "",
          :ERROR_PARSER => nil
        },

        :LINKER =>
        {
          :COMMAND => "",
          :MUST_FLAGS => "",
          :SCRIPT => "",
          :USER_LIB_FLAG => "",
          :EXE_FLAG => "",
          :LIB_FLAG => "",
          :LIB_PATH_FLAG => "",
          :LIB_PREFIX_FLAGS => "", # "-Wl,--whole-archive",
          :LIB_POSTFIX_FLAGS => "", # "-Wl,--no-whole-archive",
          :FLAGS => "",
          :MAP_FILE_FLAG => "",
          :MAP_FILE_PIPE => true,
          :OUTPUT_ENDING => ".exe", # or .elf
          :ERROR_PARSER => nil,
          :LIST_MODE => false
        },

        :MAKE =>
        {
          :COMMAND => "make",
          :FLAGS => "-j",
          :FILE_FLAG => "-f",
          :DIR_FLAG => "-C",
          :CLEAN => "clean"
        },
        
        :CONSOLE_HIGHLIGHTER => ColorizingFormatter.new,
        
        :LINT_POLICY => []
      }

      def self.add(name, basedOn = nil)
        chain = Marshal.load(Marshal.dump(basedOn.nil? ? @@default : @@settings[basedOn]))
        @@settings[name] = chain
        chain
      end

      def self.default
        @@default
      end

      def self.modify_cpp_compiler(based_on, h)
        chain = Marshal.load(Marshal.dump(@@settings[based_on]))
        chain[:COMPILER][:CPP].update(h)
        chain
      end

      def self.[](name)
      
        if name == "TI"
          if not ENV['TI_HOME']
            Printer.printError "Error: Please set TI_HOME"
            ExitHelper.exit(1)
          end
        end
      
        return @@settings[name] if @@settings.include? name
        nil
      end

      def self.list
        return @@settings.delete_if {|x| x.include?"_Lint" }
      end

    end

  end
end

require 'imported/toolchain/diab'
require 'imported/toolchain/gcc'
require 'imported/toolchain/gcc_lint'
require 'imported/toolchain/clang'
require 'imported/toolchain/ti'
require 'imported/toolchain/greenhills'
require 'imported/toolchain/keil'
