#!/usr/bin/env ruby

require 'bake/version'

require 'tocxx'
require 'bake/options'
require 'bake/util'
require 'cxxproject/utils/exit_helper'
require 'socket'
require 'cxxproject/utils/cleanup'
require 'fileutils'
require 'helper'

module Cxxproject

ExitHelper.enable_exit_test

describe "Deps" do

  before(:each) do
    $mystring=""
    $sstring=StringIO.open($mystring,"w+")
    $stdoutbackup=$stdout
    $stdout=$sstring
  end
  
  after(:each) do
    $stdout=$stdoutbackup
    ExitHelper.reset_exit_code
    Utils.cleanup_rake
  end

  it 'custom deps exe' do
    options = Options.new(["-m", "spec/testdata/deps/p1", "-b", "Debug", "--rebuild", "-v"])
    options.parse_options()
    tocxx = Cxxproject::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    $mystring.include?("Building 1 of 6: p3 (Debug)").should == true
    $mystring.include?("Building 2 of 6: p5 (Debug)").should == true
    $mystring.include?("Building 3 of 6: p4 (Debug)").should == true
    $mystring.include?("Building 4 of 6: p2 (Debug)").should == true
    $mystring.include?("Building 5 of 6: p6 (Debug)").should == true
    $mystring.include?("Building 6 of 6: p1 (Debug)").should == true
    $mystring.include?("Building 6 of 6: p1 (Debug)").should == true
    $mystring.include?("g++ -o Debug_p1/p2.exe Debug_p1/src/main.o ../p3/Debug_p1/libp3.a -L../p5/").should == true
    $mystring.include?("g++ -o Debug/p1.exe Debug/src/main.o ../p3/Debug_p1/libp3.a -L../p5/").should == false
    $mystring.include?("Rebuild done.").should == true
  end
  
  it 'exe deps exe' do
    options = Options.new(["-m", "spec/testdata/deps/p1", "-b", "Debug2", "--rebuild", "-v"])
    options.parse_options()
    tocxx = Cxxproject::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    $mystring.include?("Building 1 of 6: p3 (Debug)").should == true
    $mystring.include?("Building 2 of 6: p5 (Debug)").should == true
    $mystring.include?("Building 3 of 6: p4 (Debug)").should == true
    $mystring.include?("Building 4 of 6: p2 (Debug)").should == true
    $mystring.include?("Building 5 of 6: p6 (Debug)").should == true
    $mystring.include?("Building 6 of 6: p1 (Debug2)").should == true
    $mystring.include?("g++ -o Debug2_p1/p2.exe Debug2_p1/src/main.o ../p3/Debug2_p1/libp3.a -L../p5/").should == true
    $mystring.include?("g++ -o Debug2/p1.exe Debug2/src/main.o ../p3/Debug2_p1/libp3.a -L../p5/").should == true
    $mystring.include?("Rebuild done.").should == true
  end
  
  it 'different config of same proj' do
    options = Options.new(["-m", "spec/testdata/deps/p1", "-b", "DebugWrong"])
    options.parse_options()
    tocxx = Cxxproject::ToCxx.new(options)
    lambda { tocxx.doit() }.should raise_error(ExitHelperException)
    $mystring.include?("Error: dependency to config 'DebugWrong' of project 'p3' found (line 11), but config Debug was requested earlier").should == true
  end  
  
  it 'circ deps' do
    options = Options.new(["-m", "spec/testdata/deps/p1", "-b", "DebugCirc"])
    options.parse_options()
    tocxx = Cxxproject::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    $mystring.include?("Circular dependency detected").should == true
    $mystring.include?("Build aborted.").should == true
  end  
  
end

end
