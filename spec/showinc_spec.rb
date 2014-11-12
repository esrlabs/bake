#!/usr/bin/env ruby



require 'bake/version'

require 'tocxx'
require 'bake/options'
require 'imported/utils/exit_helper'
require 'imported/utils/cleanup'
require 'fileutils'
require 'helper'

module Bake

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
    tocxx = Bake::ToCxx.new(options)
    expect { tocxx.doit() }.to raise_error(ExitHelperException)
    
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

    expect(($mystring.include?s)).to be == true

  end
  
  
  
end





end
