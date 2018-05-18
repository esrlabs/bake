#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'bake/util'
require 'common/exit_helper'
require 'socket'
require 'fileutils'

require 'common/ext/stdout'

module Bake

describe "Makefile" do

  it 'builds' do
    Bake.startBake("make/main", ["test"])
    expect($mystring.include?("make all")).to be == true
    expect($mystring.include?("Building done.")).to be == true
  end

  it 'cleans' do
    Bake.startBake("make/main",  ["test", "-c"])
    expect($mystring.include?("Cleaning done.")).to be == true
  end

  it 'cleanStep build' do
    Bake.startBake("make/main",  ["test_cleanstep"])
    expect($mystring.include?("make clean")).to be == false
  end

  it 'cleanStep clean' do
    Bake.startBake("make/main",  ["test_cleanstep", "-c"])
    expect($mystring.include?("make clean")).to be == true
  end

  it 'workingDir and env' do
    Bake.startBake("make/main2",  ["test"])

    str =
      "**** Building 1 of 1: main2 (test) ****\n"+
      "make all -s -C makefile -f m.mak\n"+
      "CPPC1 -DCPPD1 CPPF1\n"+
      "CC1 -DCD1 CF1\n"+
      "ASMC1 -DASMD1 ASMF1\n"+
      "ARC1 ARF1\n"+
      "LC1 LF1\n"+
      "DIR: makefile\n"+
      "make all -s -f makefile/m.mak\n"+
      "CPPC1 -DCPPD1 CPPF1\n"+
      "CC1 -DCD1 CF1\n"+
      "ASMC1 -DASMD1 ASMF1\n"+
      "ARC1 ARF1\n"+
      "LC1 LF1\n"+
      "DIR: main2\n"+
      "make all -s -C makefile -f m.mak\n"+
      "CPPC1 -DCPPD1 CPPF1\n"+
      "CC1 -DCD1 CF1\n"+
      "ASMC1 -DASMD1 ASMF1\n"+
      "ARC1 ARF1\n"+
      "LC1 LF1\n"+
      "DIR: makefile\n"+
      "\n"+
      "Building done."

    expect($mystring.include?(str)).to be == true
  end

  it 'noClean' do
    Bake.startBake("make/main2",  ["test", "-c", "-v2"])

    str =
      "**** Cleaning 1 of 1: main2 (test) ****\n"+
      "make clean -s -C makefile -f m.mak\n"+
      "CleanIt\n"+
      "make clean -s -f makefile/m.mak\n"+
      "CleanIt\n"+
      "\n"+
      "Cleaning done."

    expect($mystring.include?(str)).to be == true
  end

end

end
