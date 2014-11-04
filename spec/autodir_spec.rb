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

describe "autodir" do
  
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

  it 'without no_autodir' do
    options = Options.new(["-m", "spec/testdata/noAutodir/main", "-b", "test", "--rebuild"])
    options.parse_options()
    tocxx = Cxxproject::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    ($mystring.split("Rebuild failed.").length).should == 2
  end

  it 'with no_autodir' do
    options = Options.new(["-m", "spec/testdata/noAutodir/main", "-b", "test", "--no_autodir", "--rebuild"])
    options.parse_options()
    tocxx = Cxxproject::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    ($mystring.split("Rebuild done.").length).should == 2
  end
  
end

end
