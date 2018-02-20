module Bake
  def self.ciRunning?
    ENV["CI_RUNNING"] == "YES"
  end
end

begin
  if Bake.ciRunning?
    require 'simplecov'
    require 'coveralls'
    SimpleCov.start do
      add_filter 'spec'
    end
    Coveralls.wear_merged!
  end
rescue LoadError
end

require 'tempfile'
require 'common/cleanup'
require 'tocxx'

module Bake

  $endReached = false

  def self.startBake(proj, opt)
    Bake.options = Options.new(["-m", "spec/testdata/#{proj}"].concat(opt))
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    Bake::cleanup
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
      r = Dir.glob("spec/testdata/**/test*")
      r.each { |f| FileUtils.rm_rf(f) }
      r = Dir.glob("spec/testdata/**/.bake")
      r.each { |f| FileUtils.rm_rf(f) }
      r = Dir.glob("spec/testdata/**/build")
      r.each { |f| FileUtils.rm_rf(f) }
      r = Dir.glob("spec/testdata/**/build_*")
      r.each { |f| FileUtils.rm_rf(f) }
      r = Dir.glob("spec/testdata/**/*.json")
      r.each { |f| FileUtils.rm_rf(f) }
      r = Dir.glob("**/.qacdata")
      r.each { |f| FileUtils.rm_rf(f) }
      r = Dir.glob("**/testQacData")
      r.each { |f| FileUtils.rm_rf(f) }

      FileUtils.rm_rf("spec/testdata/make/main/obj")
      FileUtils.rm_rf("spec/testdata/make/main/project")
      FileUtils.rm_rf("spec/testdata/make/main/project.exe")
    end
  end

  RSpec.configure do |config|

    config.before(:each) do
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

    config.after(:each) do
      Thread.current[:stdout]=$stdoutbackup

      @fstdout.rewind; @fstdout.read; @fstdout.close
      @fstderr.rewind; @fstderr.read; @fstderr.close
      STDOUT.reopen @backup_stdout
      STDERR.reopen @backup_stderr

      ExitHelper.reset_exit_code
      Bake::clean_testdata
      if ($endReached)
        print $mystring
      else
        puts $mystring
      end
    end

  end

end