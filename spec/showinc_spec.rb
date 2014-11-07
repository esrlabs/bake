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

describe "ShowInc" do
  
  before(:all) do
  end

  after(:all) do
  end

  before(:each) do
    Utils.cleanup_rake
    SpecHelper.clean_testdata_build("showinc","main","test*")
    SpecHelper.clean_testdata_build("outdir","sub","test*")

    $mystring=""
    $sstring=StringIO.open($mystring,"w+")
    $stdoutbackup=$stdout
    $stdout=$sstring
  end
  
  after(:each) do
    $stdout=$stdoutbackup

    ExitHelper.reset_exit_code
  end

  it 'RelativePath' do
    options = Options.new(["-m", "spec/testdata/showinc/main", "-b", "test" , "--show_incs_and_defs"])
    options.parse_options()
    tocxx = Cxxproject::ToCxx.new(options)
    lambda { tocxx.doit() }.should raise_error(ExitHelperException)
    
    s = "main\n"+
        " includes\n"+
        "  A/include\n"+
        "  ../sub/include\n"+
        "  subst\n"+
        "  incluuude\n"+
        "  C:\\gaga\n"+
        " CPP defines\n"+
        " C defines\n"+
        "  A=1\n"+
        "  UNITTEST\n"+
        "  X=Y\n"+
        "  blah\n"+
        "  toll\n"+
        " ASM defines\n"+
        " done\n"+
        "sub\n"+
        " includes\n"+
        "  include\n"+
        "  incluuude\n"+
        "  C:\\gaga\n"+
        " CPP defines\n"+
        "  GAGA\n"+
        " C defines\n"+
        "  A=1\n"+
        "  UNITTEST\n"+
        "  HOSSA\n"+
        "  X=Y\n"+
        "  blah\n"+
        "  toll\n"+
        " ASM defines\n"+
        " done"

    ($mystring.include?s).should == true

  end
  
  
  
end





end
