require 'blocks/blockBase'
require 'multithread/job'
require 'yaml'
require 'imported/utils/process'
require 'imported/utils/utils'
require 'bake/toolchain/colorizing_formatter'
require 'bake/config/loader'

module Bake
  
  module Blocks
    
    class Compile < BlockBase
      
      attr_reader :objects
      
      def initialize(block, config, referencedConfigs, tcs)
        super(block, config, referencedConfigs, tcs)
        @objects = []
          
        @src_pattern    = config.files.map        { |f| f.name }
        @ex_src_pattern = config.excludeFiles.map { |f| f.name }     
        
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
      
      def needed?(source, object, type, dep_filename)
        return false if Bake.options.linkOnly
        return true if Bake.options.prepro
        
        return true if not File.exist?(object)
        oTime = File.mtime(object)
        return true if oTime < File.mtime(@config.file_name)
        return true if oTime < Bake::Config.defaultToolchainTime 
        return true if oTime < File.mtime(source) 
        
        if type != :ASM
          begin
            deps = YAML.load_file(dep_filename)
            deps.each do |d|
              return true if not File.exist?(d) or oTime < File.mtime(d) 
            end
          rescue Exception => ex
            # puts ex.message
           #  puts ex.backtrace
            # may happen if dep_filename was not converted the last time
            return true
          end
        end


                
        false
      end
      
      
      def calcDepFile(object, type)
        dep_filename = nil
        if type != :ASM
          dep_filename = object[0..-3] + ".d"
          dep_filename = "\"" + dep_filename + "\"" if dep_filename.include?" "
        end
        dep_filename
      end

      def get_source_type(source)
        ex = File.extname(source)
        [:CPP, :C, :ASM].each do |t|
          return t if @tcs[:COMPILER][t][:SOURCE_FILE_ENDINGS].include?(ex)
        end
        nil
      end
                
      def compileFile(source)
        
        #if File.is_absolute?(source)
        #  source = File.rel_from_to_project(@projectDir, source, false)
        #end
        
        type = get_source_type(source)
        return true if type.nil? # todo: info output
        
        object = get_object_file(source)
        @objects << object
        
        dep_filename = calcDepFile(object, type)
        
        return true if not needed?(source, object, type, dep_filename)

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
          Bake.formatter.printError("Info: No preprocessor option available for " + source)
          raise SystemCommandFailed.new 
        end
                   
        prepareOutputDir(object)

        
        cmd = [compiler[:COMMAND]]
        cmd += compiler[:COMPILE_FLAGS].split(" ")
          
        if dep_filename
          cmd += @tcs[:COMPILER][type][:DEP_FLAGS].split(" ")
          if @tcs[:COMPILER][type][:DEP_FLAGS_FILENAME]
            if @tcs[:COMPILER][type][:DEP_FLAGS_SPACE]
              cmd << dep_filename
            else
              cmd[cmd.length-1] << dep_filename
            end
          end
        end
             
             
        cmd += compiler[:PREPRO_FLAGS].split(" ") if Bake.options.prepro
        cmd += flags
        cmd += includes
        cmd += defines
        cmd += (compiler[:OBJECT_FILE_FLAG] + object).split(" ")
        cmd << source
   
        rd, wr = IO.pipe
        cmd << { :err=>wr, :out=>wr }
        success, consoleOutput = ProcessHelper.safeExecute() { sp = spawn(*cmd); ProcessHelper.readOutput(sp, rd, wr) }
        cmd.pop
   
        outputType = Bake.options.prepro ? "Preprocessing" : "Compiling"
        process_result(cmd, consoleOutput, compiler[:ERROR_PARSER], "#{outputType} #{source}", success)
   
        convert_depfile(dep_filename)
        check_config_file
      end

      def convert_depfile(dep_filename)
        return if not dep_filename or not File.exist?(dep_filename)
        deps_string = File.read(dep_filename)
        # deps_string looks like "test.o: test.cpp test.h" -> remove .o and .cpp from list
        deps = deps_string.gsub(/\\\n/,'').split()[2..-1]
        return if deps.nil? # ok, because next run the source will be recompiled due to invalid dep_filename
        expanded_deps = deps.map { |d| d.gsub(/[\\]/,'/') }
        File.open(dep_filename, 'wb') { |f| f.write(expanded_deps.to_yaml) }
      end

      def deps_in_depFiles
        @deps_in_depFiles ||= Set.new
      end

            
      def mutex
        @mutex ||= Mutex.new
      end
      
      def execute
        Dir.chdir(@projectDir) do
        
          calcSources
          
          @error_strings = {}
          
          # TODO: test when no files are added
          compileJobs = Multithread::Jobs.new(@source_files) do |jobs|
            while true do
              
              if jobs.failed and (Bake.options.stopOnFirstError or Blocks::ABORTED)
                break
              end
              
              source = jobs.get_next_or_nil
              break unless source # TODO: write better while
        
              s = StringIO.new
              tmp = Thread.current[:stdout]
              Thread.current[:stdout] = s unless tmp
                  
              result = false
              begin
                compileFile(source)
                result = true
              rescue Bake::ExitHelperException
                raise ## ?
              rescue Bake::SystemCommandFailed => scf # normal compilation error
                # delete file?
              rescue SystemExit => exSys
                ProcessHelper.killProcess # delete file when killing process! ?
              rescue Exception => ex1
                # delete file?
                if not Blocks::ABORTED # means no kill from IDE. TODO: test this!
                  Bake.formatter.printError "Error: #{ex1.message}"
                  puts ex1.backtrace if Bake.options.debug
                end
              end 
              
              jobs.set_failed if not result
                
              Thread.current[:stdout] = tmp
                  
              mutex.synchronize do
                if s.string.length > 0 
                  if Bake.options.stopOnFirstError and not success
                    @error_strings[source] = s.string
                  else
                    puts s.string
                  end
                end
              end                  
                  
                # if failed....
                
            end
          end
          compileJobs.join
            
          raise SystemCommandFailed.new if compileJobs.failed
          
        end
          
        # can only happen in case of bail_on_first_error.
        # if not sorted, it may be confusing when builing more than once and the order of the error appearances changes from build to build
        # (it is not deterministic which file compilation finishes first)
        @error_strings.sort.each {|es| puts es[1]}
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
                puts "Deleting file #{object}" if Bake.options.verboseHigh
                FileUtils.rm_rf(object)
              end
              if File.exist?dep_filename 
                puts "Deleting file #{dep_filename}" if Bake.options.verboseHigh
                FileUtils.rm_rf(dep_filename)
              end
            end
          end
        end
      end
      
      def calcSources(quite = false)
        @source_files = []
    
        exclude_files = Set.new
        @ex_src_pattern.each do |p|
          Dir.glob(p).each {|f| exclude_files << f}
        end
          
        source_files = Set.new
        @src_pattern.each do |p|
          res = Dir.glob(p)
          if res.length == 0 and Bake.options.verboseHigh and quite == false
            Bake.formatter.printInfo "Info: Source file pattern '#{p}' did not match to any file"
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
          if source_files.length == 0 and not Bake.options.verboseLow and quite == false
            Bake.formatter.printInfo "Info: #{Bake.options.filename} did not match to any source"
          end
        end
        
        @source_files = source_files.sort.to_a
      end
        
      def calcIncludes
        incList = @config.includeDir.map do |dir|
          (dir.name == "___ROOTS___") ? (Bake.options.roots.map { |r| File.rel_from_to_project(@projectDir,r,false) }) : @block.convPath(dir)
        end.flatten
        
        @include_array = {}
        [:CPP, :C, :ASM].each do |type|
          @include_array[type] = incList.map {|k| "#{@tcs[:COMPILER][type][:INCLUDE_PATH_FLAG]}#{k}"}
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
              Bake.formatter.printWarning "Warning: #{@config.file_name}(#{f.line_number}): toolchain settings not allowed for file pattern #{f.name}"
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