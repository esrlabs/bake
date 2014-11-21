#!/usr/bin/env ruby

require 'common/version'

require 'tocxx'
require 'bake/options/options'
require 'bake/util'
require 'imported/utils/exit_helper'
require 'socket'
require 'imported/utils/cleanup'
require 'fileutils'
require 'helper'

module Bake

describe "Deps" do

  it 'custom deps exe' do
    Bake.options = Options.new(["-m", "spec/testdata/deps/p1", "-b", "Debug", "--rebuild", "-v2"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()
    expect($mystring.include?("Building 1 of 6: p3 (Debug)")).to be == true
    expect($mystring.include?("Building 2 of 6: p5 (Debug)")).to be == true
    expect($mystring.include?("Building 3 of 6: p4 (Debug)")).to be == true
    expect($mystring.include?("Building 4 of 6: p2 (Debug)")).to be == true
    expect($mystring.include?("Building 5 of 6: p6 (Debug)")).to be == true
    expect($mystring.include?("Building 6 of 6: p1 (Debug)")).to be == true
    expect($mystring.include?("Building 6 of 6: p1 (Debug)")).to be == true
    expect($mystring.include?("g++ -o Debug_p1/p2.exe Debug_p1/src/main.o ../p3/Debug_p1/libp3.a -L../p5/")).to be == true
    expect($mystring.include?("g++ -o Debug/p1.exe Debug/src/main.o ../p3/Debug_p1/libp3.a -L../p5/")).to be == false
    expect($mystring.include?("Rebuild done.")).to be == true
  end
  
  it 'exe deps exe' do
    Bake.options = Options.new(["-m", "spec/testdata/deps/p1", "-b", "Debug2", "--rebuild", "-v2"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()
    expect($mystring.include?("Building 1 of 6: p3 (Debug)")).to be == true
    expect($mystring.include?("Building 2 of 6: p5 (Debug)")).to be == true
    expect($mystring.include?("Building 3 of 6: p4 (Debug)")).to be == true
    expect($mystring.include?("Building 4 of 6: p2 (Debug)")).to be == true
    expect($mystring.include?("Building 5 of 6: p6 (Debug)")).to be == true
    expect($mystring.include?("Building 6 of 6: p1 (Debug2)")).to be == true
    expect($mystring.include?("g++ -o Debug2_p1/p2.exe Debug2_p1/src/main.o ../p3/Debug2_p1/libp3.a -L../p5/")).to be == true
    expect($mystring.include?("g++ -o Debug2/p1.exe Debug2/src/main.o ../p3/Debug2_p1/libp3.a -L../p5/")).to be == true
    expect($mystring.include?("Rebuild done.")).to be == true
  end
  
  it 'different config of same proj' do
    Bake.options = Options.new(["-m", "spec/testdata/deps/p1", "-b", "DebugWrong"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    expect { tocxx.doit() }.to raise_error(ExitHelperException)
    expect($mystring.include?("Error: dependency to config 'DebugWrong' of project 'p3' found (line 11), but config Debug was requested earlier")).to be == true
  end  
  
  it 'circ deps' do
    Bake.options = Options.new(["-m", "spec/testdata/deps/p1", "-b", "DebugCirc"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()
    expect($mystring.include?("Circular dependency detected")).to be == true
    expect($mystring.include?("Build aborted.")).to be == true
  end  
  
end

end
