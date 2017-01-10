require 'blocks/blockBase'
require 'multithread/job'
require 'common/process'
require 'common/utils'
require 'bake/toolchain/colorizing_formatter'
require 'bake/config/loader'

module Bake

  module Blocks

    class Compile < BlockBase

      attr_reader :objects, :include_list

      def initialize(block, config, referencedConfigs)
        super(block, config, referencedConfigs)
        @objects = []
        @object_files = {}
        @system_includes = Set.new

        calcFileTcs
        calcIncludes
        calcDefines # not for files with changed tcs
        calcFlags   # not for files with changed tcs
      end

      def get_object_file(source)

        # until now all OBJECT_FILE_ENDING are equal in all three types
        adaptedSource = source.chomp(File.extname(source)).gsub(/\.\./, "##") + (Bake.options.prepro ? ".i" : @block.tcs[:COMPILER][:CPP][:OBJECT_FILE_ENDING])
        return adaptedSource if File.is_absolute?source
        File.join([@block.output_dir, adaptedSource])
      end

      def ignore?(type)
        Bake.options.linkOnly or (Bake.options.prepro and type == :ASM)
      end

      def needed?(source, object, type, dep_filename_conv)
        return "because analyzer toolchain is configured" if Bake.options.analyze
        return "because prepro was specified and source is no assembler file" if Bake.options.prepro

        return "because object does not exist" if not File.exist?(object)
        oTime = File.mtime(object)

        return "because source is newer than object" if oTime < File.mtime(source)

        if type != :ASM
          return "because dependency file does not exist" if not File.exist?(dep_filename_conv)

          begin
            File.readlines(dep_filename_conv).map{|line| line.strip}.each do |dep|
              Thread.current[:filelist].add(File.expand_path(dep)) if Bake.options.filelist

              if not File.exist?(dep)
                # we need a hack here. with some windows configurations the compiler prints unix paths
                # into the dep file which cannot be found easily. this will be true for system includes,
                # e.g. /usr/lib/...xy.h
                if (Bake::Utils::OS.windows? and dep.start_with?"/") or
                  (not Bake::Utils::OS.windows? and dep.length > 1 and dep[1] == ":")
                  puts "Dependency header file #{dep} ignored!" if Bake.options.debug
                else
                  return "because dependent header #{dep} does not exist"
                end
              else
                return "because dependent header #{dep} is newer than object" if oTime < File.mtime(dep)
              end
            end
          rescue Exception => ex
            if Bake.options.debug
              puts "While reading #{dep_filename_conv}:"
              puts ex.message
              puts ex.backtrace
            end
            return "because dependency file could not be loaded"
          end
        end

        false
      end

      def calcCmdlineFile(object)
        object[0..-3] + ".cmdline"
      end

      def calcDepFile(object, type)
        dep_filename = nil
        if type != :ASM
          dep_filename = object[0..-3] + ".d"
        end
        dep_filename
      end

      def calcDepFileConv(dep_filename)
        dep_filename + ".bake"
      end

      def get_source_type(source)
        ex = File.extname(source)
        [:CPP, :C, :ASM].each do |t|
          return t if @block.tcs[:COMPILER][t][:SOURCE_FILE_ENDINGS].include?(ex)
        end
        nil
      end

      def compileFile(source)
        type = get_source_type(source)
        return if type.nil?

        @headerFilesFromDep = []

        object = @object_files[source]

        dep_filename = calcDepFile(object, type)
        dep_filename_conv = calcDepFileConv(dep_filename) if type != :ASM

        cmdLineCheck = false
        cmdLineFile = calcCmdlineFile(object)

        return if ignore?(type)
        reason = needed?(source, object, type, dep_filename_conv)
        if not reason
          cmdLineCheck = true
          reason = config_changed?(cmdLineFile)
        end

        Thread.current[:filelist].add(File.expand_path(source)) if Bake.options.filelist

        if @fileTcs.include?(source)
          compiler = @fileTcs[source][:COMPILER][type]
          defines = getDefines(compiler)
          flags = getFlags(compiler)
        else
          compiler = @block.tcs[:COMPILER][type]
          defines = @define_array[type]
          flags = @flag_array[type]
        end
        includes = @include_array[type]

        if Bake.options.prepro and compiler[:PREPRO_FLAGS] == ""
          Bake.formatter.printError("Error: No preprocessor option available for " + source)
          raise SystemCommandFailed.new
        end

        cmd = Utils.flagSplit(compiler[:COMMAND], false)
        cmd += compiler[:COMPILE_FLAGS].split(" ")

        if dep_filename
          cmd += @block.tcs[:COMPILER][type][:DEP_FLAGS].split(" ")
          if @block.tcs[:COMPILER][type][:DEP_FLAGS_FILENAME]
            if @block.tcs[:COMPILER][type][:DEP_FLAGS_SPACE]
              cmd << dep_filename
            else
              if dep_filename.include?" "
                cmd[cmd.length-1] << "\"" + dep_filename + "\""
              else
                cmd[cmd.length-1] << dep_filename
              end

            end
          end
        end

        cmd += compiler[:PREPRO_FLAGS].split(" ") if Bake.options.prepro
        cmd += flags
        cmd += includes
        cmd += defines

        offlag = compiler[:OBJECT_FILE_FLAG]
        offlag = compiler[:PREPRO_FILE_FLAG] if compiler[:PREPRO_FILE_FLAG] and Bake.options.prepro

        if compiler[:OBJ_FLAG_SPACE]
          cmd << offlag
          cmd << object
        else
          if object.include?" "
            cmd << offlag + "\"" + object + "\""
          else
            cmd << offlag + object
          end
        end
        cmd << source

        if Bake.options.cc2j_filename
          cmdJson = cmd.is_a?(Array) ? cmd.join(' ') : cmd
          Blocks::CC2J << { :directory => @projectDir, :command => cmdJson, :file => source }
        end

        if not (cmdLineCheck and BlockBase.isCmdLineEqual?(cmd, cmdLineFile))
          BlockBase.prepareOutput(object)
          BlockBase.writeCmdLineFile(cmd, cmdLineFile)
          success, consoleOutput = ProcessHelper.run(cmd, false, false)

          outputType = Bake.options.analyze ? "Analyzing" : (Bake.options.prepro ? "Preprocessing" : "Compiling")
          incList = process_result(cmd, consoleOutput, compiler[:ERROR_PARSER], "#{outputType} #{source}", reason, success)

          if type != :ASM and not Bake.options.analyze and not Bake.options.prepro
            incList = Compile.read_depfile(dep_filename, @projectDir, @block.tcs[:COMPILER][:DEP_FILE_SINGLE_LINE]) if incList.nil?
            Compile.write_depfile(incList, dep_filename_conv)

            incList.each do |h|
              Thread.current[:filelist].add(File.expand_path(h))
            end if Bake.options.filelist
          end
          check_config_file
        end



      end

      def self.read_depfile(dep_filename, projDir, singleLine)
        deps = []
        begin
          if singleLine
            File.readlines(dep_filename).each do |line|
              splitted = line.split(": ")
              deps << splitted[1].gsub(/[\\]/,'/') if splitted.length > 1
            end
          else
            deps_string = File.read(dep_filename)
            deps_string = deps_string.gsub(/\\\n/,'')
            dep_splitted = deps_string.split(/([^\\]) /).each_slice(2).map(&:join)[2..-1]
            deps = dep_splitted.map { |d| d.gsub(/[\\] /,' ').gsub(/[\\]/,'/').strip }.delete_if {|d| d == "" }
          end
        rescue Exception => ex1
          Bake.formatter.printWarning("Could not read '#{dep_filename}'", projDir)
          puts ex1.message if Bake.options.debug
          return nil
        end
        deps
      end

      # todo: move to toolchain util file
      def self.write_depfile(deps, dep_filename_conv)
        if deps
          begin
            File.open(dep_filename_conv, 'wb') do |f|
              deps.each do |dep|
                f.puts(dep)
              end
            end
          rescue Exception
            Bake.formatter.printWarning("Could not write '#{dep_filename_conv}'", projDir)
            return nil
          end
        end
      end

      def mutex
        @mutex ||= Mutex.new
      end

      def execute
        Dir.chdir(@projectDir) do

          calcSources
          calcObjects

          @error_strings = {}

          fileListBlock = Set.new if Bake.options.filelist
          compileJobs = Multithread::Jobs.new(@source_files) do |jobs|
            while source = jobs.get_next_or_nil do

              if (jobs.failed and Bake.options.stopOnFirstError) or Bake::IDEInterface.instance.get_abort
                break
              end

              s = StringIO.new
              tmp = Thread.current[:stdout]
              Thread.current[:stdout] = s unless tmp

              Thread.current[:filelist] = Set.new if Bake.options.filelist

              result = false
              begin
                compileFile(source)
                result = true
              rescue Bake::SystemCommandFailed => scf # normal compilation error
              rescue SystemExit => exSys
              rescue Exception => ex1
                if not Bake::IDEInterface.instance.get_abort
                  Bake.formatter.printError("Error: #{ex1.message}")
                  puts ex1.backtrace if Bake.options.debug
                end
              end

              jobs.set_failed if not result

              Thread.current[:stdout] = tmp

              mutex.synchronize do
                fileListBlock.merge(Thread.current[:filelist]) if Bake.options.filelist

                if s.string.length > 0
                  if Bake.options.stopOnFirstError and not result
                    @error_strings[source] = s.string
                  else
                    puts s.string
                  end
                end
              end

            end
          end
          compileJobs.join

          if Bake.options.filelist
            Bake.options.filelist.merge(fileListBlock.merge(fileListBlock))

            if Bake.options.json
              require "json"
              File.open(@block.output_dir + "/" + "file-list.json", 'wb') do |f|
                f.puts JSON.pretty_generate({:files=>fileListBlock.sort})
              end
            else
              File.open(@block.output_dir + "/" + "file-list.txt", 'wb') do |f|
                fileListBlock.sort.each do |entry|
                  f.puts(entry)
                end
              end
            end
          end


          # can only happen in case of bail_on_first_error.
          # if not sorted, it may be confusing when builing more than once and the order of the error appearances changes from build to build
          # (it is not deterministic which file compilation finishes first)
          @error_strings.sort.each {|es| puts es[1]}

          raise SystemCommandFailed.new if compileJobs.failed


        end
        return true
      end

      def clean
        if Bake.options.filename or Bake.options.analyze
          Dir.chdir(@projectDir) do
            calcSources(true)
            @source_files.each do |source|

              type = get_source_type(source)
              next if type.nil?
              object = get_object_file(source)
              if File.exist?object
                puts "Deleting file #{object}" if Bake.options.verbose >= 2
                FileUtils.rm_rf(object)
              end
              if not Bake.options.analyze
                dep_filename = calcDepFile(object, type)
                if dep_filename and File.exist?dep_filename
                  puts "Deleting file #{dep_filename}" if Bake.options.verbose >= 2
                  FileUtils.rm_rf(dep_filename)
                end
                cmdLineFile = calcCmdlineFile(object)
                if File.exist?cmdLineFile
                  puts "Deleting file #{cmdLineFile}" if Bake.options.verbose >= 2
                  FileUtils.rm_rf(cmdLineFile)
                end
              end
            end
          end
        end
        return true
      end

      def calcObjects
        @source_files.each do |source|
          type = get_source_type(source)
          if not type.nil?
            object = get_object_file(source)
            if @objects.include?object
              @object_files.each do |k,v|
                if (v == object) # will be found exactly once
                  Bake.formatter.printError("Source files '#{k}' and '#{source}' would result in the same object file", source)
                  raise SystemCommandFailed.new
                end
              end
            end
            @object_files[source] = object
            @objects << object
          end
        end
      end

      def calcSources(cleaning = false, keep = false)
        return @source_files if @source_files and not @source_files.empty?
        Dir.chdir(@projectDir) do
          @source_files = []

          exclude_files = Set.new
          @config.excludeFiles.each do |p|
            Dir.glob(p.name).each {|f| exclude_files << f}
          end

          source_files = Set.new
          @config.files.each do |sources|
            p = sources.name
            res = Dir.glob(p).sort
            if res.length == 0 and cleaning == false
              if not p.include?"*" and not p.include?"?"
                Bake.formatter.printError("Source file '#{p}' not found", sources)
                raise SystemCommandFailed.new
              elsif Bake.options.verbose >= 1
                Bake.formatter.printInfo("Source file pattern '#{p}' does not match to any file", sources)
              end
            end
            res.each do |f|
              next if exclude_files.include?(f)
              next if source_files.include?(f)
              source_files << f
              @source_files << f
            end
          end

          if Bake.options.filename
            @source_files.keep_if do |source|
              source.include?Bake.options.filename
            end
            if @source_files.length == 0 and cleaning == false
              Bake.formatter.printInfo("#{Bake.options.filename} does not match to any source", @config)
            end
          end

          if Bake.options.eclipseOrder # directories reverse order, files in directories in alphabetical order
            dirs = []
            filemap = {}
            @source_files.sort.reverse.each do |o|
              d = File.dirname(o)
              if filemap.include?(d)
                filemap[d] << o
              else
                filemap[d] = [o]
                dirs << d
              end
            end
            @source_files = []
            dirs.each do |d|
              filemap[d].reverse.each do |f|
                @source_files << f
              end
            end
          end
        end
        @source_files
      end

      def mapInclude(inc, orgBlock)

        if inc.name == "___ROOTS___"
          return Bake.options.roots.map { |r| File.rel_from_to_project(@projectDir,r,false) }
        end

        i = orgBlock.convPath(inc,nil,true)
        if orgBlock != @block
          if not File.is_absolute?(i)
            i = File.rel_from_to_project(@projectDir,orgBlock.config.parent.get_project_dir) + i
          end
        end

        Pathname.new(i).cleanpath
      end

      def calcIncludesInternal(block)
        @blocksRead << block
        block.config.baseElement.each do |be|
          if Metamodel::IncludeDir === be
            if be.inherit == true || block == @block
              mappedInc = mapInclude(be, block)
              @include_list << mappedInc
              @system_includes << mappedInc if be.system
            end
          elsif Metamodel::Dependency === be
            childBlock = block.depToBlock[be.name + "," + be.config]
            calcIncludesInternal(childBlock) if !@blocksRead.include?(childBlock)
          end
        end
      end

      def calcIncludes

        @blocksRead = Set.new
        @include_list = []
        @system_includes = Set.new
        calcIncludesInternal(@block) # includeDir and child dependencies with inherit: true

        @block.getBlocks(:parents).each do |b|
          if b.config.respond_to?("includeDir")
            include_list_front = []
            b.config.includeDir.each do |inc|
              if inc.inject == "front" || inc.infix == "front"
                mappedInc = mapInclude(inc, b)
                include_list_front << mappedInc
                @system_includes << mappedInc if inc.system
              elsif inc.inject == "back" || inc.infix == "back"
                mappedInc = mapInclude(inc, b)
                @include_list << mappedInc
                @system_includes << mappedInc if inc.system
              end
            end
            @include_list = include_list_front + @include_list
          end
        end

        @include_list = @include_list.flatten.uniq

        @include_array = {}
        [:CPP, :C, :ASM].each do |type|
          @include_array[type] = @include_list.map do |k|
            if @system_includes.include?(k)
              "#{@block.tcs[:COMPILER][type][:SYSTEM_INCLUDE_PATH_FLAG]}#{k}"
            else
              "#{@block.tcs[:COMPILER][type][:INCLUDE_PATH_FLAG]}#{k}"
            end
          end
        end
      end

      def getDefines(compiler)
        compiler[:DEFINES].map {|k| "#{compiler[:DEFINE_FLAG]}#{k}"}
      end

      def getFlags(compiler)
        Bake::Utils::flagSplit(compiler[:FLAGS],true)
      end

      def calcDefines
        @define_array = {}
        [:CPP, :C, :ASM].each do |type|
          @define_array[type] = getDefines(@block.tcs[:COMPILER][type])
        end
      end
      def calcFlags
        @flag_array = {}
        [:CPP, :C, :ASM].each do |type|
          @flag_array[type] = getFlags(@block.tcs[:COMPILER][type])
        end
      end

      def calcFileTcs
        @fileTcs = {}
        @config.files.each do |f|
          if (f.define.length > 0 or f.flags.length > 0)
            if f.name.include?"*"
              Bake.formatter.printWarning("Toolchain settings not allowed for file pattern #{f.name}", f)
              err_res = ErrorDesc.new
              err_res.file_name = @config.file_name
              err_res.line_number = f.line_number
              err_res.severity = ErrorParser::SEVERITY_WARNING
              err_res.message = "Toolchain settings not allowed for file patterns"
              Bake::IDEInterface.instance.set_errors([err_res])
            else
              @fileTcs[f.name] = integrateCompilerFile(Utils.deep_copy(@block.tcs),f)
            end
          end
        end
      end

      def tcs4source(source)
        @fileTcs[source] || @block.tcs
      end


    end

  end
end