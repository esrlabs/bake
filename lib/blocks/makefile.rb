require 'blocks/has_execute_command'

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
        @projectDir = config.parent.parent.parent.get_project_dir
        @path_to = []
        @flags = adjustFlags("",config.flags) if config.flags # TODO: CHANGE SYNTAX
        @makefile = config.name
        @target = config.target != "" ? config.target : "all"
        calcPathTo(referencedConfigs)
        calcCommandLine
        calcCleanLine

        # TODO
        block.lib_elements[config.line_number] = [Block::LIB_WITH_PATH, config.lib] if config.lib != ""
      end
      
      def calcCommandLine
        @commandLine = remove_empty_strings_and_join([
          MAKE_COMMAND, @target,
          @flags,
          MAKE_DIR_FLAG,  File.dirname(@makefile),
          MAKE_FILE_FLAG, File.basename(@makefile),
          @path_to])        
      end
      
      def calcCleanLine
        @cleanLine = remove_empty_strings_and_join([
          MAKE_COMMAND, MAKE_CLEAN, 
          MAKE_DIR_FLAG,  File.dirname(@makefile),
          MAKE_FILE_FLAG, File.basename(@makefile),
          @path_to]) 
      end      
      
      def calcPathTo(referencedConfigs)
     
        if config.pathTo != ""
          pathHash = {}
          config.pathTo.split(",").each do |p|
            nameOfP = p.strip
            dirOfP = nil
            if referencedConfigs.include?nameOfP
              dirOfP = referencedConfigs[nameOfP].first.parent.get_project_dir
            else
              Bake.options.roots.each do |r|
                absIncDir = r+"/"+nameOfP
                if File.exists?(absIncDir)
                  dirOfP = absIncDir
                  break
                end
              end
            end
            if dirOfP == nil
              Bake.formatter.printError "Error: Project '#{nameOfP}' not found for makefile #{@projectDir}/#{config.name}"
              ExitHelper.exit(1)
            end
            pathHash[nameOfP] = File.rel_from_to_project(File.dirname(@projectDir),File.dirname(dirOfP))
          end
        end
        
        @path_to = []
        pathHash.each { |k,v| @path_to << "PATH_TO_#{k}=#{v}" }
        @path_to.join(" ")
      end
      
    end
        
    def execute
      executeCommand(@commandLine)
     end
    
    def clean
      executeCommand(@cleanLine)
    end
    
  end
end
