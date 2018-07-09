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



end

end
