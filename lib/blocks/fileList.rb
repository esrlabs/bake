require 'blocks/compile'

module Bake

  module Blocks

    class FileList < Compile

      def initialize(block, config, referencedConfigs, tcs)
        super(block, config, referencedConfigs, tcs)
      end

      def execute
        Dir.chdir(@projectDir) do
          calcSources
          calcObjects

          projDir = File.expand_path(@projectDir)
          headers = Set.new
          @source_files.sort.each do |s|
            puts "FILE: " + projDir+"/"+s
            type = get_source_type(s)
            if type.nil?
              Bake.formatter.printError("Error: could not get type of source file #{s}")
              ExitHelper.exit(1)
            end
            object = @object_files[s]
            dep_filename = calcDepFile(object, type)
            if type != :ASM
              dep_filename_conv = calcDepFileConv(dep_filename)
              if not File.exist?(dep_filename_conv)
                Bake.formatter.printError("Error: dependency file doesn't exist for #{s}")
                ExitHelper.exit(1)
              end
              File.readlines(dep_filename_conv).map {|line| headers << line.strip}
            end
          end
          headers.map do |h|
            habs = File.is_absolute?(h) ? h : projDir+"/"+h
            File.expand_path(h)
          end.sort.each { |h| puts "HEADER: " + h }
        end
        return true
      end

      def clean
        # nothing to do here
      end

    end

  end
end