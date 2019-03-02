require_relative 'compile'

module Bake

  module Blocks

    class Convert < Compile

      def initialize(block, config, referencedConfigs)
        super(block, config, referencedConfigs)
      end

      def execute
        Dir.chdir(@projectDir) do
          calcSources

          puts "START_INFO"
          puts " BAKE_PROJECTDIR"
          puts "  #{File.expand_path(@projectDir)}"
          puts " BAKE_SOURCES"
          @source_files.each { |s| puts "  #{s}" }
          puts " BAKE_INCLUDES"
          @include_list.each { |s| puts "  #{s}" }
          puts " BAKE_DEFINES"
          (@block.tcs[:COMPILER][:CPP][:DEFINES] + @block.tcs[:COMPILER][:C][:DEFINES] + @block.tcs[:COMPILER][:ASM][:DEFINES]).uniq.each { |s| puts "  #{s}" }
          puts " BAKE_DEPENDENCIES"
          @block.dependencies.each { |dep| puts "  #{dep.projectName}" }
          puts " BAKE_DEPENDENCIES_FILTERED"
          @block.dependencies.each { |dep| puts "  #{dep.projectName}" unless @projectName == dep.projectName or dep.projectName == "gmock" or dep.projectName == "gtest" }
          puts "END_INFO"
        end
        return true
      end

      def clean
        # nothing to do here
      end

    end

  end
end