require 'blocks/blockBase'

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
        if not @config.artifactName.nil? and @config.artifactName.name != ""
          baseFilename = @config.artifactName.name
        else
          baseFilename = "lib#{@projectName}.a"
        end
        @archive_name ||= File.join([@block.output_dir, baseFilename])
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
            return "because library does not exist" if not File.exists?(@archive_name)

            aTime = File.mtime(@archive_name)

            # sources
            @objects.each do |obj|
              return "because object #{obj} does not exist" if not File.exists?(obj)
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
              if !File.exists?(File.expand_path(@archive_name, @projectDir))
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
              BlockBase.prepareOutput(File.expand_path(@archive_name, @projectDir))
              BlockBase.writeCmdLineFile(cmd, cmdLineFile)
              consoleOutput = ""

              printCmd(cmd, "Creating  #{@projectName} (#{@config.name}): #{@archive_name}", reason, false)
              SyncOut.flushOutput()

              success, consoleOutput = ProcessHelper.run(cmd, false, false, nil, [0], @projectDir) if !Bake.options.dry
              process_result(cmd, consoleOutput, archiver[:ERROR_PARSER], nil, reason, success)

              check_config_file()
            ensure
              SyncOut.stopStream(success)
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
        else
          return cleanProjectDir()
        end
      end

    end
  end
end