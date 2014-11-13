require 'tempfile'


module Bake

class SpecHelper

  def self.clean_testdata_build(name,main,setup)
    r = Dir.glob("spec/testdata/#{name}/#{main}/#{setup}")
    r.each { |f| FileUtils.rm_rf(f) }
    r = Dir.glob("spec/testdata/#{name}/**/.bake")
    r.each { |f| FileUtils.rm_rf(f) }
  end

end

  RSpec.configure do |config|
  
    #your other config
  
    config.before(:each) do
      Utils.cleanup_rake
      
      @backup_stdout = STDOUT.dup
      @backup_stderr = STDERR.dup
      @f1 = Tempfile.open("captured_stdout")
      @f2 = Tempfile.open("captured_stderr")
      STDOUT.reopen(@f1)
      STDERR.reopen(@f2)
      
      $mystring=""
      $sstring=StringIO.open($mystring,"w+")
      $stdoutbackup=$stdout
      $stdout=$sstring
      
      ExitHelper.enable_exit_test
    end
    
    
    
    config.after(:each) do
      $stdout=$stdoutbackup
      
      @f1.rewind
      @f2.rewind
      @f1.read    
      @f2.read    
      @f1.close
      @f2.close
      STDOUT.reopen @backup_stdout
      STDERR.reopen @backup_stderr
      
      ExitHelper.reset_exit_code
    end

    
  end


end