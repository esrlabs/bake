require 'imported/buildingblocks/building_block'
require 'imported/buildingblocks/has_libraries_mixin'
require 'imported/buildingblocks/has_sources_mixin'
require 'imported/buildingblocks/has_includes_mixin'
require 'imported/utils/process'
require 'imported/utils/utils'
require 'imported/ext/stdout'

require 'tmpdir'
require 'set'
require 'etc'

module Bake

  class Executable < BuildingBlock
    include HasLibraries
    include HasSources
    include HasIncludes

    def set_linker_script(x)
      @linker_script = x
      self
    end

    def set_mapfile(x)
      @mapfile = x
      self
    end

    def initialize(projectName, configName)
      super
      @linker_script = nil
      @mapfile = nil
    end

    def set_executable_name(name) # ensure it's relative
      @exe_name = name
    end

    def get_executable_name() # maybe relative path
      @exe_name ||= File.join([@output_dir_relPath, "#{@project_name}#{@tcs[:LINKER][:OUTPUT_ENDING]}"])
    end

    def get_full_exe_name() # full path
      @full_exe_name ||= File.join([@output_dir, "#{@project_name}#{@tcs[:LINKER][:OUTPUT_ENDING]}"])
    end
    
    def get_task_name() # full path
      @task_name ||= "MAIN "+@project_name+","+@config_name
    end


    def collect_unique(array, set)
      ret = []
      array.each do |v|
        if set.add?(v)
          ret << v
        end
      end
      ret
    end

    def adaptPath(v, d, prefix)
      tmp = nil
      if File.is_absolute?(v)
        tmp = v
      else
        prefix ||= File.rel_from_to_project(@project_dir,d.project_dir)
        tmp = File.add_prefix(prefix, v)
      end
      tmp = "\"" + tmp + "\"" if tmp.include?(" ")
      [tmp, prefix]
    end

    def linker_lib_string()
      @lib_path_set = []
      @dep_set = Set.new
      res = calc_linker_lib_string_recursive(self)
      return res if (@tcs[:LINKER][:LIST_MODE] == false)
      
      res.map { |x| x+"(*.o)"}
      if not (@lib_path_set.empty?)
        res << (@tcs[:LINKER][:LIB_PATH_FLAG] + @lib_path_set.join(","));
      end
      res
    end

    def calc_linker_lib_string_recursive(d)
      res = []

      return res if @dep_set.include?d
      @dep_set << d
      
#      puts "CCCCCCCCCC: #{d.get_task_name}"
      
     # if ModuleBuildingBlock === d
     #   puts "AAAAAAAAAAAAAAAAAA"
     #   d.dependencies.each do |e| # maybe reverse_each
     #     puts "BBBBBBBBBB: #{ALL_BUILDING_BLOCKS[e].get_task_name}"
     #     res += calc_linker_lib_string_recursive(ALL_BUILDING_BLOCKS[e])
     #   end
     #   return res
     # end
      
      if HasLibraries === d
        prefix = nil
        linker = @tcs[:LINKER]
          
        d.lib_elements.each do |elem|
          case elem[0]
            when HasLibraries::LIB
              res << "#{linker[:LIB_FLAG]}#{elem[1]}"
            when HasLibraries::USERLIB
              res << "#{linker[:USER_LIB_FLAG]}#{elem[1]}"
            when HasLibraries::LIB_WITH_PATH
              tmp, prefix = adaptPath(elem[1], d, prefix)
              res <<  tmp
            when HasLibraries::SEARCH_PATH
              tmp, prefix = adaptPath(elem[1], d, prefix)
              if not @lib_path_set.include?tmp
                @lib_path_set << tmp
                res << "#{linker[:LIB_PATH_FLAG]}#{tmp}" if linker[:LIST_MODE] == false
              end
            when HasLibraries::DEPENDENCY
              if ALL_BUILDING_BLOCKS.include?elem[1]
                bb = ALL_BUILDING_BLOCKS[elem[1]]
                res += calc_linker_lib_string_recursive(bb)
              end
          end
        end
      end

      res
    end

    # create a task that will link an executable from a set of object files
    #
    def convert_to_rake()
      object_multitask = prepare_tasks_for_objects()
      linker = @tcs[:LINKER]

      res = typed_file_task Rake::Task::EXECUTABLE, get_full_exe_name => object_multitask do
        Dir.chdir(@project_dir) do

          cmd = [linker[:COMMAND]] # g++
          cmd += linker[:MUST_FLAGS].split(" ")
          cmd += Bake::Utils::flagSplit(linker[:FLAGS],true)
          cmd << linker[:EXE_FLAG]
          cmd << get_executable_name # -o debug/x.exe
          cmd += @objects
          cmd << linker[:SCRIPT] if @linker_script # -T
          cmd << @linker_script if @linker_script # xy/xy.dld
          cmd += linker[:MAP_FILE_FLAG].split(" ") if @mapfile # -Wl,-m6
          if not linker[:MAP_FILE_PIPE] and @mapfile 
            cmd[cmd.length-1] << @mapfile 
          end
          cmd += Bake::Utils::flagSplit(linker[:LIB_PREFIX_FLAGS],true) # "-Wl,--whole-archive "
          cmd += linker_lib_string
          cmd += Bake::Utils::flagSplit(linker[:LIB_POSTFIX_FLAGS],true) # "-Wl,--no-whole-archive "

          mapfileStr = (@mapfile and linker[:MAP_FILE_PIPE]) ? " >#{@mapfile}" : ""
          if Bake::Utils.old_ruby?
            cmd.map! {|c| ((c.include?(" ")) ? ("\""+c+"\"") : c )}

            # TempFile used, because some compilers, e.g. diab, uses ">" for piping to map files:
            cmdLinePrint = cmd.join(" ")
            cmdLine = cmdLinePrint + " 2>" + get_temp_filename
            if cmdLine.length > 8000
              inputName = get_executable_name+".tmp"
              File.open(inputName,"wb") { |f| f.write(cmd[1..-1].join(" ")) }
              inputName = "\""+inputName+"\"" if inputName.include?" "
              strCmd = "#{linker[:COMMAND] + " @" + inputName + mapfileStr + " 2>" + get_temp_filename}"
            else
              strCmd = "#{cmd.join(" ") + mapfileStr + " 2>" + get_temp_filename}"
            end
            printCmd(cmdLinePrint, "Linking #{get_executable_name}", false)
            
            success, consoleOutput, exceptionThrown = ProcessHelper.safeExecute() { `#{strCmd}` }
            consoleOutput.concat(read_file_or_empty_string(get_temp_filename)) unless exceptionThrown
            
          else
            rd, wr = IO.pipe
            cmdLinePrint = cmd
            printCmd(cmdLinePrint, "Linking #{get_executable_name}", false)
            cmd << {
             :out=> (@mapfile and linker[:MAP_FILE_PIPE]) ? "#{@mapfile}" : wr, # > xy.map
             :err=>wr
            }
            
            success, consoleOutput = ProcessHelper.safeExecute() { sp = spawn(*cmd); ProcessHelper.readOutput(sp, rd, wr) }
            cmd.pop

            # for console print
            cmd << " >#{@mapfile}" if (@mapfile and linker[:MAP_FILE_PIPE])
          end

          process_result(cmdLinePrint, consoleOutput, linker[:ERROR_PARSER], nil, success)

          check_config_file()
        end
      end
      
      res.immediate_output = true
      res.enhance(@config_files)
      res.enhance([@project_dir + "/" + @linker_script]) if @linker_script

      add_output_dir_dependency(get_full_exe_name, res, true)
      setup_rake_dependencies(res, object_multitask)

      # check that all source libs are checked even if they are not a real rake dependency (can happen if "build this project only")
      begin
        libChecker = task get_full_exe_name+"LibChecker" do
          if File.exists?(get_full_exe_name) # otherwise the task will be executed anyway
            all_dependencies.each do |bb|
              if bb and SourceLibrary === bb
                f = bb.get_full_archive_name # = abs path of library
                if not File.exists?(f) or File.mtime(f) > File.mtime(get_full_exe_name)
                  def res.needed?
                    true
                  end
                  break
                end
              end
            end
          end
        end
      rescue
        def res.needed?
          true
        end
      end
      libChecker.transparent_timestamp = true
      res.enhance([libChecker])

      task get_task_name => res
      res
    end

    def get_temp_filename
      Dir.tmpdir + "/lake.tmp"
    end

  end
end
