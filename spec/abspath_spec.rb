#!/usr/bin/env ruby

require 'helper'
require 'socket'
require 'fileutils'
require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'

module Bake

describe "abspaths" do

  it 'rel' do
    Bake.startBake("errorParser/error", ["test"])
    expect($mystring.include?("src/main.cpp:3")).to be == true
    expect($mystring.include?("spec/testdata/errorParser/error/src/main.cpp:3")).to be == false
  end
  it 'absOld' do
    Bake.startBake("errorParser/error", ["test", "--show_abs_paths"])
    expect($mystring.include?("spec/testdata/errorParser/error/src/main.cpp:3")).to be == true
  end
  it 'absNew' do
    Bake.startBake("errorParser/error", ["test", "--abs-paths"])
    expect($mystring.include?("spec/testdata/errorParser/error/src/main.cpp:3")).to be == true
  end
  it 'absCmd' do
    Bake.startBake("simple/main", ["test_ok", "--abs-paths", "-v2"])
    expect($mystring).to match(/spec\/testdata\/simple\/lib\/build\/test_ok_main_test_ok\/src\/y\.d .*spec\/testdata\/simple\/lib\/build\/test_ok_main_test_ok\/src\/y\.o .*spec\/testdata\/simple\/lib\/src\/y\.cpp/)
    expect($mystring).to match(/spec\/testdata\/simple\/lib\/build\/test_ok_main_test_ok\/liblib\.a .*spec\/testdata\/simple\/lib\/build\/test_ok_main_test_ok\/src\/y\.o .*spec\/testdata\/simple\/lib\/build\/test_ok_main_test_ok\/src\/z\.o/)
    expect($mystring).to match(/spec\/testdata\/simple\/main\/build\/test_ok\/main.*spec\/testdata\/simple\/main\/build\/test_ok\/src\/x\.o .*spec\/testdata\/simple\/lib\/build\/test_ok_main_test_ok\/liblib\.a/)
  end

  it 'abs-out' do
    Bake.startBake("errorParser/error", ["test", "--abs-paths-in"])
    expect($mystring.include?("spec/testdata/errorParser/error/src/main.cpp:3")).to be == true
  end
  it 'absCmd-out' do
    Bake.startBake("simple/main", ["test_ok", "--abs-paths-out", "-v2"])
    expect($mystring.include?("spec/testdata/simple/main/build")).to be == false
    expect($mystring.include?("spec/testdata/simple/lib/build")).to be == false
  end
  it 'absCmd-in' do
    Bake.startBake("simple/main", ["test_ok", "--abs-paths-in", "-v2"])
    expect($mystring.include?("spec/testdata/simple/main/build")).to be == true
    expect($mystring.include?("spec/testdata/simple/lib/build")).to be == true
  end

end

end
