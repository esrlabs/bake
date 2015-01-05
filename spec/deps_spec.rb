#!/usr/bin/env ruby

require 'common/version'

require 'bake/options/options'
require 'bake/util'
require 'common/exit_helper'
require 'socket'
require 'fileutils'
require 'helper'

module Bake

describe "Deps" do

  it 'custom deps exe' do
    Bake.startBake("deps/p1", ["-b", "Debug", "-v2", "--rebuild"])
    expect($mystring.include?("Building 1 of 6: p3 (Debug)")).to be == true
    expect($mystring.include?("Building 2 of 6: p5 (Debug)")).to be == true
    expect($mystring.include?("Building 3 of 6: p4 (Debug)")).to be == true
    expect($mystring.include?("Building 4 of 6: p2 (Debug)")).to be == true
    expect($mystring.include?("Building 5 of 6: p6 (Debug)")).to be == true
    expect($mystring.include?("Building 6 of 6: p1 (Debug)")).to be == true
    expect($mystring.include?("g++ -o Debug_p1_Debug/p2.exe Debug_p1_Debug/src/main.o ../p3/Debug_p1_Debug/libp3.a -L../p5/")).to be == true
    expect($mystring.include?("g++ -o Debug/p1.exe Debug/src/main.o ../p3/Debug_p1_Debug/libp3.a -L../p5/")).to be == false
    expect($mystring.include?("Rebuilding done.")).to be == true
  end
  
  it 'exe deps exe' do
    Bake.startBake("deps/p1", ["-b", "Debug2", "-v2", "--rebuild"])
    expect($mystring.include?("Building 1 of 6: p3 (Debug)")).to be == true
    expect($mystring.include?("Building 2 of 6: p5 (Debug)")).to be == true
    expect($mystring.include?("Building 3 of 6: p4 (Debug)")).to be == true
    expect($mystring.include?("Building 4 of 6: p2 (Debug)")).to be == true
    expect($mystring.include?("Building 5 of 6: p6 (Debug)")).to be == true
    expect($mystring.include?("Building 6 of 6: p1 (Debug2)")).to be == true
    expect($mystring.include?("g++ -o Debug_p1_Debug2/p2.exe Debug_p1_Debug2/src/main.o ../p3/Debug_p1_Debug2/libp3.a -L../p5/")).to be == true
    expect($mystring.include?("g++ -o Debug2/p1.exe Debug2/src/main.o ../p3/Debug_p1_Debug2/libp3.a -L../p5/")).to be == true
    expect($mystring.include?("Rebuilding done.")).to be == true
  end
  
  it 'circ deps' do
    Bake.startBake("deps/p1", ["-b", "DebugCirc"])
    expect($mystring.include?("Circular dependency found")).to be == true
  end  
  
end

end
