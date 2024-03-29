require_relative 'blockBase'

require_relative '../multithread/job'
require_relative '../common/process'
require_relative '../common/ext/dir'
require_relative '../common/utils'
require_relative '../bake/toolchain/colorizing_formatter'
require_relative '../bake/config/loader'

begin
  module Kernel32
    require 'fiddle'
    require 'fiddle/import'
    require 'fiddle/types'
    extend Fiddle::Importer
    dlload 'kernel32'
    include Fiddle::Win32Types
    extern 'DWORD GetLongPathName(LPCSTR, LPSTR, DWORD)'
    extern 'DWORD GetShortPathName(LPCSTR, LPSTR, DWORD)'
  end

  def longname short_name
    max_path = 1024
    long_name = " " * max_path
    lfn_size = Kernel32.GetLongPathName(short_name, long_name, max_path)
    return long_name[0..lfn_size-1]
  end

  def shortname long_name
    max_path = 1024
    short_name = " " * max_path
    lfn_size = Kernel32.GetShortPathName(long_name, short_name, max_path)
    return short_name[0..lfn_size-1]
  end

  def realname file
    x = longname(shortname(file))
  end

rescue Exception

  def realname file
    file
  end

end


module Bake

  module Blocks

    class Compile < BlockBase

      attr_reader :objects, :source_files, :source_files_compiled, :include_list, :source_files_ignored_in_lib, :object_files_ignored_in_lib, :object_files

      def mutex
        @mutex ||= Mutex.new
      end

      def initialize(block, config, referencedConfigs)
        super(block, config, referencedConfigs)
        @objects = []
        @object_files = {}
        @system_includes = Set.new


      end

      def get_object_file(source)
        # until now all OBJECT_FILE_ENDING are equal in all three types

        sourceEndingAdapted = @block.tcs[:KEEP_FILE_ENDINGS] ? source : source.chomp(File.extname(source))
        srcWithoutDotDot = sourceEndingAdapted.gsub(/\.\./, "__")
        if srcWithoutDotDot[0] == '/'
          srcWithoutDotDot = "_" + srcWithoutDotDot
        elsif srcWithoutDotDot[1] == ':'
          srcWithoutDotDot = "_" + srcWithoutDotDot[0] + "_" + srcWithoutDotDot[2..-1]
        end

        adaptedSource = srcWithoutDotDot + (Bake.options.prepro ? ".i" : @block.tcs[:COMPILER][:CPP][:OBJECT_FILE_ENDING])

        File.join([@block.output_dir, adaptedSource])
      end

      def ignore?(type)
        Bake.options.linkOnly or (Bake.options.prepro and type == :ASM)
      end

      def needed?(source, object, type, dep_filename_conv)
        return "because analyzer toolchain is configured" if Bake.options.analyze
        return "because prepro was specified and source is no assembler file" if Bake.options.prepro

        Dir.mutex.synchronize do
          Dir.chdir(@projectDir) do
            return "because object does not exist" if not File.exist?(object)
            oTime = File.mtime(object)

            return "because source is newer than object" if oTime < File.mtime(source)

            if type != :ASM
              return "because dependency file does not exist" if not File.exist?(dep_filename_conv)

              begin
                File.readlines(dep_filename_conv).map{|line| line.strip}.each do |dep|
                  Thread.current[:filelist].add(File.expand_path(dep, @projectDir)) if Bake.options.filelist

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
          end
        end
        return false
      end

      def calcObjectBasename(object)
        object.chomp(File.extname(object))
      end

      def calcCmdlineFile(object)
        File.expand_path(calcObjectBasename(object) + ".cmdline", @projectDir)
      end

      def calcDepFile(object, type)
        dep_filename = nil
        if type != :ASM
          dep_filename = calcObjectBasename(object) + ".d"
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

        Thread.current[:filelist].add(File.expand_path(source, @projectDir)) if Bake.options.filelist

        if @fileTcs[source]
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

        cmd = Utils.flagSplit(compiler[:PREFIX], true)
        cmd += Utils.flagSplit(compiler[:COMMAND], true)
        onlyCmd = cmd
        cmd += compiler[:COMPILE_FLAGS].split(" ")

        if dep_filename
          cmdDep = compiler[:DEP_FLAGS].split(" ")
          if compiler[:DEP_FLAGS_FILENAME]
            if compiler[:DEP_FLAGS_SPACE]
              cmdDep << dep_filename
            else
              if dep_filename.include?" "
                cmdDep[cmdDep.length-1] << "\"" + dep_filename + "\""
              else
                cmdDep[cmdDep.length-1] << dep_filename
              end
            end
          end
          if compiler[:CUDA]
            if compiler[:CUDA_PREFIX] == ""
              Bake.formatter.printWarning("Warning: Cuda not yet supported by this toolchain.")
            else
              cmdDep.each do |c|
                cmd += [compiler[:CUDA_PREFIX], c]
              end
              cmdDep = nil
            end
          end
          cmd += cmdDep if cmdDep
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
          srcFilePath = source
          if Bake.options.abs_path_in
            srcFilePath = File.join(@projectDir, srcFilePath) if !File.is_absolute?(srcFilePath)
            cmdJson[source] = srcFilePath
          end
          cmdJson.gsub!("\"" , "\\\"")
          Blocks::CC2J << { :directory => @projectDir, :command => cmdJson, :file => srcFilePath }
        end

        if not (cmdLineCheck and BlockBase.isCmdLineEqual?(cmd, cmdLineFile))
          BlockBase.prepareOutput(File.expand_path(object,@projectDir))
          outputType = Bake.options.analyze ? "Analyzing" : (Bake.options.prepro ? "Preprocessing" : "Compiling")
          realCmd = Bake.options.fileCmd ? calcFileCmd(cmd, onlyCmd, object, compiler) : cmd 
          printCmd(realCmd, "#{outputType} #{@projectName} (#{@config.name}): #{source}", reason, false)
          SyncOut.flushOutput()
          BlockBase.writeCmdLineFile(cmd, cmdLineFile)

          success = true
          consoleOutput = ""
          incList = nil

          if !Bake.options.diabCaseCheck
            success, consoleOutput = ProcessHelper.run(realCmd, false, false, nil, [0], @projectDir) if !Bake.options.dry
            incList = process_result(realCmd, consoleOutput, compiler[:ERROR_PARSER], nil, reason, success)
          end

          if type != :ASM && !Bake.options.analyze && !Bake.options.prepro
            Dir.mutex.synchronize do
              if !Bake.options.diabCaseCheck
                Dir.chdir(@projectDir) do
                  incList = Compile.read_depfile(dep_filename, @projectDir, @block.tcs[:COMPILER][:DEP_FILE_SINGLE_LINE], compiler[:COMMAND]) if incList.nil?
                  Compile.write_depfile(source, incList, dep_filename_conv, @projectDir)
                end
              end
              if !Bake.options.dry && Bake.options.caseSensitivityCheck
                wrongCase = []

                if compiler[:COMMAND] == "dcc"
                  if Bake.options.diabCaseCheck
                    pos = cmd.find_index(compiler[:OBJECT_FILE_FLAG])
                    preProCmd = (cmd[0..pos-1] + cmd[pos+2..-1] + ["-E"])
                    preProCmd = calcFileCmd(preProCmd, onlyCmd, object, compiler, ".dccCaseCheck") if Bake.options.fileCmd
                    success, consoleOutput = ProcessHelper.run(preProCmd, false, false, nil, [0], @projectDir)
                    if !success
                      Bake.formatter.printError("Error: could not compile #{source}")
                      raise SystemCommandFailed.new
                    end
                    Dir.chdir(@projectDir) do
                      incList = Compile.read_depfile(dep_filename, @projectDir, @block.tcs[:COMPILER][:DEP_FILE_SINGLE_LINE], compiler[:COMMAND])
                      Compile.write_depfile(source, incList, dep_filename_conv, @projectDir)
                    end
                    ergs = consoleOutput.scan(/# \d+ "([^"]+)" \d+/)
                    ergs.each do |f|
                      next if source.include?f[0]
                      next if f[0].length>=2 && f[0][1] == ":"
                      filenameToCheck = f[0].gsub(/\\/,"/").gsub(/\/\//,"/").gsub(/\A\.\//,"")
                      if incList.none?{|i| i.include?(filenameToCheck) }
                        Dir.chdir(@projectDir) do
                          wrongCase << [filenameToCheck, realname(filenameToCheck)]
                        end
                      end
                    end
                  end
                else # not diab
                  Dir.chdir(@projectDir) do
                    incList.each do |dep|
                      if dep.length<2 || dep[1] != ":"
                        real = realname(dep)
                        if dep != real && dep.upcase == real.upcase
                          wrongCase << [dep, real]
                        end
                      end
                    end unless incList.nil?
                  end
                end

                if wrongCase.length > 0
                  wrongCase.each do |c|
                    Bake.formatter.printError("Case sensitivity error in #{source}:\n  included: #{c[0]}\n  realname: #{c[1]}")
                  end
                  FileUtils.rm_f(dep_filename_conv)
                  raise SystemCommandFailed.new
                end
              end

            end

            incList.each do |h|
              Thread.current[:filelist].add(File.expand_path(h, @projectDir))
            end if Bake.options.filelist
          end
          check_config_file
        else
          if Bake.options.filename and Bake.options.verbose >= 1
            puts "Up-to-date #{source}"
            SyncOut.flushOutput()
          end
        end
      end

      def self.read_depfile(dep_filename, projDir, lineType, command = "")
        deps = []
        begin
          lineType = :single if command.include?("cafeCC")
          if lineType == :single
            File.readlines(dep_filename).each do |line|
              splitted = line.split(": ")
              if splitted.length > 1
                deps << splitted[1].gsub(/[\\]/,'/')
              else
                splitted = line.split(":\t") # right now only for tasking compiler
                if splitted.length > 1
                  dep = splitted[1].gsub(/[\\]/,'/').strip
                  dep = dep[1..-2] if dep.start_with?("\"")
                  deps << dep
                end
              end
            end
          elsif lineType == :multi
            deps_string = File.read(dep_filename)
            deps_string = deps_string.gsub(/\\\n/,'')
            dep_splitted = deps_string.split(/([^\\]) /).each_slice(2).map(&:join)[2..-1]
            deps = dep_splitted.map { |d| d.gsub(/[\\] /,' ').gsub(/\\:\\/,':\\').gsub(/[\\]/,'/').strip }.delete_if {|d| d == "" }
          elsif lineType == :plain
            firstLine = true
            File.readlines(dep_filename).each do |line|
              if firstLine
                firstLine = false
              else
                deps << line
              end
            end
          end
        rescue Exception => ex1
          if !Bake.options.dry
            Bake.formatter.printWarning("Could not read '#{dep_filename}'", projDir)
            puts ex1.message if Bake.options.debug
          end
          return nil
        end
        deps
      end

      # todo: move to toolchain util file
      def self.write_depfile(source, deps, dep_filename_conv, projDir)
        if deps && !Bake.options.dry
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

      def execute
          return true if @config.files.empty?
          
          SyncOut.mutex.synchronize do
            calcIncludes
            calcDefines # not for files with changed tcs
            calcFlags   # not for files with changed tcs
            calcSources
            calcObjects
            puts "Profiling #{Time.now - $timeStart}: prepareIncludes (#{@projectName+","+@config.name}) start..." if Bake.options.profiling
            prepareIncludes
            puts "Profiling #{Time.now - $timeStart}: prepareIncludes (#{@projectName+","+@config.name}) stop..." if Bake.options.profiling
          end

          odir = File.expand_path(@block.output_dir, @projectDir)
          Utils.gitIgnore(odir) if !Bake.options.dry

          fileListBlock = Set.new if Bake.options.filelist
          @source_files_compiled = @source_files.dup
          compileJobs = Multithread::Jobs.new(@source_files) do |jobs|
            while source = jobs.get_next_or_nil do

              if (jobs.failed && Bake.options.stopOnFirstError) or Bake::IDEInterface.instance.get_abort
                break
              end

              SyncOut.startStream()
              begin
                Thread.current[:filelist] = Set.new if Bake.options.filelist
                Thread.current[:lastCommand] = nil

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
              ensure
                SyncOut.stopStream()
              end
              self.mutex.synchronize do
                fileListBlock.merge(Thread.current[:filelist]) if Bake.options.filelist
              end

            end
          end
          compileJobs.join

          if Bake.options.filelist && !Bake.options.dry
            Bake.options.filelist.merge(fileListBlock.merge(fileListBlock))

            File.open(odir + "/" + "file-list.txt", 'wb') do |f|
              fileListBlock.sort.each do |entry|
                f.puts(entry)
              end
            end

          end

          raise SystemCommandFailed.new if compileJobs.failed

        #end
        return true
      end

      def clean
        if (Bake.options.filename or Bake.options.analyze)
          Dir.chdir(@projectDir) do
            calcSources(true)
            @source_files.each do |source|

              type = get_source_type(source)
              next if type.nil?
              object = get_object_file(source)
              if File.exist?object
                puts "Deleting file #{object}" if Bake.options.verbose >= 2
                if !Bake.options.dry
                  FileUtils.rm_rf(object)
                end
              end
              if not Bake.options.analyze
                dep_filename = calcDepFile(object, type)
                if dep_filename and File.exist?dep_filename
                  puts "Deleting file #{dep_filename}" if Bake.options.verbose >= 2
                  if !Bake.options.dry
                    FileUtils.rm_rf(dep_filename)
                  end
                end
                cmdLineFile = calcCmdlineFile(object)
                if File.exist?cmdLineFile
                  puts "Deleting file #{cmdLineFile}" if Bake.options.verbose >= 2
                  if !Bake.options.dry
                    FileUtils.rm_rf(cmdLineFile)
                  end
                end
              end
            end
          end
        end
        return true
      end

      def calcObjects
        @object_files_ignored_in_lib = []
        @source_files.map! do |source|
          type = get_source_type(source)
          if not type.nil?
            object = get_object_file(source)

            if Bake.options.abs_path_in
              object = File.expand_path(object, @projectDir)
              source = File.expand_path(source, @projectDir)
            end

            if @objects.include?object
              @object_files.each do |k,v|
                if (v == object) # will be found exactly once
                  Bake.formatter.printError("Source files '#{k}' and '#{source}' would result in the same object file", source)
                  raise SystemCommandFailed.new
                end
              end
            end
            @object_files[source] = object
            if @source_files_ignored_in_lib.include?(source)
              if @source_files_link_directly.include?(source)
                @object_files_ignored_in_lib << object
              end
            else
              @objects << object
            end
          end
          source
        end
      end

      def calcSources(cleaning = false, keep = false)
        return @source_files if @source_files && !@source_files.empty?
        @source_files = []
        @source_files_ignored_in_lib = []
        @source_files_link_directly = []
        @fileTcs = {}

        exclude_files = Set.new
        @config.excludeFiles.each do |pr|
          Dir.glob_dir(pr.name, @projectDir).each {|f| exclude_files << f}
        end

        source_files = Set.new
        @config.files.each do |sources|
          pr = sources.name
          pr = pr[2..-1] if pr.start_with?"./"

          res = Dir.glob_dir(pr, @projectDir).select {|f| !get_source_type(f).nil?}.sort
          if res.length == 0 and cleaning == false
            if not pr.include?"*" and not pr.include?"?"
              Bake.formatter.printError("Source file '#{pr}' not found", sources)
              raise SystemCommandFailed.new
            elsif Bake.options.verbose >= 1
              Bake.formatter.printInfo("Source file pattern '#{pr}' does not match to any file", sources)
            end
          end
          if (sources.define.length > 0 or sources.flags.length > 0)
            icf = integrateCompilerFile(Utils.deep_copy(@block.tcs),sources)
          end
          res.each do |f|
            singleFile = res.length == 1 && res[0] == pr
            fTcs = (Bake.options.abs_path_in ? File.expand_path(f, @projectDir) : f)
            if ((!@fileTcs.has_key?(fTcs)) || singleFile)
              @fileTcs[fTcs] = icf
            end
            if source_files.include?(f) || exclude_files.include?(f)
              if (singleFile)
                @source_files_ignored_in_lib << f if sources.compileOnly || sources.linkDirectly
                @source_files_link_directly << f if sources.linkDirectly
              end
              next
            end
            source_files << f
            @source_files << f
            @source_files_ignored_in_lib << f if sources.compileOnly || sources.linkDirectly
            @source_files_link_directly << f if sources.linkDirectly
          end
        end

        if Bake.options.filename
          @source_files.keep_if do |source|
            source.include?Bake.options.filename
          end
          if @source_files.length == 0 and cleaning == false and @config.files.length > 0 and Bake.options.verbose >= 2
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

        return @source_files
      end

      def calcIncludesInternal(block)
        noDeps = @blocksRead.include?(block)
        @blocksRead << block
        block.bes.each do |be|
          if Metamodel::IncludeDir === be
            if be.inherit == true || block == @block
              if Bake.options.abs_path_in
                mappedInc = be.name
              else
                mappedInc = File.rel_from_to_project(@projectDir,be.name,false)
                mappedInc  = "." if mappedInc.empty?
              end
              if !@include_set.include?(mappedInc)
                @include_list << mappedInc
                @include_set << mappedInc
                if !@include_merge.has_key?(mappedInc)
                  if be.parent.mergeInc == "no"
                    @include_merge[mappedInc] = false
                  elsif @config.mergeInc == "all"
                    @include_merge[mappedInc] = true
                  elsif @block.config != be.parent && @config.mergeInc == "yes"
                    @include_merge[mappedInc] = true
                  else
                    @include_merge[mappedInc] = false
                  end
                end
                @system_includes << mappedInc if be.system
              end
            end
          elsif Metamodel::Dependency === be
            if (!noDeps)
              childBlock = Blocks::ALL_BLOCKS[be.name + "," + be.config]
              if block.projectName == be.parent.parent.name &&
                block.configName == be.parent.name
                next if @blocksRead.include?(childBlock)
              end
              calcIncludesInternal(childBlock)
            end
          end
        end
      end

      def calcIncludes
        @blocksRead = Set.new
        @include_set = Set.new
        @include_list = []
        @include_merge = {}
        @system_includes = Set.new
        calcIncludesInternal(@block) # includeDir and child dependencies with inherit: true
        @include_list = @include_list.flatten.uniq
      end

      def prepareIncludes
        mergeCounter = 0
        inmerge = false
        mdir = nil
        include_list_new = []
        filesToCopy = {}
        destDirs = Set.new
        merging = false
        @include_list.reverse.each do |idir|
          idirs = idir.to_s
          idirs = File.expand_path(idirs, @projectDir) if !File.is_absolute?(idirs)
          if @include_merge[idir]
            if (!inmerge)
              mergeCounter += 1
              mdir = File.expand_path(@block.output_dir+"/mergedIncludes#{mergeCounter}", @projectDir)
              FileUtils.rm_rf(mdir)
              Utils.gitIgnore(mdir)
              inmerge = true
            end
            if !merging
              puts "Profiling #{Time.now - $timeStart}: glob..." if Bake.options.profiling
            end
            merging = true

            toCopy = Dir.glob(idirs+"/**/*").
              reject { |file| file.start_with?(idirs+"/build/") || file.start_with?(idirs+"/.") }.
              select { |file| File.file?(file) && /^\.(h|i|cfg)/ === File.extname(file) }
            toCopy.each do |t|
              dest = mdir+t[idirs.length..-1]
              destDirs << File.dirname(dest)
              if filesToCopy.has_key?(t)
                filesToCopy[t] << dest
              else
                filesToCopy[t] = [dest]
              end
            end
            include_list_new << (@block.output_dir+"/mergedIncludes#{mergeCounter}")
          else
            if (inmerge)
              inmerge = false
            end
            include_list_new << idir
          end
        end
        if merging
          sizeWarning = 100000
          sum = filesToCopy.keys.inject(0) do |sum,t|
            si = File.size(t)
            puts "Size warning (>#{sizeWarning} byte): #{t} has #{si} byte" if si > sizeWarning and Bake.options.profiling
            sum + si
          end
          puts "Profiling #{Time.now - $timeStart}: copy #{sum} byte in #{filesToCopy.length} files..." if Bake.options.profiling
          destDirs.each {|d| Utils.gitIgnore(d) }
          filesToCopy.each do |t, dest|
            dest.each do |d|
              FileUtils.cp_r(t, d, :preserve => true)
            end
          end
        end
        @include_list = include_list_new.uniq.reverse

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
        (compiler[:DEFINES] + Bake.options.defines).map {|k| "#{compiler[:DEFINE_FLAG]}#{k}"}
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

    end

  end
end