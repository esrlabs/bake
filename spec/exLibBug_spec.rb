#!/usr/bin/env ruby

$:.unshift(File.dirname(__FILE__)+"/../../cxxproject.git/lib")

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

describe "..in ex lib" do
  
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

  it 'with search=true' do
    options = Options.new(["-m", "spec/testdata/exLibBug/sub", "-b", "Debug", "--rebuild"])
    options.parse_options()
    tocxx = Cxxproject::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    ($mystring.split("Rebuild done.").length).should == 2
	
    options = Options.new(["-m", "spec/testdata/exLibBug/main", "-b", "test1", "--rebuild"])
    options.parse_options()
    tocxx = Cxxproject::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    ($mystring.split("Rebuild done.").length).should == 3
  end

  it 'with search=false' do
    options = Options.new(["-m", "spec/testdata/exLibBug/sub", "-b", "Debug", "--rebuild"])
    options.parse_options()
    tocxx = Cxxproject::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    ($mystring.split("Rebuild done.").length).should == 2
	
    options = Options.new(["-m", "spec/testdata/exLibBug/main", "-b", "test2", "--rebuild"])
    options.parse_options()
    tocxx = Cxxproject::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    ($mystring.split("Rebuild done.").length).should == 3
  end
  
  it 'with searchPath' do
    options = Options.new(["-m", "spec/testdata/exLibBug/sub", "-b", "Debug", "--rebuild"])
    options.parse_options()
    tocxx = Cxxproject::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    ($mystring.split("Rebuild done.").length).should == 2
	
    options = Options.new(["-m", "spec/testdata/exLibBug/main", "-b", "test3", "--rebuild"])
    options.parse_options()
    tocxx = Cxxproject::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    ($mystring.split("Rebuild done.").length).should == 3
  end  

  
end

end
