require 'tempfile'
require 'common/cleanup'
require 'tocxx'

module Bake

  def self.startBake(proj, opt)
    Bake.options = Options.new(["-m", "spec/testdata/#{proj}"].concat(opt))
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    Bake::cleanup
  end  

  
  def self.clean_testdata()
    if not $noCleanTestData
      r = Dir.glob("spec/testdata/**/test*")
      r.each { |f| FileUtils.rm_rf(f) }
      r = Dir.glob("spec/testdata/**/.bake")
      r.each { |f| FileUtils.rm_rf(f) }
      r = Dir.glob("spec/testdata/**/build_*")
      r.each { |f| FileUtils.rm_rf(f) }
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
      $stdoutbackup=$stdout
      $stdout=$sstring
    end
    
    config.after(:each) do
      $stdout=$stdoutbackup
      
      @fstdout.rewind; @fstdout.read; @fstdout.close
      @fstderr.rewind; @fstderr.read; @fstderr.close
      STDOUT.reopen @backup_stdout
      STDERR.reopen @backup_stderr
      
      ExitHelper.reset_exit_code
      Bake::clean_testdata
      
      #puts $mystring      
    end

  end

end