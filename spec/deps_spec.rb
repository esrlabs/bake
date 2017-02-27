#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'bake/util'
require 'common/exit_helper'
require 'socket'
require 'fileutils'

module Bake

describe "Deps" do

  it 'custom deps exe' do
    Bake.startBake("deps/p1", ["-b", "Debug", "-v2", "--rebuild"])
    expect($mystring.include?("Building 1 of 6: p3 (Debug)")).to be == true
    expect($mystring.include?("Applying 2 of 6: p5 (Debug)")).to be == true
    expect($mystring.include?("Applying 3 of 6: p4 (Debug)")).to be == true
    expect($mystring.include?("Building 4 of 6: p2 (Debug)")).to be == true
    expect($mystring.include?("Applying 5 of 6: p6 (Debug)")).to be == true
    expect($mystring.include?("Applying 6 of 6: p1 (Debug)")).to be == true
    expect($mystring.include?("g++ -o build/Debug_p1_Debug/p2"+Bake::Toolchain.outputEnding+" build/Debug_p1_Debug/src/main.o ../p3/build/Debug_p1_Debug/libp3.a -L../p5")).to be == true
    expect($mystring.include?("g++ -o build/Debug/p1"+Bake::Toolchain.outputEnding+" build/Debug/src/main.o ../p3/build/Debug_p1_Debug/libp3.a -L../p5")).to be == false
    expect($mystring.include?("Rebuilding done.")).to be == true
  end

  it 'exe deps exe' do
    Bake.startBake("deps/p1", ["-b", "Debug2", "-v2", "--rebuild"])
    expect($mystring.include?("Building 1 of 6: p3 (Debug)")).to be == true
    expect($mystring.include?("Applying 2 of 6: p5 (Debug)")).to be == true
    expect($mystring.include?("Applying 3 of 6: p4 (Debug)")).to be == true
    expect($mystring.include?("Building 4 of 6: p2 (Debug)")).to be == true
    expect($mystring.include?("Applying 5 of 6: p6 (Debug)")).to be == true
    expect($mystring.include?("Building 6 of 6: p1 (Debug2)")).to be == true
    expect($mystring.include?("g++ -o build/Debug_p1_Debug2/p2"+Bake::Toolchain.outputEnding+" build/Debug_p1_Debug2/src/main.o ../p3/build/Debug_p1_Debug2/libp3.a -L../p5")).to be == true
    expect($mystring.include?("g++ -o build/Debug2/p1"+Bake::Toolchain.outputEnding+" build/Debug2/src/main.o -L../p5 ../p3/build/Debug_p1_Debug2/libp3.a")).to be == true
    expect($mystring.include?("Rebuilding done.")).to be == true
  end

  it 'circ deps' do
    Bake.startBake("deps/p1", ["-b", "DebugCirc", "-v3"])
    expect($mystring.include?("circular dependency")).to be == true
  end

  it 'double dep explicit' do
    Bake.startBake("deps/doubledep1", ["test1"])
    expect($mystring.split("echo sub").length).to be == 2
  end

  it 'double dep default' do
    Bake.startBake("deps/doubledep1", ["test2"])
    expect($mystring.split("echo sub").length).to be == 2
  end

  it 'double dep derive' do
    Bake.startBake("deps/doubledep1", ["test3"])
    expect($mystring.split("echo sub").length).to be == 2
  end

end

end
