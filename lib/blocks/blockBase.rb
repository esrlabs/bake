module Bake
  module Blocks

    class BlockBase

      attr_reader :projectDir, :block

      def initialize(block, config, referencedConfigs)
        @block = block
        @config = config
        @referencedConfigs = referencedConfigs
        @projectName = config.parent.name
        @projectDir = config.get_project_dir
        @config_date = Time.now
      end

      def check_config_file()
        if File.exists?(@config.file_name) and File.mtime(@config.file_name) > @config_date
          begin
            FileUtils.touch(@config.file_name) if !Bake.options.dry
          rescue Exception=>e
            if Bake.options.verbose >= 2
              Bake.formatter.printWarning("Could not touch #{@config.file_name}: #{e.message}", @config.file_name)
            end
          end
        end
      end

      def self.prepareOutput(filename, block = nil)
        return if Bake.options.dry
        filename = File.expand_path(filename, @projectDir)
        begin
          if File.exists?(filename)
            FileUtils.rm(filename)
          else
            FileUtils::mkdir_p(File.dirname(filename))
          end
          Utils.gitIgnore(File.expand_path(block.output_dir, @projectDir)) if block
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
              FileUtils.touch(cmdLineFile) if !Bake.options.dry
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
          if !Bake.options.dry
            File.open(cmdLineFile, 'w') { |f| f.write(cmd.join(" ")) }
          end
        rescue Exception => e
          if Bake.options.debug
            puts e.message
            puts e.backtrace
          end
        end
      end

      def printCmd(cmd, alternate, reason, forceVerbose)
        if (cmd == Thread.current[:lastCommand])
          if (Bake.options.verbose >= 2 or (Thread.current[:printedCmdAlternate] and not forceVerbose))
            return
          end
        end

        Thread.current[:lastCommand] = cmd

        return if Bake.options.verbose == 0 and not forceVerbose

        if forceVerbose or Bake.options.verbose >= 2 or not alternate
          Thread.current[:printedCmdAlternate] = false
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
          Thread.current[:printedCmdAlternate] = true
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
              if metadata_json = Bake.options.dev_features.include?("no-error-parser")
                error_descs = []
                console_output_full = x[0]
              else
                error_descs, console_output_full, incList = error_parser.scan_lines(x, @projectDir)
              end

              console_output = x[0]
              console_output = console_output_full if Bake.options.consoleOutput_fullnames

              ret = error_descs.any? { |e| e.severity == ErrorParser::SEVERITY_ERROR }

              console_output.gsub!(/[\r]/, "")
              if metadata_json = Bake.options.dev_features.include?("no-error-parser")
                puts console_output
              else
                Bake.formatter.format(console_output, error_descs, error_parser) unless console_output.empty?
                Bake::IDEInterface.instance.set_errors(error_descs)
              end

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
        printCmd(cmd, alternate, reason, hasError)
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
        if !Bake.options.filename
          Dir.chdir(@projectDir) do
            if File.exist?@block.output_dir
              puts "Deleting folder #{@block.output_dir}" if Bake.options.verbose >= 2
              if !Bake.options.dry
                FileUtils.rm_rf(@block.output_dir)
              end

              if (@block.tcs[:OUTPUT_DIR] == nil) && (Bake.options.buildDirDelimiter == "/") # in this case all builds are placed in a "build" folder
                buildDir = File.dirname(@block.output_dir)
                if (File.basename(buildDir) == "build") && (Dir.entries(buildDir).size == 2)# double check if it's really "build" and check if it's empty (except "." and "..")
                  puts "Deleting folder #{buildDir}" if Bake.options.verbose >= 2
                  if !Bake.options.dry
                    FileUtils.rm_rf(buildDir)
                  end
                end
              end

            end
          end
        end
        return true
      end
      
      def calcFileCmd(cmd, onlyCmd, orgOut, tcs, postfix = "")
        if tcs[:FILE_COMMAND] == ""
          Bake.formatter.printWarning("Warning: file command option not yet supported for this toolchain")
          return cmd
        end
        args = cmd.drop(onlyCmd.length)
        argsFlat = args.join(' ')

        splittedArgs = argsFlat.split("\"")
        argsFlat = ""
        splittedArgs.each_with_index do |s,i|
          argsFlat << s
          argsFlat << (i%2 == 0 ? "\"\\\"" : "\\\"\"") if i != splittedArgs.length - 1 
        end

        cmdFile = orgOut + ".file" + postfix
        cmdFileLong = File.expand_path(cmdFile, @projectDir)
        Utils.gitIgnore(File.dirname(cmdFileLong))
        File.open(cmdFileLong, "w") { |f| f.puts argsFlat }
        return onlyCmd + ["#{tcs[:FILE_COMMAND]}#{cmdFile}"]
      end

    end
  end
end
