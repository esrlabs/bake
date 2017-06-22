require 'bake/toolchain/colorizing_formatter'
require 'common/options/parser'
require 'bake/toolchain/gcc'
require 'common/options/finder'

module Bake

  class BakeqacOptions < Parser
    attr_reader :rcf, :acf, :qacstep, :qac_home, :cct_append  # String
    attr_reader :c11, :c14, :qacfilter, :qacnoformat, :qacunittest, :qacdoc, :cct_patch # Boolean
    attr_reader :cct # Array
    attr_reader :qacretry # int
    attr_accessor :qacdata # String

    def initialize(argv)
      super(argv)

      @cct_patch = false
      @cct_append = nil
      @main_dir = nil
      @cVersion = ""
      @c11 = false
      @acf = nil
      @rcf = nil
      @cct = []
      @default = nil
      @qacdata = nil
      @qacstep = nil
      @qacfilter = true
      @qacnoformat = false
      @qacunittest = false
      @qacretry = 0
      @qacdoc = false
      @qacdataOrg = nil
      @qacdataCounter = 0

      add_option(["-b", ""                         ], lambda { |x| setDefault(x)                })
      add_option(["-a"                             ], lambda { |x| Bake.formatter.setColorScheme(x.to_sym) })
      add_option(["-m"                             ], lambda { |x| set_main_dir(x)              })
      add_option(["--c++11"                        ], lambda {     @cVersion = "-c++11"         })
      add_option(["--c++14"                        ], lambda {     @cVersion = "-c++14"         })
      add_option(["--cct"                          ], lambda { |x| @cct << x.gsub(/\\/,"/")     })
      add_option(["--rcf"                          ], lambda { |x| @rcf = x.gsub(/\\/,"/")      })
      add_option(["--acf"                          ], lambda { |x| @acf = x.gsub(/\\/,"/")      })
      add_option(["--qaccctpatch"                  ], lambda { @cct_patch = true                })
      add_option(["--qacdata"                      ], lambda { |x| @qacdata = x.gsub(/\\/,"/")  })
      add_option(["--qacstep"                      ], lambda { |x| @qacstep = x                 })
      add_option(["--qacnofilter"                  ], lambda { @qacfilter = false               })
      add_option(["--qacretry"                     ], lambda { |x| @qacretry = x.to_i           })
      add_option(["--qacnoformat", "--qacrawformat"], lambda { @qacnoformat = true              })
      add_option(["--qacunittest"                  ], lambda { @qacunittest = true              })
      add_option(["--qacdoc"                       ], lambda { @qacdoc = true                   })
      add_option(["-h", "--help"                   ], lambda { usage; ExitHelper.exit(0)        })
      add_option(["--version"                      ], lambda { Bake::Version.printBakeqacVersion; ExitHelper.exit(0)    })

    end

    def usage
      puts "\nUsage: bakeqac [options]"
      puts " --c++11          Use C++11 rules, available for GCC 4.7 and higher."
      puts " --c++14          Use C++14 rules, available for GCC 4.9 and higher."
      puts " --cct <file>     Set a specific compiler compatibility template, can be defined multiple times."
      puts "                  If not specified, $(QAC_HOME)/config/cct/<platform>.ctt will be used and additionally"
      puts "                  a file named qac.cct will be searched up to root and also used if found."
      puts " --rcf <file>     Set a specific rule config file. If not specified, $(QAC_HOME)/config/rcf/mcpp-1_5_1-en_US.rcf will be used."
      puts " --acf <file>     Set a specific analysis config file, otherwise $(QAC_HOME)/config/acf/default.acf will be used."
      puts " --qaccctpatch    If specified, some adaptions to cct are made. Might improve the result - no guarantee."
      puts " --qacdata <dir>  QAC writes data into this folder. Default is <working directory>/.qacdata."
      puts " --qacstep admin|analyze|view|report|mdr   Steps can be ORed. Per default admin|analyze|view will be executed."
      puts " --qacnofilter    Output will be printed immediately and unfiltered. Per default filters are used to reduce noise."
      puts " --qacrawformat   Raw QAC output (with incomplete MISRA rules!)."
      puts " --qacretry <seconds>   If build or result step fail due to refused license, the step will be retried until timeout."
      puts " --qacdoc         Print link to HTML help page for every warning if found."
      puts " --version        Print version."
      puts " -h, --help       Print this help."
      puts "Note: all parameters from bake apply also here. Note, that --rebuild and --compile-only will be added to the internal bake call automatically."
      puts "Note: works only for GCC 4.1 and above"
    end

    def setDefault(x)
      if (@default)
        Bake.formatter.printError("Error: '#{x}' not allowed, '#{@default}' already set.")
        ExitHelper.exit(1)
      end
      @default = x
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

    def set_main_dir(dir)
      check_valid_dir(dir)
      @main_dir = File.expand_path(dir.gsub(/[\\]/,'/'))
    end

    def searchCctFile(dir)
      cctFile = dir+"/qac.cct"
      return cctFile if File.exist?(cctFile)

      parent = File.dirname(dir)
      return searchCctFile(parent) if parent != dir

      return nil
    end

    def incrementQacdata()
      if @qacdataCounter > 0
        FileUtils::rm_rf(@qacdata)
      end
      @qacdataCounter = @qacdataCounter + 1
      @qacdata = @qacdataOrg + "/run" + @qacdataCounter.to_s
    end

    def parse_options(bakeOptions)
      parse_internal(true, bakeOptions)

      searchDir = @main_dir.nil? ? Dir.pwd : @main_dir
      dir = Bake.findDirOfFileToRoot(searchDir,"Project.meta")
      if dir
        set_main_dir(dir)
      else
        Bake.formatter.printError("Error: Project.meta not found in #{searchDir} or upwards")
        ExitHelper.exit(1)
      end

      @qacdata = "#{@main_dir}/.qacdata" if @qacdata.nil?
      @qacdataOrg = @qacdata
      @qacdataCounter = 0
      incrementQacdata()

      if !ENV["QAC_HOME"] || ENV["QAC_HOME"].empty?
        Bake.formatter.printError("Error: specify the environment variable QAC_HOME.")
        ExitHelper.exit(1)
      end

      if !@qacstep.nil?
        @qacstep.split("|").each do |s|
          if not ["admin", "analyze", "view", "report", "mdr"].include?s
            Bake.formatter.printError("Error: incorrect qacstep name.")
            ExitHelper.exit(1)
          end
        end
      end

      @qac_home = ENV["QAC_HOME"].gsub(/\\/,"/")
      @qac_home = qac_home[0, qac_home.length-1] if qac_home.end_with?"/"

      if @cct.empty?
        gccVersion = Bake::Toolchain::getGccVersion
        if gccVersion.length < 2
          Bake.formatter.printError("Error: could not determine GCC version.")
          ExitHelper.exit(1)
        end

        plStr = nil
        gccPlatform = Bake::Toolchain::getGccPlatform
        if gccPlatform.include?"mingw"
          plStr = "w64-mingw32"
        elsif gccPlatform.include?"cygwin"
          plStr = "pc-cygwin"
        elsif gccPlatform.include?"linux"
          plStr = "generic-linux"
        end

        if plStr.nil? # fallback
          if RUBY_PLATFORM =~ /mingw/
            plStr = "w64-mingw32"
          elsif RUBY_PLATFORM =~ /cygwin/
            plStr = "pc-cygwin"
          else
            plStr = "generic-linux"
          end
        end

        while (@cct.empty? or gccVersion[0]>=4)
          @cct = [qac_home + "/config/cct/GNU_GCC-g++_#{gccVersion[0]}.#{gccVersion[1]}-i686-#{plStr}-C++#{@cVersion}.cct"]
          break if File.exist?@cct[0]
          @cct = [qac_home + "/config/cct/GNU_GCC-g++_#{gccVersion[0]}.#{gccVersion[1]}-x86_64-#{plStr}-C++#{@cVersion}.cct"]
          break if File.exist?@cct[0]
          if gccVersion[1]>0
            gccVersion[1] -= 1
          else
            gccVersion[0] -= 1
            gccVersion[1] = 20
          end
        end
      end

      cctInDir = searchCctFile(@main_dir)
      @cct_append = cctInDir.gsub(/[\\]/,'/') if cctInDir

      if @acf.nil?
        @acf = qac_home + "/config/acf/default.acf"
      end

      if @rcf.nil?
        @rcf  = qac_home + "/config/rcf/mcpp-1_5_1-en_US.rcf"
      end

    end


  end

end
