#!/usr/bin/env ruby

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'
require 'helper'

module Bake

describe "ShowInc" do

  it 'RelativePath' do
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
  
  it 'Vars' do
    Bake.startBake("showinc/main", ["testVar", "--incs-and-defs"])
    expect($mystring.match(/\/.+\/\.\.\/include1/).nil?).to be == false
    expect($mystring.match(/\/.+\/\.\.\/include2/).nil?).to be == false
    expect($mystring.match(/\/.+\/\.\.\/include3/).nil?).to be == false
    expect($mystring.match(/\/.+\/\.\.\/include4/).nil?).to be == false
    expect($mystring.match(/\/.+\/\.\.\/include5/).nil?).to be == false
  end
  

  
end





end
