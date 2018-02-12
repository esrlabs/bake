#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'socket'
require 'fileutils'

module Bake

describe "Ending" do

  it 'switch files' do
    Bake.startBake("ending/main", ["test", "-v2"])
    expect($mystring.include?("gcc -c -MD -MF build/test/src/file1.d -o build/test/src/file1.o src/file1.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test/src/file2.d -o build/test/src/file2.o src/file2.c")).to be == true
    expect($mystring.include?("gcc -c -MD -MF build/test/src/file3.d -o build/test/src/file3.o src/file3.hxx")).to be == true

    expect($mystring.include?("Building done.")).to be == true
  end

  it 'no file endings in DefaultToolchain' do
    Bake.startBake("ending/wrong1", [])
    expect($mystring.include?("FileEnding must not be empty.")).to be == true
    expect($mystring.include?("Building failed.")).to be == true
  end

  it 'no file endings in Toolchain' do
    Bake.startBake("ending/wrong2", [])
    expect($mystring.include?("FileEnding must not be empty.")).to be == true
    expect($mystring.include?("Building failed.")).to be == true
  end

end

end

