require 'blocks/blockBase'

module Bake

  module Blocks

    class Library < BlockBase

      attr_reader :compileBlock, :archive_name

      def initialize(block, config, referencedConfigs, tcs, compileBlock)
        super(block,config, referencedConfigs, tcs)
        @compileBlock = compileBlock

        block.set_library(self)

        calcArtifactName
      end

      def calcArtifactName
        if not @config.artifactName.nil? and @config.artifactName.name != ""
          baseFilename = @config.artifactName.name
        else
          baseFilename = "lib#{@projectName}.a"
        end
        @archive_name ||= File.join([@output_dir, baseFilename])
      end

      def calcCmdlineFile()
        @archive_name + ".cmdline"
      end

      def ignore?
        Bake.options.linkOnly or Bake.options.prepro
      end

      def needed?
        # lib
        return "because library does not exist" if not File.exists?(@archive_name)

        aTime = File.mtime(@archive_name)

        # sources
        @objects.each do |obj|
          return "because object #{obj} does not exist" if not File.exists?(obj)
          return "because object #{obj} is newer than executable" if aTime < File.mtime(obj)
        end

        false
      end

      def execute

        Dir.chdir(@projectDir) do

          @objects = @compileBlock.objects
          if !@block.prebuild
            if @objects.empty?
              puts "No source files, library won't be created" if Bake.options.verbose >= 2
              return true
            end
          else
            @objects = Dir.glob("#{@output_dir}/**/*.o")
            if @objects.empty?
              if !File.exists?(@archive_name)
                puts "No object files, library won't be created" if Bake.options.verbose >= 2
              end
              return true
            end
          end

          cmdLineCheck = false
          cmdLineFile = calcCmdlineFile()

          return true if ignore?
          reason = needed?
          if not reason
            cmdLineCheck = true
            reason = config_changed?(cmdLineFile)
          end
          archiver = @tcs[:ARCHIVER]

          cmd = Utils.flagSplit(archiver[:COMMAND], false) # ar
          cmd += Bake::Utils::flagSplit(archiver[:FLAGS],true) # --all_load
          cmd += archiver[:ARCHIVE_FLAGS].split(" ")

          if archiver[:ARCHIVE_FLAGS_SPACE]
            cmd << @archive_name
          else
            cmd[cmd.length-1] += @archive_name
          end

          cmd += @objects

          if cmdLineCheck and BlockBase.isCmdLineEqual?(cmd, cmdLineFile)
            success = true
          else
            BlockBase.prepareOutput(@archive_name)

            BlockBase.writeCmdLineFile(cmd, cmdLineFile)
            success, consoleOutput = ProcessHelper.run(cmd, false, false)
            process_result(cmd, consoleOutput, archiver[:ERROR_PARSER], "Creating #{@archive_name}", reason, success)

            check_config_file()
          end

          return success
        end
      end

      def clean
        if @block.prebuild
          Dir.chdir(@projectDir) do
            @objects = Dir.glob("#{@output_dir}/**/*.o")
            if !@objects.empty? && File.exist?(@archive_name)
              puts "Deleting file #{@archive_name}" if Bake.options.verbose >= 2
              FileUtils.rm_rf(@archive_name)
            end
          end
        else
          return cleanProjectDir()
        end
      end

    end
  end
end