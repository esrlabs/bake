require 'tempfile'
require 'imported/utils/cleanup'

module Bake

  def self.clean_testdata()
    r = Dir.glob("spec/testdata/**/test*")
    r.each { |f| FileUtils.rm_rf(f) }
    r = Dir.glob("spec/testdata/**/.bake")
    r.each { |f| FileUtils.rm_rf(f) }
  end

  RSpec.configure do |config|

    config.before(:each) do
      Utils.cleanup_rake
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
      
      ExitHelper.enable_exit_test
    end
    
    config.after(:each) do
      $stdout=$stdoutbackup
      
      @fstdout.rewind; @fstdout.read; @fstdout.close
      @fstderr.rewind; @fstderr.read; @fstderr.close
      STDOUT.reopen @backup_stdout
      STDERR.reopen @backup_stderr
      
      ExitHelper.reset_exit_code
      Bake::clean_testdata      
    end

  end

end