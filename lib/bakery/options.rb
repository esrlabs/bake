require 'cxxproject/utils/printer'
require "cxxproject/toolchain/colorizing_formatter"
require "option/parser"

module Cxxproject

  class BakeryOptions < Parser
    attr_reader :collection_name, :collection_dir # String
    attr_reader :roots # String List
    attr_reader :color, :error # Boolean
    attr_reader :socket # Fixnum

    def initialize(argv)
      super(argv)
      
      @collection_name = ""
      @collection_dir = nil      
      @color = nil
      @error = false
      @roots = []
      @socket = 0
      @def_root = nil
            
      add_option(Option.new("-b",true)        { |x| set_collection_name(x)     })
      add_option(Option.new("-m",true)        { |x| set_collection_dir(x)     })
      add_option(Option.new("-r",false)       {     set_error                 })
      add_option(Option.new("-a",true)        { |x| set_color(x)              })
      add_option(Option.new("-w",true)        { |x| set_root(x)               })
      add_option(Option.new("--socket",true)  { |x| set_socket(x)             })
      add_option(Option.new("-h",false)       {     usage; ExitHelper.exit(0) })
    end
    
    def usage
      puts "\nUsage: bake <name> [options]"
      puts " -b <name>         Name of the collection to build."
      puts " -m <dir>          Directory containing the collection file (default is current directory)."
      puts " -r                Stop on first error."
      puts " -a <scheme>       Use ansi color sequences (console must support it). Possible values are 'white' and 'black'."
      puts " -h                Print this help."
      puts " -w <root>         Add a workspace root (can be used multiple times)."
      puts "                   If no root is specified, the parent directory of Collection.meta is added automatically."
      puts " --socket <num>    Set socket for sending errors, receiving commands, etc. - used by e.g. Eclipse."
      puts "Note: all parameters except -b, -p and -h will be passed to bake - see bake help for more options." 
    end
  
    def parse_options()
      parse_internal(true)
      set_collection_dir(Dir.pwd) if @collection_dir.nil?
      @roots << @def_root if @roots.length == 0
    end
    
    def check_valid_dir(dir)
     if not File.exists?(dir)
        Printer.printError "Error: Directory #{dir} does not exist"
        ExitHelper.exit(1)
      end
      if not File.directory?(dir)
        Printer.printError "Error: #{dir} is not a directory"
        ExitHelper.exit(1)
      end      
    end    
    
    def set_collection_name(collection_name)
      if not @collection_name.empty?
        Printer.printError "Error: Cannot set collection name '#{collection_name}', because collection name is already set to '#{@collection_name}'"
        ExitHelper.exit(1)
      end      
      @collection_name = collection_name
    end
    
    def set_collection_dir(dir)
      check_valid_dir(dir)
      @collection_dir = File.expand_path(dir.gsub(/[\\]/,'/'))
      @def_root = File.dirname(@collection_dir)
    end
    
    def set_color(x)
      if (x != "black" and x != "white")
        Printer.printError "Error: color scheme must be 'black' or 'white'"
        ExitHelper.exit(1)
      end      
      @color = x
      ColorizingFormatter.enabled = true
      ColorizingFormatter::setColorScheme(x.to_sym)
    end    
    def set_error()
      @error = true
    end

    def set_root(dir)
      check_valid_dir(dir)
      r = File.expand_path(dir.gsub(/[\\]/,'/'))
      @roots << r if not @roots.include?r
    end
        
    def set_socket(num)
      @socket = String === num ? num.to_i : num
    end  
  
  end

end
