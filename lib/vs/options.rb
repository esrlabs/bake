require "common/options/parser"
require "common/options/option"

module Bake

  class VsOptions < Parser
    attr_accessor :version, :roots, :rewriteSolution

    def initialize(argv)
      super(argv)
      
      @version = "2012"
      @rewriteSolution = false
      @roots = []
            
      add_option(Option.new("--version",true)           { |x| set_version(x)            })
      add_option(Option.new("--rewrite_solution",false) {     set_rewrite_solution      })
	    add_option(Option.new("-w",true)                  { |x| set_root(x)               })
      add_option(Option.new("-h",false)                 {     usage; ExitHelper.exit(0) })
    end
    
    def usage
      puts "\nUsage: createVSProjects [options]"
      puts " -w <root>           Add a workspace root. Default is current directory."
	    puts "                     This option can be used at multiple times."
	    puts "                     Solution files will be created in the first root directory."
	    puts " --version <year>    Visual Studio version. Currently supported: 2010 and 2012 (default)."
      puts " --rewrite_solution  Rewrites existing solution files instead of appending new projects."
      puts " -h                  Print this help."
    end
  
    def parse_options()
      parse_internal(false)
      @roots << Dir.pwd if @roots.length == 0
    end
    
    def check_valid_dir(dir)
     if not File.exists?(dir)
        puts "Error: Directory #{dir} does not exist"
        ExitHelper.exit(1)
      end
      if not File.directory?(dir)
        puts "Error: #{dir} is not a directory"
        ExitHelper.exit(1)
      end      
    end    
    
    def set_version(v)
	  if v != "2010" and v != "2012"
	    puts "Error: version must be '2010' or '2012'"
      ExitHelper.exit(1)
	  end
      @version = v
    end
    
    def set_rewrite_solution
      @rewriteSolution = true
    end
    
    def set_root(dir)
      check_valid_dir(dir)
      r = File.expand_path(dir.gsub(/[\\]/,'/'))
      @roots << r if not @roots.include?r
    end
        
  end

end
