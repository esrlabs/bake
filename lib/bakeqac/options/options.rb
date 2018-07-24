require_relative '../../bake/toolchain/colorizing_formatter'
require_relative '../../common/options/parser'
require_relative '../../bake/toolchain/gcc'
require_relative '../../common/options/finder'

module Bake

  class BakeqacOptions < Parser
    attr_reader :rcf, :acf, :qacstep, :qac_home, :mcpp_home, :cct_append  # String
    attr_reader :c11, :c14, :qacmsgfilter, :qacfilefilter, :qacnoformat, :qacunittest, :qacdoc, :cct_patch, :qacverbose # Boolean
    attr_reader :cct # Array
    attr_reader :qacretry # int
    attr_accessor :qacdata # String

    RCF_DEFAULT = "config/rcf/mcpp-*-en_US.rcf".freeze()

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
      @qacverbose = false
      @qacstep = nil
      @qacmsgfilter = true
      @qacfilefilter = true
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
      add_option(["--qacnofilter"                  ], lambda { @qacfilefilter = false; @qacmsgfilter = false }) # backward compatibility
      add_option(["--qacnofilefilter"              ], lambda { @qacfilefilter = false           })
      add_option(["--qacnomsgfilter"               ], lambda { @qacmsgfilter = false            })
      add_option(["--qacretry"                     ], lambda { |x| @qacretry = x.to_i           })
      add_option(["--qacnoformat", "--qacrawformat"], lambda { @qacnoformat = true              })
      add_option(["--qacunittest"                  ], lambda { @qacunittest = true              })
      add_option(["--qacdoc"                       ], lambda { @qacdoc = true                   })
      add_option(["--qacverbose"                   ], lambda { @qacverbose = true               })
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
      puts " --rcf <file>     Set a specific rule config file. If not specified, $(MCPP_HOME)/#{RCF_DEFAULT} will be used."
      puts " --acf <file>     Set a specific analysis config file, otherwise $(QAC_HOME)/config/acf/default.acf will be used."
      puts " --qaccctpatch    If specified, some adaptions to cct are made. Might improve the result - no guarantee."
      puts " --qacdata <dir>  QAC writes data into this folder. Default is <working directory>/.qacdata."
      puts " --qacstep <steps> Can be admin,analyze,view,report,mdr (separated by \",\" without spaces)."
      puts "                  Defines the steps to execute, see documentation. Default: admin,analyze,view"
      puts " --qacnofilefilter Some files will be filtered per default, like /test/."
      puts " --qacnomsgfilter  Some messages will be filter per default filters to reduce noise."
      puts " --qacrawformat   Raw QAC output (with incomplete MISRA rules!)."
      puts " --qacretry <seconds>   If build or result step fail due to refused license, the step will be retried until timeout."
      puts " --qacdoc         Print link to HTML help page for every warning if found."
      puts " --qacverbose     Verbose output of bakeqac."
      puts " --version        Print version."
      puts " -h, --help       Print this help."
      puts "Note: all parameters from bake apply also here. Note, that --rebuild and --compile-only will be added to the internal bake call automatically."
      puts "Note: works only for GCC 4.1 and above"
    end

    def checkNum(num)
      if String === num && !/\A\d+\z/.match(num)
        Bake.formatter.printError("Error: #{num} is not a positive number")
        ExitHelper.exit(1)
      end
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
      @qac_home = ENV["QAC_HOME"].gsub(/\\/,"/")
      @qac_home = @qac_home[0, @qac_home.length-1] if @qac_home.end_with?"/"
      if !File.directory?(@qac_home)
        Bake.formatter.printError("Error: QAC_HOME points to invalid directory.")
        ExitHelper.exit(1)
      end

      # find mcpp install folder
      # prio 1: explicit env var
      if ENV["MCPP_HOME"] && !ENV["MCPP_HOME"].empty?
        @mcpp_home = ENV["MCPP_HOME"].gsub(/\\/,"/")
        @mcpp_home = @mcpp_home[0, @mcpp_home.length-1] if @mcpp_home.end_with?"/"
        if !File.directory?(@mcpp_home)
          Bake.formatter.printError("Error: MCPP_HOME points to invalid directory: #{@mcpp_home}")
          ExitHelper.exit(1)
        end
      # prio 2: with qac_home
      elsif !(mcps = Dir.glob(@qac_home+"/#{RCF_DEFAULT}")).empty?
        @mcpp_home = @qac_home
      # prio 3: next to qac_home
      elsif !(mcps = Dir.glob(File.dirname(@qac_home)+"/mcpp-*/")).empty?
        @mcpp_home = mcps.sort.last[0..-2]
      else
        Bake.formatter.printError("Error: cannot find MCPP home folder. Specify MCPP_HOME.")
        ExitHelper.exit(1)
      end

      if !@qacstep.nil?
        @qacstep.split(/[,|]/).each do |s|
          if not ["admin", "analyze", "view", "report", "mdr"].include?s
            Bake.formatter.printError("Error: incorrect qacstep name.")
            ExitHelper.exit(1)
          end
        end
      end

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
          @cct = [@qac_home + "/config/cct/GNU_GCC-g++_#{gccVersion[0]}.#{gccVersion[1]}-i686-#{plStr}-C++#{@cVersion}.cct"]
          break if File.exist?@cct[0]
          @cct = [@qac_home + "/config/cct/GNU_GCC-g++_#{gccVersion[0]}.#{gccVersion[1]}-x86_64-#{plStr}-C++#{@cVersion}.cct"]
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
        @acf = @qac_home + "/config/acf/default.acf"
      end

      if @rcf.nil?
        rcfs = Dir.glob(@mcpp_home+"/#{RCF_DEFAULT}")
        if rcfs.empty?
          Bake.formatter.printError("Error: rcf file not found: #{@mcpp_home+"/#{RCF_DEFAULT}"}")
          ExitHelper.exit(1)
        end
        @rcf  = rcfs.sort.last
      end

      @cct.each do |cct|
        if !File.exists?(cct)
          Bake.formatter.printError("Error: cct file not found: #{cct}")
          ExitHelper.exit(1)
        end
      end
      if !File.exists?(@acf)
        Bake.formatter.printError("Error: acf file not found: #{@acf}")
        ExitHelper.exit(1)
      end
      if !File.exists?(@rcf)
        Bake.formatter.printError("Error: rcf file not found: #{@rcf}")
        ExitHelper.exit(1)
      end

    end


  end

end
