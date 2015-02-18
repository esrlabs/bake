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
      
      def initialize(block, config, referencedConfigs, tcs)
        super(block, config, referencedConfigs, tcs)
        @objects = []
        
        calcFileTcs
        calcIncludes
        calcDefines # not for files with changed tcs
        calcFlags   # not for files with changed tcs
      end
   
      def get_object_file(source)
        adaptedSource = source.chomp(File.extname(source)).gsub(/\.\./, "##") + (Bake.options.prepro ? ".i" : ".o")
        return adaptedSource if File.is_absolute?source
        File.join([@output_dir, adaptedSource])
      end
      
      def needed?(source, object, type, dep_filename_conv)
        return false if Bake.options.linkOnly

        return "because prepro was specified" if Bake.options.prepro
        
        return "because object does not exist" if not File.exist?(object)
        oTime = File.mtime(object)
        
        return "because config file has been changed" if oTime < File.mtime(@config.file_name)
        return "Compiling #{source} because DefaultToolchain has been changed" if oTime < Bake::Config.defaultToolchainTime
        
        return "because source is newer than object" if oTime < File.mtime(source)

        if type != :ASM
          return "because dependency file does not exist" if not File.exist?(dep_filename_conv)
          
          begin
            File.readlines(dep_filename_conv).map{|line| line.strip}.each do |dep|
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
          return t if @tcs[:COMPILER][t][:SOURCE_FILE_ENDINGS].include?(ex)
        end
        nil
      end
                
      def compileFile(source)
        type = get_source_type(source)
        return true if type.nil?
        
        object = get_object_file(source)
        @objects << object
        
        dep_filename = calcDepFile(object, type)
        dep_filename_conv = calcDepFileConv(dep_filename) if type != :ASM
        
        reason = needed?(source, object, type, dep_filename_conv)
        return true unless reason

        if @fileTcs.include?(source)
          compiler = @fileTcs[source][:COMPILER][type]
          defines = getDefines(compiler)
          flags = getFlags(compiler)
        else
          compiler = @tcs[:COMPILER][type]
          defines = @define_array[type]
          flags = @flag_array[type]
        end
        includes = @include_array[type]

        if Bake.options.prepro and compiler[:PREPRO_FLAGS] == "" 
          Bake.formatter.printError("Error: No preprocessor option available for " + source)
          raise SystemCommandFailed.new 
        end
                   
        BlockBase.prepareOutput(object)
        
        cmd = Utils.flagSplit(compiler[:COMMAND], false)
        cmd += compiler[:COMPILE_FLAGS].split(" ")
          
        if dep_filename
          cmd += @tcs[:COMPILER][type][:DEP_FLAGS].split(" ")
          if @tcs[:COMPILER][type][:DEP_FLAGS_FILENAME]
            if @tcs[:COMPILER][type][:DEP_FLAGS_SPACE]
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
        
        if compiler[:OBJ_FLAG_SPACE]
          cmd << compiler[:OBJECT_FILE_FLAG]
          cmd << object
        else
          if object.include?" "
            cmd << compiler[:OBJECT_FILE_FLAG] + "\"" + object + "\"" 
          else
            cmd << compiler[:OBJECT_FILE_FLAG] + object
          end
        end
        cmd << source

        if Bake.options.cc2j_filename
          Blocks::CC2J << { :directory => @projectDir, :command => cmd, :file => source }
        end
        
        success, consoleOutput = ProcessHelper.run(cmd, false, false)
        outputType = Bake.options.prepro ? "Preprocessing" : "Compiling"
        process_result(cmd, consoleOutput, compiler[:ERROR_PARSER], "#{outputType} #{source}", reason, success)
   
        Compile.convert_depfile(dep_filename, dep_filename_conv, @projectDir, @tcs[:COMPILER][:DEP_FILE_SINGLE_LINE]) if type != :ASM
        check_config_file
      end

      def self.read_depfile(dep_filename, projDir, singeLine)
        deps = []
        begin
          if singeLine
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
        rescue Exception
          Bake.formatter.printWarning("Could not read '#{dep_filename}'", projDir)
          return nil
        end
        deps
      end
      
      # todo: move to toolchain util file
      def self.convert_depfile(dep_filename, dep_filename_conv, projDir, singleLine)
        deps = read_depfile(dep_filename, projDir, singleLine)
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
          
          @error_strings = {}
          
          compileJobs = Multithread::Jobs.new(@source_files) do |jobs|
            while source = jobs.get_next_or_nil do
              
              if (jobs.failed and Bake.options.stopOnFirstError) or Bake::IDEInterface.instance.get_abort
                break
              end
              
              s = StringIO.new
              tmp = Thread.current[:stdout]
              Thread.current[:stdout] = s unless tmp
                  
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

          # can only happen in case of bail_on_first_error.
          # if not sorted, it may be confusing when builing more than once and the order of the error appearances changes from build to build
          # (it is not deterministic which file compilation finishes first)
          @error_strings.sort.each {|es| puts es[1]}
                      
          raise SystemCommandFailed.new if compileJobs.failed
          
        end
      end
      
      def clean
        if Bake.options.filename
          Dir.chdir(@projectDir) do
            calcSources(true)
            @source_files.each do |source|
              
              type = get_source_type(source)
              next if type.nil?
              object = get_object_file(source)
              dep_filename = calcDepFile(object, type)
              if File.exist?object 
                puts "Deleting file #{object}" if Bake.options.verbose >= 2
                FileUtils.rm_rf(object)
              end
              if File.exist?dep_filename 
                puts "Deleting file #{dep_filename}" if Bake.options.verbose >= 2
                FileUtils.rm_rf(dep_filename)
              end
            end
          end
        end
      end
      
      def calcSources(cleaning = false)
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
            source_files << f
          end
        end
        
        if Bake.options.filename
          source_files.keep_if do |source|
            source.include?Bake.options.filename
          end
          if source_files.length == 0 and cleaning == false
            Bake.formatter.printInfo("#{Bake.options.filename} does not match to any source", @config)
          end
        end
        
        @source_files = source_files.sort.to_a
      end
        
      def calcIncludes
        @include_list = @config.includeDir.map do |dir|
          (dir.name == "___ROOTS___") ? (Bake.options.roots.map { |r| File.rel_from_to_project(@projectDir,r,false) }) : @block.convPath(dir)
        end.flatten
        
        @include_array = {}
        [:CPP, :C, :ASM].each do |type|
          @include_array[type] = @include_list.map {|k| "#{@tcs[:COMPILER][type][:INCLUDE_PATH_FLAG]}#{k}"}
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
          @define_array[type] = getDefines(@tcs[:COMPILER][type])
        end
      end
      def calcFlags
        @flag_array = {}
        [:CPP, :C, :ASM].each do |type|
          @flag_array[type] = getFlags(@tcs[:COMPILER][type])
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
              @fileTcs[f.name] = integrateCompilerFile(Utils.deep_copy(@tcs),f)
            end
          end
        end
      end
      
      def tcs4source(source)
        @fileTcs[source] || @tcs
      end      
      
      
    end
    
  end
end