require_relative 'blockBase'

module Bake

  module Blocks

    class Library < BlockBase

      attr_reader :compileBlock, :archive_name

      def initialize(block, config, referencedConfigs, compileBlock)
        super(block,config, referencedConfigs)
        @compileBlock = compileBlock

        block.set_library(self)

        calcArtifactName
      end

      def calcArtifactName
        archiver = @block.tcs[:ARCHIVER]
        fileEnding = archiver[:ARCHIVE_FILE_ENDING]

        if not @config.artifactName.nil? and @config.artifactName.name != ""
          baseFilename = @config.artifactName.name
        else
          baseFilename = "lib#{@projectName}#{fileEnding}"
        end
        if !@config.artifactExtension.nil? && @config.artifactExtension.name != "default"
          extension = ".#{@config.artifactExtension.name}"
          if baseFilename.include?(".")
            baseFilename = baseFilename.split(".")[0...-1].join(".")
          end
          baseFilename += ".#{@config.artifactExtension.name}"
        end
        @archive_name ||= File.join([@block.output_dir, baseFilename])
        if Bake.options.abs_path_in
          @archive_name = File.expand_path(@archive_name, @projectDir)
        end
        return @archive_name
      end

      def calcCmdlineFile()
        File.expand_path(@archive_name + ".cmdline", @projectDir)
      end

      def ignore?
        Bake.options.linkOnly or Bake.options.prepro
      end

      def needed?
        Dir.mutex.synchronize do
          Dir.chdir(@projectDir) do
            # lib
            return "because library does not exist" if not File.exist?(@archive_name)

            aTime = File.mtime(@archive_name)

            # sources
            @objects.each do |obj|
              return "because object #{obj} does not exist" if not File.exist?(obj)
              return "because object #{obj} is newer than executable" if aTime < File.mtime(obj)
            end
          end
        end
        return false
      end

      def execute

        #Dir.chdir(@projectDir) do

          if !@block.prebuild
            @objects = @compileBlock.objects
            if @objects.empty?
              SyncOut.mutex.synchronize do
                puts "No source files, library won't be created" if Bake.options.verbose >= 2
              end
              return true
            end
          else

            @objects = []
            [:CPP, :C, :ASM].map do |t|
              @block.tcs[:COMPILER][t][:OBJECT_FILE_ENDING]
            end.uniq.each do |e|
              @objects.concat(Dir.glob_dir("#{@block.output_dir}/**/*#{e}", @projectDir))
            end
            if @objects.empty?
              if !File.exist?(File.expand_path(@archive_name, @projectDir))
                SyncOut.mutex.synchronize do
                  puts "No object files, library won't be created" if Bake.options.verbose >= 2
                end
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
          archiver = @block.tcs[:ARCHIVER]

          cmd = Utils.flagSplit(archiver[:PREFIX], true)
          cmd += Utils.flagSplit(archiver[:COMMAND], true) # ar
          onlyCmd = cmd
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
            SyncOut.startStream()

            begin
              success = true
              BlockBase.prepareOutput(File.expand_path(@archive_name, @projectDir), @block)
              BlockBase.writeCmdLineFile(cmd, cmdLineFile)
              consoleOutput = ""

              realCmd = Bake.options.fileCmd ? calcFileCmd(cmd, onlyCmd, @archive_name, archiver) : cmd
              printCmd(realCmd, "Creating  #{@projectName} (#{@config.name}): #{@archive_name}", reason, false)
              SyncOut.flushOutput()

              success, consoleOutput = ProcessHelper.run(realCmd, false, false, nil, [0], @projectDir) if !Bake.options.dry
              process_result(realCmd, consoleOutput, archiver[:ERROR_PARSER], nil, reason, success)

              check_config_file()
            ensure
              SyncOut.stopStream()
            end
          end

          return success
        #end
      end

      def clean
        if @block.prebuild
          Dir.chdir(@projectDir) do

            @objects = []
            [:CPP, :C, :ASM].map do |t|
              @block.tcs[:COMPILER][t][:OBJECT_FILE_ENDING]
            end.uniq.each do |e|
              @objects.concat(Dir.glob_dir("#{@block.output_dir}/**/*#{e}", @projectDir))
            end

            if !@objects.empty? && File.exist?(@archive_name)
              puts "Deleting file #{@archive_name}" if Bake.options.verbose >= 2
              if !Bake.options.dry
                FileUtils.rm_rf(@archive_name)
              end
            end
          end
          return true
        else
          return cleanProjectDir()
        end
      end

    end
  end
end