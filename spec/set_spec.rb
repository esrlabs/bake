#!/usr/bin/env ruby

$:.unshift(File.dirname(__FILE__)+"/../../cxxproject/lib")

require 'bake/version'

require 'tocxx'
require 'bake/options'
require 'cxxproject/utils/exit_helper'
require 'socket'
require 'cxxproject/utils/cleanup'
require 'fileutils'
require 'helper'

module Cxxproject

ExitHelper.enable_exit_test

describe "Set" do
  
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

  it 'value' do
    options = Options.new(["-m", "spec/testdata/set", "-b", "value"])
    options.parse_options()
    tocxx = Cxxproject::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    ($mystring.include?"*GUGU*").should == true
  end

  it 'cmd' do
    options = Options.new(["-m", "spec/testdata/set", "-b", "cmd"])
    options.parse_options()
    tocxx = Cxxproject::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    ($mystring.include?"*GAGA*").should == true
  end
  
  it 'cat' do
    options = Options.new(["-m", "spec/testdata/set", "-b", "cat"])
    options.parse_options()
    tocxx = Cxxproject::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    STDERR.puts $mystring
    ($mystring.include?"*MYTEST ABC*").should == true
  end  

  it 'arti' do
    options = Options.new(["-m", "spec/testdata/set", "-b", "arti"])
    options.parse_options()
    tocxx = Cxxproject::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    ($mystring.include?"arti/*GAGA*").should == true
  end
  
  it 'triple' do
    options = Options.new(["-m", "spec/testdata/set", "-b", "triple"])
    options.parse_options()
    tocxx = Cxxproject::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    ($mystring.include?"*GAGAGUGUHUHU*").should == true
  end
  
  it 'recursive' do
    options = Options.new(["-m", "spec/testdata/set", "-b", "recursive"])
    options.parse_options()
    tocxx = Cxxproject::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    ($mystring.include?"**GUGU*-HUHU *GUGU*.elf*").should == true
    ($mystring.include?"recursive/HUHU *GUGU*.elf").should == true
  end
  
  it 'no cmd' do
    options = Options.new(["-m", "spec/testdata/set_set/A", "-b", "test"])
    options.parse_options()
    tocxx = Cxxproject::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    ($mystring.include?"Project A TestA   A").should == true
    ($mystring.include?"Project B TestA TestB  B").should == true
    ($mystring.include?"Project C TestA  TestC C").should == true
  end

  it 'cmd A' do
    options = Options.new(["-m", "spec/testdata/set_set/A", "-b", "test", "--set", "a=X"])
    options.parse_options()
    tocxx = Cxxproject::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    ($mystring.include?"Project A X   A").should == true
    ($mystring.include?"Project B X TestB  B").should == true
    ($mystring.include?"Project C X  TestC C").should == true
  end
  
  it 'cmd B' do
    options = Options.new(["-m", "spec/testdata/set_set/A", "-b", "test", "--set", "b=X"])
    options.parse_options()
    tocxx = Cxxproject::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    ($mystring.include?"Project A TestA X  A").should == true
    ($mystring.include?"Project B TestA X  B").should == true
    ($mystring.include?"Project C TestA X TestC C").should == true
  end
  
      
end

end
