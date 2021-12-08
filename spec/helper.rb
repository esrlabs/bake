module Bake
  def self.ciRunning?
    ENV["CI_RUNNING"] == "YES"
  end
end

module Bake
  def self.coverageRunning?
    ENV["COVERAGE_RUNNING"] == "YES"
  end
end

begin
  if Bake.coverageRunning?
    gem "simplecov", "=0.21.2"
    gem "simplecov-lcov", "=0.8.0"
    gem "rspec",     "=3.10.0"

    require 'simplecov'
    require 'simplecov-lcov'

    SimpleCov::Formatter::LcovFormatter.config do |config|
      config.report_with_single_file = true
      config.single_report_path = 'coverage/lcov.info'
    end

    SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
      SimpleCov::Formatter::HTMLFormatter,
      SimpleCov::Formatter::LcovFormatter
    ])

    SimpleCov.start do
      add_filter 'spec'
    end

  end


rescue LoadError => ex
  puts ex.message
  puts ex.backtrace
end

require 'tempfile'
require 'common/version'
require 'common/cleanup'
require 'tocxx'

module Bake

  def self.clearEnvToolchainSettings
    ENV["BAKE_C_COMPILER"] = nil
    ENV["BAKE_CPP_COMPILER"] = nil
    ENV["BAKE_ASM_COMPILER"] = nil
    ENV["BAKE_ARCHIVER"] = nil
    ENV["BAKE_LINKER"] = nil
    ENV["BAKE_C_FLAGS"] = nil
    ENV["BAKE_CPP_FLAGS"] = nil
    ENV["BAKE_ASM_FLAGS"] = nil
    ENV["BAKE_ARCHIVER_FLAGS"] = nil
    ENV["BAKE_LINKER_FLAGS"] = nil
  end

  def self.startBake(proj, opt)
    begin
      Bake.options = Options.new(["-m", "spec/testdata/#{proj}"].concat(opt))
      Bake.options.parse_options()
      tocxx = Bake::ToCxx.new
      tocxx.doit()
      Bake::cleanup
    rescue Exception
    end
  end

  def self.startBakeWithPath(path, proj, opt)
    Dir.chdir(path) do
      Bake.options = Options.new(["-m", "#{proj}"].concat(opt))
      Bake.options.parse_options()
      tocxx = Bake::ToCxx.new
      tocxx.doit()
      Bake::cleanup
    end
  end

  def self.startBakeWithChangeDir(proj, opt)
    Dir.chdir("spec/testdata/#{proj}") do
      Bake.options = Options.new([].concat(opt))
      Bake.options.parse_options()
      tocxx = Bake::ToCxx.new
      tocxx.doit()
      Bake::cleanup
    end
  end


  def self.clean_testdata()
    if not $noCleanTestData
      [ "spec/testdata/**/test*",
        "spec/testdata/**/.bake",
        "spec/testdata/**/build",
        "spec/testdata/**/build_*",
        "**/.qacdata",
        "**/testQacData",
        "**/*.json",
        "spec/testdata/make/main/obj",
        "spec/testdata/make/main/project",
        "spec/testdata/make/main/project.exe"
      ].each do |gp|
        Dir.glob(gp).each { |f| FileUtils.rm_rf(f) }
      end
    end
  end

  RSpec.configure do |config|

    config.before(:all) do |the_test|
      Bake::clearEnvToolchainSettings
      puts "Testing #{the_test.class}:"
    end
    
    config.after(:all) do |the_test|
      puts "\nDONE"
    end
    
    config.before(:each) do |the_test|
      Bake::cleanup
      Bake::clean_testdata

      
      @backup_stdout = STDOUT.dup
      @backup_stderr = STDERR.dup
      @fstdout = Tempfile.open("captured_stdout")
      @fstderr = Tempfile.open("captured_stderr")
      STDOUT.reopen(@fstdout)
      STDERR.reopen(@fstderr)

      $mystring=""
      $sstring=StringIO.open($mystring,"w+")
      $stdoutbackup=Thread.current[:stdout]
      Thread.current[:stdout]=$sstring
    end

    config.after(:each) do |the_test|
      Thread.current[:stdout]=$stdoutbackup

      @fstdout.rewind; @fstdout.read; @fstdout.close
      @fstderr.rewind; @fstderr.read; @fstderr.close
      STDOUT.reopen @backup_stdout
      STDERR.reopen @backup_stderr

      ExitHelper.reset_exit_code
      Bake::clean_testdata
      if !the_test.instance_variable_get(:@exception).nil?
        puts $mystring
      end
    end

  end

end