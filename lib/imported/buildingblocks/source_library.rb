require 'imported/buildingblocks/building_block'
require 'imported/buildingblocks/has_libraries_mixin'
require 'imported/buildingblocks/has_sources_mixin'
require 'imported/buildingblocks/has_includes_mixin'
require 'imported/utils/process'
require 'imported/utils/utils'

module Bake
  class SourceLibrary < BuildingBlock
    include HasLibraries
    include HasSources
    include HasIncludes

    def complete_init()
      add_lib_element(HasLibraries::LIB_WITH_PATH, get_archive_name, true)
      super
    end

    def get_archive_name() # relative path
      @archive_name ||= File.join([@output_dir_relPath, "lib#{@project_name}.a"])
    end

    def get_full_archive_name()
      @archive_name_full ||= File.join([@output_dir, "lib#{@project_name}.a"])
    end

    def get_task_name()
      @task_name ||= "MAIN "+@project_name+","+@config_name
    end
    
    # task that will link the given object files to a static lib
    #
    def convert_to_rake()
      object_multitask = prepare_tasks_for_objects()
      archiver = @tcs[:ARCHIVER]

      res = typed_file_task Rake::Task::LIBRARY, get_full_archive_name => object_multitask do
        dir = @project_dir
        objs = @objects
        aname = get_archive_name
        
        if (objs.length != 0 or not File.exist?(get_full_archive_name))
          Dir.chdir(dir) do
            if File.exists?(aname)
              FileUtils.rm(aname)
            else 
              d = File.dirname(aname)
              FileUtils.mkdir_p(d)
            end
            
            cmd = [archiver[:COMMAND]] # ar
            cmd += Bake::Utils::flagSplit(archiver[:FLAGS],true) # --all_load
            cmd += archiver[:ARCHIVE_FLAGS].split(" ")
            cmd << aname
            cmd += objs
  
            if Bake::Utils.old_ruby?
              cmd.map! {|c| ((c.include?" ") ? ("\""+c+"\"") : c )}
  
              cmdLine = cmd.join(" ")
              if cmdLine.length > 8000
                inputName = aname+".tmp"
                File.open(inputName,"wb") { |f| f.write(cmd[1..-1].join(" ")) }
                success, consoleOutput = ProcessHelper.safeExecute() { `#{archiver[:COMMAND] + " @" + inputName}` }
              else
                success, consoleOutput = ProcessHelper.safeExecute() { `#{cmd.join(" ")} 2>&1` }
              end
            else
              rd, wr = IO.pipe
              cmd << {
               :err=>wr,
               :out=>wr
              }
              success, consoleOutput = ProcessHelper.safeExecute() { sp = spawn(*cmd); ProcessHelper.readOutput(sp, rd, wr) }
              cmd.pop
            end
  
            process_result(cmd, consoleOutput, archiver[:ERROR_PARSER], "Creating #{aname}", success)
  
            check_config_file()
          end
        end
      end
      enhance_with_additional_files(res)
      
      if not Rake.application["clean"].prerequisites.include?(get_full_archive_name+"Clean")
        cleanTask = task get_full_archive_name+"Clean" do
          Dir.chdir(@project_dir) do 
            if (calc_sources_to_build(true).length != 0 or not File.exist?(get_full_archive_name))
              FileUtils.rm_rf(@output_dir)
            end
          end
        end        
        
        Rake.application["clean"].enhance([cleanTask])
      end
      
      setup_rake_dependencies(res, object_multitask)
      task get_task_name => res
    end

  end
end
