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
    expect($mystring.include?("gcc -c -MD -MF build/test/src/file1.d -DA -o build/test/src/file1.o src/file1.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test/src/file2.d -o build/test/src/file2.o src/file2.c")).to be == true

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

  it 'keep endings' do
    Bake.startBake("ending/keep", ["-v2"])
    expect(File.exists?("spec/testdata/ending/keep/build/test_dep_keep_test/src/file1.cpp.d")).to be == true
    expect(File.exists?("spec/testdata/ending/keep/build/test_dep_keep_test/src/file1.cpp.o")).to be == true
    expect(File.exists?("spec/testdata/ending/keep/build/test/src/file2.c.d")).to be == true
    expect(File.exists?("spec/testdata/ending/keep/build/test/src/file2.c.o")).to be == true
    expect($mystring.include?("Building done.")).to be == true

    Bake.startBake("ending/keep", [])
    expect($mystring.include?("Compiling")).to be == false
    expect($mystring.split("Building done.").length).to be == 3
  end


end

end

