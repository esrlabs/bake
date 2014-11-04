#!/usr/bin/env ruby

$:.unshift(File.dirname(__FILE__)+"/../../cxxproject/lib")

require 'bake/version'

require 'tocxx'
require 'bake/options'
require 'cxxproject/utils/exit_helper'
require 'cxxproject/utils/cleanup'
require 'fileutils'
require 'helper'

module Cxxproject

ExitHelper.enable_exit_test

describe "Multiple root" do
  
  before(:all) do
  end

  after(:all) do
  end

  before(:each) do
    Utils.cleanup_rake
    SpecHelper.clean_testdata_build("root1","main","test")
    SpecHelper.clean_testdata_build("root1","lib1","test_main")
    SpecHelper.clean_testdata_build("root2","lib2","test_main")

    $mystring=""
    $sstring=StringIO.open($mystring,"w+")
    $stdoutbackup=$stdout
    $stdout=$sstring
  end
  
  after(:each) do
    $stdout=$stdoutbackup

    ExitHelper.reset_exit_code
  end

  it 'single root' do
    File.exists?("spec/testdata/root1/main/test/main.exe").should == false
    
    options = Options.new(["-m", "spec/testdata/root1/main", "-b", "test"])
    options.parse_options()
    tocxx = Cxxproject::ToCxx.new(options)
    lambda { tocxx.doit() }.should raise_error(ExitHelperException)
  end
  
  it 'both roots' do
    File.exists?("spec/testdata/root1/main/test/main.exe").should == false
    
    options = Options.new(["-m", "spec/testdata/root1/main", "-b", "test", "-w", "spec/testdata/root1", "-w", "spec/testdata/root2"])
    options.parse_options()
    tocxx = Cxxproject::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    File.exists?("spec/testdata/root1/main/test/main.exe").should == true
  end
  
  it 'root multiple define' do
    File.exists?("spec/testdata/root1/main/test/main.exe").should == false
    
    options = Options.new(["-m", "spec/testdata/root1/main", "-b", "test", "-w", "spec/testdata/root2", "-w", "spec/testdata/root1"])
    options.parse_options()
    tocxx = Cxxproject::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    File.exists?("spec/testdata/root1/main/test/main.exe").should == true
  end
  
  it 'wrong root' do
    File.exists?("spec/testdata/root1/main/test/main.exe").should == false
    
    options = Options.new(["-m", "spec/testdata/root1/main", "-b", "test", "-w", "spec/testdata/root1", "-w", "spec/testdata/root2/lib3"])
    lambda { options.parse_options() }.should raise_error(ExitHelperException)
    
    $mystring.split("lib3 does not exist").length.should == 2
  end  
  
  it 'forgotten root' do
    File.exists?("spec/testdata/root1/main/test/main.exe").should == false
    
    options = Options.new(["-m", "spec/testdata/root1/main", "-b", "test", "-w", "spec/testdata/root1"])
    options.parse_options()
    tocxx = Cxxproject::ToCxx.new(options)
  lambda { tocxx.doit() }.should raise_error(ExitHelperException)
    
    $mystring.split("Error: lib2/Project.meta not found").length.should == 2
  end   
 
  it 'invalid root' do
    File.exists?("spec/testdata/root1/main/test/main.exe").should == false
    
    options = Options.new(["-m", "spec/testdata/root1/main", "-b", "test", "-w", "spec/testdata/GIBTS_DOCH_GAR_NICHT"])
    lambda { options.parse_options() }.should raise_error(ExitHelperException)
    
    $mystring.split("Error: Directory spec/testdata/GIBTS_DOCH_GAR_NICHT does not exist").length.should == 2
  end    

end

end
