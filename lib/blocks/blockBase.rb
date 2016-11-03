require 'bake/bundle'

module Bake
  module Blocks

    class BlockBase

      attr_reader :tcs
      attr_reader :projectDir

      def initialize(block, config, referencedConfigs, tcs)
        @block = block
        @config = config
        @referencedConfigs = referencedConfigs
        @projectName = config.parent.name
        @projectDir = config.get_project_dir
        @tcs = tcs
        @config_date = Time.now

        @printedCmdAlternate = false
        @lastCommand = nil

        calcOutputDir
      end

      def check_config_file()
        if File.exists?(@config.file_name) and File.mtime(@config.file_name) > @config_date
          begin
            FileUtils.touch(@config.file_name)
          rescue Exception=>e
            if Bake.options.verbose >= 2
              Bake.formatter.printWarning("Could not touch #{@config.file_name}: #{e.message}", @config.file_name)
            end
          end
        end
      end

      def self.prepareOutput(filename)
        begin
          if File.exists?(filename)
            FileUtils.rm(filename)
          else
            FileUtils.mkdir_p(File.dirname(filename))
          end
        rescue Exception => e
          if Bake.options.debug
            puts e.message
            puts e.backtrace
          end
        end
      end

      def defaultToolchainTime
        @defaultToolchainTime ||= File.mtime(Bake.options.main_dir+"/Project.meta")
      end

      def config_changed?(cmdLineFile)
        return "because command line file does not exist" if not File.exist?(cmdLineFile)
        cmdTime = File.mtime(cmdLineFile)
        return "because config file has been changed" if cmdTime < File.mtime(@config.file_name)
        return "because DefaultToolchain has been changed" if cmdTime < defaultToolchainTime
        return "because command line has been changed"
      end

      def self.isCmdLineEqual?(cmd, cmdLineFile)
        begin
          if File.exist?cmdLineFile
            lastCmdLineArray = File.readlines(cmdLineFile)[0];
            if lastCmdLineArray == cmd.join(" ")
              FileUtils.touch(cmdLineFile)
              return true
            end
          end
        rescue Exception => e
          if Bake.options.debug
            puts e.message
            puts e.backtrace
          end
        end
        return false
      end

      def self.writeCmdLineFile(cmd, cmdLineFile)
        begin
          File.open(cmdLineFile, 'w') { |f| f.write(cmd.join(" ")) }
        rescue Exception => e
          if Bake.options.debug
            puts e.message
            puts e.backtrace
          end
        end
      end

      def isMainProject?
        @projectName == Bake.options.main_project_name and @config.name == Bake.options.build_config
      end

      def calcOutputDir
        if @tcs[:OUTPUT_DIR] != nil
          p = @block.convPath(@tcs[:OUTPUT_DIR])
          @output_dir = p
        else
          qacPart = Bake.options.qac ? (".qac" + Bake.options.buildDirDelimiter) : ""
          if isMainProject?
            @output_dir = "build" + Bake.options.buildDirDelimiter + qacPart + Bake.options.build_config
          else
            @output_dir = "build" + Bake.options.buildDirDelimiter + qacPart + @config.name + "_" + Bake.options.main_project_name + "_" + Bake.options.build_config
          end
        end
      end

      def printCmd(cmd, alternate, reason, forceVerbose)
        if (cmd == @lastCommand)
          if (Bake.options.verbose >= 2 or (@printedCmdAlternate and not forceVerbose))
            return
          end
        end

        @lastCommand = cmd

        return if Bake.options.verbose == 0 and not forceVerbose

        if forceVerbose or Bake.options.verbose >= 2 or not alternate
          @printedCmdAlternate = false
          puts "" if Bake.options.verbose >= 2 # for A.K. :-)
          if Bake.options.verbose >= 3
            exedIn = "\n(executed in '#{@projectDir}')"
            because = reason ? "\n(#{reason})" : ""
          else
            exedIn = ""
            because = ""
          end

          if cmd.is_a?(Array)
            puts cmd.join(' ') + exedIn + because
          else
            puts cmd + exedIn + because
          end
        else
          @printedCmdAlternate = true
          puts alternate
        end

      end

      def process_console_output(console_output, error_parser)
        ret = false
        incList = nil
        #if not console_output.empty?
          if error_parser
            begin
              x = [console_output]
              error_descs, console_output_full, incList = error_parser.scan_lines(x, @projectDir)

              console_output = x[0]
              console_output = console_output_full if Bake.options.consoleOutput_fullnames

              if Bake.options.consoleOutput_visualStudio
                console_output_VS = ""
                descCounter = 0
                console_output.each_line do |l|
                  d = error_descs[descCounter]
                  console_output_VS << error_parser.makeVsError(l.rstrip, d) << "\n"
                  descCounter = descCounter + 1
                end
                console_output = console_output_VS
              end

              if Bake.options.lint
                # ignore error output
              else
                ret = error_descs.any? { |e| e.severity == ErrorParser::SEVERITY_ERROR }
              end

              console_output.gsub!(/[\r]/, "")
              Bake.formatter.format(console_output, error_descs, error_parser) unless console_output.empty?

              Bake::IDEInterface.instance.set_errors(error_descs)
            rescue Exception => e
              Bake.formatter.printWarning("Parsing output failed (maybe language not set to English?): " + e.message)
              Bake.formatter.printWarning("Original output:")
              Bake.formatter.printWarning(console_output)
              raise e
            end
          else
            puts console_output # fallback
          end
        #end
        [ret, incList]
      end

      def process_result(cmd, console_output, error_parser, alternate, reason, success)
        hasError = (success == false)
        printCmd(cmd, alternate, reason, (hasError and not Bake.options.lint))
        errorPrinted, incList = process_console_output(console_output, error_parser)
        if hasError and not errorPrinted
          Bake.formatter.printError("System command failed", @projectDir)
        end
        if hasError or (Bake.options.wparse and errorPrinted)
          raise SystemCommandFailed.new
        end
        incList
      end


      def cleanProjectDir
        Dir.chdir(@projectDir) do
          if File.exist?@output_dir
            puts "Deleting folder #{@output_dir}" if Bake.options.verbose >= 2
            FileUtils.rm_rf(@output_dir)

            if (@tcs[:OUTPUT_DIR] == nil) && (Bake.options.buildDirDelimiter == "/") # in this case all builds are placed in a "build" folder
              buildDir = File.dirname(@output_dir)
              if (File.basename(buildDir) == "build") && (Dir.entries(buildDir).size == 2)# double check if it's really "build" and check if it's empty (except "." and "..")
                puts "Deleting folder #{@buildDir}" if Bake.options.verbose >= 2
                FileUtils.rm_rf(buildDir)
              end
            end

          end
        end unless Bake.options.filename
        return true
      end

    end
  end
end
