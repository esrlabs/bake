require 'imported/buildingblocks/building_block'
require 'imported/buildingblocks/has_libraries_mixin'
require 'bake/toolchain/colorizing_formatter'
require 'imported/utils/process'

module Bake
  class Makefile < BuildingBlock
    include HasLibraries

    def set_target(x)
      @target = x
      self
    end

    def set_flags(x)
      @flags = x
      self
    end

    def get_flags(x)
      @flags
    end


    def set_makefile(x)
      @makefile = x
      self
    end

    def set_path_to(hash)
      @path_to = hash
      self
    end

    def get_makefile
      @makefile
    end

    def get_target
      @target
    end

    def initialize(mfile, mtarget, projetName, configName)
      @target = mtarget != "" ? mtarget : "all"
      @makefile = mfile
      @flags = ""
      @path_to = {}
      @num = Rake.application.makefile_number
      super(projetName, configName)
    end

    def get_task_name()
      @task_name ||= "makefile (#{@num}): " + get_makefile + (get_target ? ("_"+get_target) : "")
    end

    def calc_pathes_to_projects
      vars = []
      @path_to.each do |k,v|
        vars << "PATH_TO_#{k}=#{v}"
      end
      vars.join(" ")
    end

    def executeCmd(cmd)
        Dir.chdir(@project_dir) do
          check_config_file
          puts cmd + (Bake.options.verboseHigh ? "\n(executed in '#{@project_dir}')" : "")
          cmd_result = false
          begin
            cmd_result = ProcessHelper.spawnProcess(cmd + " 2>&1")
          rescue
          end
          if (cmd_result == false)
            if Rake.application.idei
              err_res = ErrorDesc.new
              err_res.file_name = @project_dir + "/" + get_makefile()
              err_res.line_number = 1
              err_res.severity = ErrorParser::SEVERITY_ERROR
              if get_target != ""
                err_res.message = "Target \"#{get_target}\" failed"
              else
                err_res.message = "Failed"
              end
              Rake.application.idei.set_errors([err_res])
            end
            Bake.formatter.printError "Error: command \"#{cmd}\" failed" + (Bake.options.verboseHigh ? "" : "\n(executed in '#{@project_dir}')")
            raise SystemCommandFailed.new
          end
        end
    end

    def convert_to_rake()
      pathes_to_projects = calc_pathes_to_projects

      mfile = get_makefile()
      make = @tcs[:MAKE]
      cmd = remove_empty_strings_and_join([
        make[:COMMAND], # make
        get_target, # all
        make[:MAKE_FLAGS],
        @flags, # -j
        make[:DIR_FLAG], # -C
        File.dirname(mfile), # x/y
        make[:FILE_FLAG], # -f
        File.basename(mfile), # x/y/makefile
        pathes_to_projects
      ])

      mfileTask = task get_task_name do
        executeCmd(cmd)
      end

      mfileTask.immediate_output = true
      mfileTask.transparent_timestamp = true
      mfileTask.type = Rake::Task::MAKE
      mfileTask.enhance(@config_files)

      create_clean_task(@project_dir+"/"+mfile, pathes_to_projects)
      setup_rake_dependencies(mfileTask)
      mfileTask
    end

    def create_clean_task(mfile, pathes_to_projects)
      # generate the clean task
      if not Rake.application["clean"].prerequisites.include?(mfile+"Clean")
        cmd = remove_empty_strings_and_join([@tcs[:MAKE][:COMMAND], # make
          @tcs[:MAKE][:CLEAN], # clean
          @tcs[:MAKE][:DIR_FLAG], # -C
          File.dirname(mfile), # x/y
          @tcs[:MAKE][:FILE_FLAG], # -f
          File.basename(mfile), # x/y/makefile
          pathes_to_projects
        ])
        mfileCleanTask = task mfile+"Clean" do
          executeCmd(cmd)
        end
        mfileCleanTask.immediate_output = true
        Rake.application["clean"].enhance([mfileCleanTask])
      end
    end

  end
end
