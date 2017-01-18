require 'bake/toolchain/colorizing_formatter'
require 'common/options/parser'
require 'common/options/finder'

module Bake

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
      @def_roots = []

      add_option(["-b", ""      ], lambda { |x| set_collection_name(x)                  })
      add_option(["-m"          ], lambda { |x| set_collection_dir(x)                   })
      add_option(["-r"          ], lambda {     @error = true                           })
      add_option(["-a"          ], lambda { |x| Bake.formatter.setColorScheme(x.to_sym) })
      add_option(["-w"          ], lambda { |x| set_root(x)                             })
      add_option(["--socket"    ], lambda { |x| @socket = String === x ? x.to_i : x     })
      add_option(["-h", "--help"], lambda {     usage; ExitHelper.exit(0)               })
    end

    def usage
      puts "\nUsage: bake <name> [options]"
      puts " [-b] <name>     Name of the collection to build."
      puts " -m <dir>        Directory containing the collection file (default is current directory)."
      puts " -r              Stop on first error."
      puts " -a <scheme>     Use ansi color sequences (console must support it). Possible values are 'white' and 'black'."
      puts " -h, --help      Print this help."
      puts " -w <root>       Add a workspace root (can be used multiple times)."
      puts "                 If no root is specified, the parent directory of Collection.meta is added automatically."
      puts " --socket <num>  Set socket for sending errors, receiving commands, etc. - used by e.g. Eclipse."
      puts "Note: all parameters except -b, -m and -h will be passed to bake - see bake help for more options."
    end

    def parse_options(bakeOptions)
      parse_internal(true, bakeOptions)

      searchDir = @collection_dir.nil? ? Dir.pwd : @collection_dir
      dir = Bake.findDirOfFileToRoot(searchDir,"Collection.meta")
      if dir
        set_collection_dir(dir)
      else
        Bake.formatter.printError("Error: Collection.meta not found in #{searchDir} or upwards")
        ExitHelper.exit(1)
      end

      @roots += @def_roots
      @roots.uniq!
    end

    def check_valid_dir(dir)
     if not File.exists?(dir)
        Bake.formatter.printError("Error: Directory #{dir} does not exist")
        ExitHelper.exit(1)
      end
      if not File.directory?(dir)
        Bake.formatter.printError("Error: #{dir} is not a directory")
        ExitHelper.exit(1)
      end
    end

    def set_collection_name(collection_name)
      if not @collection_name.empty?
        Bake.formatter.printError("Error: Cannot set collection name '#{collection_name}', because collection name is already set to '#{@collection_name}'")
        ExitHelper.exit(1)
      end
      @collection_name = collection_name
    end

    def set_collection_dir(dir)
      check_valid_dir(dir)
      @collection_dir = File.expand_path(dir.gsub(/[\\]/,'/'))
      @def_roots = calc_def_roots(@collection_dir)
    end

    def set_root(dir)
      check_valid_dir(dir)
      r = File.expand_path(dir.gsub(/[\\]/,'/'))
      @roots << r if not @roots.include?r
    end


  end

end
