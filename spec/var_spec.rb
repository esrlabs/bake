#!/usr/bin/env ruby



require 'bake/version'

require 'tocxx'
require 'bake/options'
require 'imported/utils/exit_helper'
require 'socket'
require 'imported/utils/cleanup'
require 'fileutils'
require 'helper'

module Bake

ExitHelper.enable_exit_test

describe "VarSubst" do
  
  after(:all) do
    ExitHelper.reset_exit_code
  end

  before(:each) do
    Utils.cleanup_rake
    $mystring=""
    $sstring=StringIO.open($mystring,"w+")
    $stdoutbackup=$stdout
    $stdout=$sstring
  end
  after(:each) do
    $stdout=$stdoutbackup
  end

  it 'vars should be substed' do
  
    options = Options.new(["-m", "spec/testdata/cache/main", "-b", "test", "--include_filter", "var"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
  
    ($mystring.include?"MainConfigName_lib1 test").should == true
    ($mystring.include?"MainConfigName_main test").should == true
    
    ($mystring.include?"MainProjectName_lib1 main").should == true
    ($mystring.include?"MainProjectName_main main").should == true

    ($mystring.include?"ProjectName_lib1 lib1").should == true
    ($mystring.include?"ProjectName_main main").should == true

    ($mystring.include?"ConfigName_lib1 subtest").should == true
    ($mystring.include?"ConfigName_main test").should == true

    ($mystring.include?"OutputDir_lib1 test_main").should == true
    ($mystring.include?"OutputDir_main test").should == true

    ($mystring.include?"ArtifactName_lib1 \n").should == true
    ($mystring.include?"ArtifactName_main main.exe").should == true

    ($mystring.include?"ArtifactNameBase_lib1 \n").should == true
    ($mystring.include?"ArtifactNameBase_main main").should == true

    if RUBY_VERSION[0..2] == "1.9" 
      ($mystring.include?"Time_lib1").should == true
      ($mystring.include?"Time_main").should == true
    end
    
    ($mystring.include?"Hostname_lib1 ").should == true
    ($mystring.include?"Hostname_main ").should == true
    ($mystring.include?"Hostname_lib1 \n").should == false
    ($mystring.include?"Hostname_main \n").should == false

    ($mystring.include?"Path_lib1 ").should == true
    ($mystring.include?"Path_main ").should == true
    ($mystring.include?"Path_lib1 \n").should == false
    ($mystring.include?"Path_main \n").should == false

    ($mystring.include?"MAINV1main").should == true
    ($mystring.include?"MAINV2main").should == true
    
    ($mystring.include?"LIBV1lib").should == true
    ($mystring.include?"LIBV2main").should == true
    ($mystring.include?"LIBV3lib").should == true
  
    ($mystring.include?"LIBV1main").should == false
    ($mystring.include?"LIBV3main").should == false
  end

  it 'artifactname' do

    options = Options.new(["-m", "spec/testdata/cache/main", "-b", "test2", "--include_filter", "var"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
  
    ($mystring.include?"ArtifactName_main abc.def").should == true
    ($mystring.include?"ArtifactNameBase_main abc").should == true
  end  

  
end

end
