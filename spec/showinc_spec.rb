#!/usr/bin/env ruby

require 'common/version'

require 'tocxx'
require 'bake/options/options'
require 'imported/utils/exit_helper'
require 'fileutils'
require 'helper'

module Bake

describe "ShowInc" do

  it 'RelativePath' do
    Bake.options = Options.new(["-m", "spec/testdata/showinc/main", "-b", "test" , "--show_incs_and_defs"])
      
    Bake.startBake("showinc/main", ["test", "--show_incs_and_defs"])
      
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
