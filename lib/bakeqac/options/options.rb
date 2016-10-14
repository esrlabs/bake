require 'bake/toolchain/colorizing_formatter'
require 'common/options/parser'
require 'bake/toolchain/gcc'

module Bake

  class BakeqacOptions < Parser
    attr_reader :rcf, :acf, :qacdata, :qacstep, :qac_home  # String
    attr_reader :c11, :c14, :qacfilter # Boolean
    attr_reader :cct # Array

    def initialize(argv)
      super(argv)

      @cVersion = "-C++"
      @c11 = false
      @acf = nil
      @rcf = nil
      @cct = []
      @default = nil
      @qacdata = "qacdata"
      @qacstep = nil
      @qacfilter = true

      add_option(["-b", ""      ], lambda { |x| setDefault(x)                })
      add_option(["--c++11"     ], lambda {     @cVersion = "-c++11"         })
      add_option(["--c++14"     ], lambda {     @cVersion = "-c++14"         })
      add_option(["--cct"       ], lambda { |x| @cct << x.gsub(/\\/,"/")     })
      add_option(["--rcf"       ], lambda { |x| @rcf = x.gsub(/\\/,"/")      })
      add_option(["--acf"       ], lambda { |x| @acf = x.gsub(/\\/,"/")      })
      add_option(["--qacdata"   ], lambda { |x| @qacdata = x.gsub(/\\/,"/")  })
      add_option(["--qacstep"   ], lambda { |x| @qacstep = x                 })
      add_option(["--qacfilter" ], lambda { |x| @qacfilter = (x == "on")     })
      add_option(["-h", "--help"], lambda {     usage; ExitHelper.exit(0)    })
      add_option(["--version"   ], lambda {     Bake::Version.printBakeqacVersion; ExitHelper.exit(0)    })

    end

    def usage
      puts "\nUsage: bakeqac [options]"
      puts " --c++11          Uses C++11 rules, available for GCC 4.7 and higher."
      puts " --c++14          Uses C++14 rules, available for GCC 4.9 and higher."
      puts " --cct <file>     Sets a specific compiler compatibility template, otherwise $(QAC_HOME)/config/cct/<platform>.ctt will be used. Can be defined multiple times."
      puts " --rcf <file>     Sets a specific rule config file, otherwise $(QAC_RULE) will be used. If not set, $(QAC_HOME)/config/rcf/mcpp-1_5_1-en_US.rcf will be used."
      puts " --acf <file>     Sets a specific analysis config file, otherwise $(QAC_HOME)/config/acf/default.acf will be used."
      puts " --qacdata <dir>  QAC writes data into this folder. Default is <working directory>/qacdata."
      puts " --qacstep create|build|result   Steps can be ORed. Per default all steps will be executed."
      puts " --qacfilter on|off   If off, output will be printed immediately and unfiltered, default is on to reduce noise."
      puts " --version        Print version."
      puts " -h, --help       Print this help."
      puts "Note: all parameters from bake apply also here. Note, that --rebuild and --compily-only will be added to the internal bake call automatically."
      puts "Note: works only for GCC 4.1 and above"
    end

    def setDefault(x)
      if (@default)
        Bake.formatter.printError("Error: '#{x}' not allowed, '#{@default}' already set.")
        ExitHelper.exit(1)
      end
      @default = x
    end

    def parse_options(bakeOptions)
      parse_internal(true, bakeOptions)

      if not ENV["QAC_HOME"]
        Bake.formatter.printError("Error: specify the environment variable QAC_HOME.")
      end

      @qac_home = ENV["QAC_HOME"].gsub(/\\/,"/")
      @qac_home = qac_home[0, qac_home.length-1] if qac_home.end_with?"/"

      if @cct.empty?

        gccVersion = Bake::Toolchain::getGccVersion
        if gccVersion.length < 2
          Bake.formatter.printError("Error: could not determine GCC version.")
          ExitHelper.exit(1)
        end

        if RUBY_PLATFORM =~ /mingw/
          plStr = "w64-mingw32"
        elsif RUBY_PLATFORM =~ /cygwin/
          plStr = "pc-cygwin"
        else
          plStr = "generic-linux"
        end

        while (@cct.empty? or gccVersion[0]>=5)
          @cct = [qac_home + "/config/cct/GNU_GCC-g++_#{gccVersion[0]}.#{gccVersion[1]}-i686-#{plStr}#{@cVersion}.cct"]
          break if File.exist?@cct[0]
          @cct = [qac_home + "/config/cct/GNU_GCC-g++_#{gccVersion[0]}.#{gccVersion[1]}-x86_64-#{plStr}#{@cVersion}.cct"]
          break if File.exist?@cct[0]
          if gccVersion[1]>0
            gccVersion[1] -= 1
          else
            gccVersion[0] -= 1
            gccVersion[1] = 20
          end
        end
      end

      if @acf.nil?
        @acf = qac_home + "/config/acf/default.acf"
      end

      if @rcf.nil?
        if ENV["QAC_RCF"]
          @rcf = ENV["QAC_RCF"].gsub(/\\/,"/")
        else
          @rcf  = qac_home + "/config/rcf/mcpp-1_5_1-en_US.rcf"
        end
      end

    end


  end

end
