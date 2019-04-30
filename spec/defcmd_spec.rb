#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'

module Bake

  incsTestStrDefCmd =
      " CPP defines\n"+
      "  DEF1\n"+
      "  DEF2\n"+
      "  DEF3\n"+
      " C defines\n"+
      "  DEF2\n"+
      "  DEF3\n"+
      " ASM defines\n"+
      "  DEF2\n"+
      "  DEF3\n"+
      " done\n"

  incsTestStrDefCmdJson =
    "    \"cpp_defines\": [\n"+
    "      \"DEF1\",\n"+
    "      \"DEF2\",\n"+
    "      \"DEF3\"\n"+
    "    ],\n"+
    "    \"c_defines\": [\n"+
    "      \"DEF2\",\n"+
    "      \"DEF3\"\n"+
    "    ],\n"+
    "    \"asm_defines\": [\n"+
    "      \"DEF2\",\n"+
    "      \"DEF3\"\n"+
    "    ]"


describe "Define on command line" do

  it 'without -D' do
    Bake.startBake("simple/main", ["test_ok", "-v2"])

    expect($mystring.include?("Building done.")).to be == true#
    expect(ExitHelper.exit_code).to be == 0

    expect($mystring.include?("-DDEF1")).to be == true
    expect($mystring.include?("DEF2")).to be == false
    expect($mystring.include?("DEF3")).to be == false
  end

  it 'with -D' do
    Bake.startBake("simple/main", ["test_ok", "-D", "DEF2", "-D", "DEF3", "-v2"])

    expect($mystring.include?("Building done.")).to be == true#
    expect(ExitHelper.exit_code).to be == 0

    expect($mystring.include?("-DDEF1 -DDEF2 -DDEF3")).to be == true
  end

  it 'incanddefs bake' do
    Bake.startBake("simple/main", ["test_ok", "-D", "DEF2", "-D", "DEF3", "--incs-and-defs=bake"])
    expect($mystring.include?(incsTestStrDefCmd)).to be == true
  end

  it 'incanddefs json' do
    Bake.startBake("simple/main", ["test_ok", "-D", "DEF2", "-D", "DEF3", "--incs-and-defs=json"])
    expect($mystring.include?(incsTestStrDefCmdJson)).to be == true
  end

  it 'conversion info p1' do
    Bake.startBake("multiProj/main", ["test1", "--conversion-info", "-p", "lib,testSub1"])
    str = "START_INFO\n"+
          " BAKE_PROJECTDIR"
    expect($mystring.include?(str)).to be == true
    str = "multiProj/lib\n"+
          " BAKE_SOURCES\n"+
          " BAKE_INCLUDES\n"+
          " BAKE_DEFINES\n"+
          "  D2\n"+
          "  D1\n"+
          " BAKE_DEPENDENCIES\n"+
          " BAKE_DEPENDENCIES_FILTERED\n"+
          "END_INFO"
    expect($mystring.include?(str)).to be == true
  end

  it 'conversion info p2' do
    Bake.startBake("multiProj/main", ["test1", "--conversion-info", "-p", "lib,testSub2"])
    str = "START_INFO\n"+
          " BAKE_PROJECTDIR"
    expect($mystring.include?(str)).to be == true
    str = "multiProj/lib\n"+
          " BAKE_SOURCES\n"+
          " BAKE_INCLUDES\n"+
          "  incLib\n"+
          " BAKE_DEFINES\n"+
          "  D2\n"+
          "  D1\n"+
          " BAKE_DEPENDENCIES\n"+
          " BAKE_DEPENDENCIES_FILTERED\n"+
          "END_INFO"
    expect($mystring.include?(str)).to be == true
  end

  it 'conversion info p3' do
    Bake.startBake("multiProj/main", ["test1", "--conversion-info", "-p", "main,testLib1"])
    str = "START_INFO\n"+
          " BAKE_PROJECTDIR"
    expect($mystring.include?(str)).to be == true
    str = "multiProj/main\n"+
          " BAKE_SOURCES\n"+
          "  src/nix.cpp\n"+
          " BAKE_INCLUDES\n"+
          "  incMainC\n"+
          "  incMainD\n"+
          " BAKE_DEFINES\n"+
          "  D2\n"+
          "  D6\n"+
          "  D1\n"+
          "  D5\n"+
          " BAKE_DEPENDENCIES\n"+
          " BAKE_DEPENDENCIES_FILTERED\n"+
          "END_INFO"
    expect($mystring.include?(str)).to be == true
  end  

  it 'conversion info p4' do
    Bake.startBake("multiProj/main", ["test1", "--conversion-info", "-p", "main,test1"])
    str = "START_INFO\n"+
          " BAKE_PROJECTDIR"
    expect($mystring.include?(str)).to be == true
    str = "multiProj/main\n"+
          " BAKE_SOURCES\n"+
          "  src/main.cpp\n"+
          " BAKE_INCLUDES\n"+
          "  incMainA\n"+
          "  incMainB\n"+
          " BAKE_DEFINES\n"+
          "  D2\n"+
          "  D4\n"+
          "  D1\n"+
          "  D3\n"+
          " BAKE_DEPENDENCIES\n"+
          " BAKE_DEPENDENCIES_FILTERED\n"+
          "END_INFO"
    expect($mystring.include?(str)).to be == true
  end 
  
  it 'conversion info all' do
    Bake.startBake("multiProj/main", ["test1", "--conversion-info"])
    str = "START_INFO\n"+
          " BAKE_PROJECTDIR"
    expect($mystring.split(str).length).to be == 5
    str = "multiProj/main\n"+
          " BAKE_SOURCES\n"+
          "  src/main.cpp\n"+
          " BAKE_INCLUDES\n"+
          "  incMainA\n"+
          "  incMainB\n"+
          " BAKE_DEFINES\n"+
          "  D2\n"+
          "  D4\n"+
          "  D1\n"+
          "  D3\n"+
          " BAKE_DEPENDENCIES\n"+
          "  lib,testSub1\n"+
          "  lib,testSub2\n"+
          "  main,testLib1\n"+
          " BAKE_DEPENDENCIES_FILTERED\n"+
          "  lib,testSub1\n"+
          "  lib,testSub2\n"+
          "END_INFO"
    expect($mystring.include?(str)).to be == true
  end 

end

end
