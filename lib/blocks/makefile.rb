require_relative 'has_execute_command'

module Bake
  module Blocks

    class Makefile
      include HasExecuteCommand

      MAKE_COMMAND = "make"
      MAKE_FILE_FLAG = "-f"
      MAKE_DIR_FLAG = "-C"
      MAKE_CLEAN = "clean"

      def initialize(config, referencedConfigs, block)
        @config = config
        @tcs = block.tcs
        @projectDir = config.get_project_dir
        @path_to = ""
        @flags = adjustFlags("",config.flags) if config.flags
        @makefile = block.convPath(config.name)
        @target = config.target != "" ? config.target : "all"
        calcPathTo(referencedConfigs)
        calcCommandLine
        calcCleanLine
        calcEnv

        if config.lib != ""
          block.lib_elements << LibElement.new(LibElement::LIB_WITH_PATH, block.convPath(config.lib))
        end 
      end

      def calcEnv
        @envs = {}
        [:CPP, :C, :ASM].each do |type|
          compiler = @tcs[:COMPILER][type]
          defs = compiler[:DEFINES].map {|k| "#{compiler[:DEFINE_FLAG]}#{k}"}.join(" ")
          args = [defs, compiler[:FLAGS]].reject(&:empty?).join(" ")
          @envs["BAKE_#{type.to_s}_FLAGS"] = args
          @envs["BAKE_#{type.to_s}_COMMAND"] = compiler[:COMMAND]
        end
        @envs["BAKE_AR_FLAGS"] = @tcs[:ARCHIVER][:FLAGS]
        @envs["BAKE_LD_FLAGS"] = @tcs[:LINKER][:FLAGS]
        @envs["BAKE_AR_COMMAND"] = @tcs[:ARCHIVER][:COMMAND]
        @envs["BAKE_LD_COMMAND"] = @tcs[:LINKER][:COMMAND]
      end

      def fileAndDir
        if @config.changeWorkingDir
          return remove_empty_strings_and_join([
            MAKE_DIR_FLAG,  File.dirname(@makefile),
            MAKE_FILE_FLAG, File.basename(@makefile)])
        else
          return remove_empty_strings_and_join([
            MAKE_FILE_FLAG, @makefile])
        end
      end

      def calcCommandLine
        @commandLine = remove_empty_strings_and_join([
          MAKE_COMMAND, @target,
          @flags,
          fileAndDir,
          @path_to])
      end

      def calcCleanLine
        @cleanLine = remove_empty_strings_and_join([
          MAKE_COMMAND, MAKE_CLEAN,
          @flags,
          fileAndDir,
          @path_to])
      end

      def calcPathTo(referencedConfigs)
        @path_to = ""
        if @config.pathTo != ""
          pathHash = {}
          @config.pathTo.split(",").each do |p|
            nameOfP = p.strip
            dirOfP = nil
            if referencedConfigs.include?nameOfP
              dirOfP = referencedConfigs[nameOfP].first.get_project_dir
            else
              Bake.options.roots.each do |r|
                absIncDir = r.dir+"/"+nameOfP
                if File.exists?(absIncDir)
                  dirOfP = absIncDir
                  break
                end
              end
            end
            if dirOfP == nil
              Bake.formatter.printError("Project '#{nameOfP}' not found", @config)
              ExitHelper.exit(1)
            end
            pathHash[nameOfP] = File.rel_from_to_project(File.dirname(@projectDir),File.dirname(dirOfP))
          end
          path_to_array = []
          pathHash.each { |k,v| path_to_array << "PATH_TO_#{k}=#{v}" }
          @path_to = path_to_array.join(" ")
        end

      end

      def run
        return true if Bake.options.linkOnly
        @envs.each { |k,v| ENV[k] = v }
        return executeCommand(@commandLine, nil, @config.validExitCodes, @config.echo)
      end

      def execute
        return run()
       end

      def startupStep
        return run()
      end

      def exitStep
        return run()
      end

      def do_clean
        return true if Bake.options.linkOnly || @config.noClean
        @envs.each { |k,v| ENV[k] = v }
        return executeCommand(@cleanLine, "No rule to make target 'clean'.", @config.validExitCodes, @config.echo) unless Bake.options.filename
      end

      def clean
        return do_clean()
      end

      def cleanStep
        return do_clean()
      end

    end

  end
end
