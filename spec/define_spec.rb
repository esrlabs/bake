#!/usr/bin/env ruby

$:.unshift(File.dirname(__FILE__)+"/../../cxxproject.git/lib")

require 'bake/version'

require 'tocxx'
require 'bake/options'
require 'cxxproject/utils/exit_helper'
require 'cxxproject/utils/cleanup'
require 'fileutils'
require 'helper'

module Cxxproject

ExitHelper.enable_exit_test

def self.cleanMergeOutput()
  SpecHelper.clean_testdata_build("define","main","Main")
end

describe "Define filter" do
  
  before(:all) do
    Cxxproject::cleanMergeOutput()
  end

  after(:all) do
    Cxxproject::cleanMergeOutput()
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
    ExitHelper.reset_exit_code
  end

  it 'no filter' do
    options = Options.new(["-m", "spec/testdata/define/main", "Main", "--rebuild"])
    options.parse_options()
    tocxx = Cxxproject::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    $mystring.include?("GAGA").should == false
    $mystring.include?("GUGU").should == true
    $mystring.include?("GOGO").should == true
  end    

  it 'gaga' do
    options = Options.new(["-m", "spec/testdata/define/main", "Main", "--rebuild", "--include_filter", "gaga"])
    options.parse_options()
    tocxx = Cxxproject::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    $mystring.include?("GAGA").should == true
    $mystring.include?("GUGU").should == true
    $mystring.include?("GOGO").should == true
  end    
  
  it 'gugu' do
    options = Options.new(["-m", "spec/testdata/define/main", "Main", "--rebuild", "--include_filter", "gugu"])
    options.parse_options()
    tocxx = Cxxproject::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    $mystring.include?("GAGA").should == false
    $mystring.include?("GUGU").should == true
    $mystring.include?("GOGO").should == true
  end    

  it 'gogo' do
    options = Options.new(["-m", "spec/testdata/define/main", "Main", "--rebuild", "--include_filter", "gogo"])
    options.parse_options()
    tocxx = Cxxproject::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    $mystring.include?("GAGA").should == false
    $mystring.include?("GUGU").should == true
    $mystring.include?("GOGO").should == true
  end    

    
  it 'no gaga' do
    options = Options.new(["-m", "spec/testdata/define/main", "Main", "--rebuild", "--exclude_filter", "gaga"])
    options.parse_options()
    tocxx = Cxxproject::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    $mystring.include?("GAGA").should == false
    $mystring.include?("GUGU").should == true
    $mystring.include?("GOGO").should == true
  end    
  
  it 'no gugu' do
    options = Options.new(["-m", "spec/testdata/define/main", "Main", "--rebuild", "--exclude_filter", "gugu"])
    options.parse_options()
    tocxx = Cxxproject::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    $mystring.include?("GAGA").should == false
    $mystring.include?("GUGU").should == false
    $mystring.include?("GOGO").should == true
  end    

  it 'no gogo' do
    options = Options.new(["-m", "spec/testdata/define/main", "Main", "--rebuild", "--exclude_filter", "gogo"])
    options.parse_options()
    tocxx = Cxxproject::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    $mystring.include?("GAGA").should == false
    $mystring.include?("GUGU").should == true
    $mystring.include?("GOGO").should == false
  end    
  
  it 'no rebuild' do
    options = Options.new(["-m", "spec/testdata/define/main", "Main"])
    options.parse_options()
    tocxx = Cxxproject::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    $mystring.include?("GAGA").should == false
    $mystring.include?("GUGU").should == true
    $mystring.include?("GOGO").should == false
  end    
  
end

end
