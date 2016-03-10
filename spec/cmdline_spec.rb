#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'

module Bake

describe "Cmdline" do
  
  it 'works' do
    expect(File.exists?("spec/testdata/simple/lib/build_test_ok_main_test_ok/src/y.cmdline")).to be == false
    expect(File.exists?("spec/testdata/simple/lib/build_test_ok_main_test_ok/liblib.a.cmdline")).to be == false
    expect(File.exists?("spec/testdata/simple/main/build_test_ok/src/x.cmdline")).to be == false
    expect(File.exists?("spec/testdata/simple/main/build_test_ok/main.exe.cmdline")).to be == false
    
    Bake.startBake("simple/main", ["test_ok"])

    expect(File.exists?("spec/testdata/simple/lib/build_test_ok_main_test_ok/src/y.cmdline")).to be == true
    expect(File.exists?("spec/testdata/simple/lib/build_test_ok_main_test_ok/liblib.a.cmdline")).to be == true
    expect(File.exists?("spec/testdata/simple/main/build_test_ok/src/x.cmdline")).to be == true
    expect(File.exists?("spec/testdata/simple/main/build_test_ok/main.exe.cmdline")).to be == true

    contents = File.read("spec/testdata/simple/lib/build_test_ok_main_test_ok/src/y.cmdline")  
    expect(contents.strip).to be == "g++ -c -MD -MF build_test_ok_main_test_ok/src/y.d -o build_test_ok_main_test_ok/src/y.o src/y.cpp"
    
    contents = File.read("spec/testdata/simple/lib/build_test_ok_main_test_ok/liblib.a.cmdline")  
    expect(contents.strip).to be == "ar -rc build_test_ok_main_test_ok/liblib.a build_test_ok_main_test_ok/src/y.o"

    contents = File.read("spec/testdata/simple/main/build_test_ok/src/x.cmdline")  
    expect(contents.strip).to be == "g++ -c -MD -MF build_test_ok/src/x.d -o build_test_ok/src/x.o src/x.cpp"

    contents = File.read("spec/testdata/simple/main/build_test_ok/main.exe.cmdline")  
    expect(contents.strip).to be == "g++ -o build_test_ok/main.exe build_test_ok/src/x.o ../lib/build_test_ok_main_test_ok/liblib.a"
  end

  it 'compile error' do
    expect(File.exists?("spec/testdata/simple/lib/build_test_ok_main_test_compileError/src/y.cmdline")).to be == false
    expect(File.exists?("spec/testdata/simple/lib/build_test_ok_main_test_compileError/liblib.a.cmdline")).to be == false
    expect(File.exists?("spec/testdata/simple/main/build_test_compileError/src/x.cmdline")).to be == false
    expect(File.exists?("spec/testdata/simple/main/build_test_compileError/main.exe.cmdline")).to be == false
    
    Bake.startBake("simple/main", ["test_compileError"])

    expect(File.exists?("spec/testdata/simple/lib/build_test_ok_main_test_compileError/src/y.cmdline")).to be == true
    expect(File.exists?("spec/testdata/simple/lib/build_test_ok_main_test_compileError/liblib.a.cmdline")).to be == false
    expect(File.exists?("spec/testdata/simple/main/build_test_compileError/src/x.cmdline")).to be == true
    expect(File.exists?("spec/testdata/simple/main/build_test_compileError/main.exe.cmdline")).to be == false

    contents = File.read("spec/testdata/simple/lib/build_test_ok_main_test_compileError/src/y.cmdline")  
    expect(contents.strip).to be == "g++ -c -MD -MF build_test_ok_main_test_compileError/src/y.d -wrong -o build_test_ok_main_test_compileError/src/y.o src/y.cpp"
    
    contents = File.read("spec/testdata/simple/main/build_test_compileError/src/x.cmdline")  
    expect(contents.strip).to be == "g++ -c -MD -MF build_test_compileError/src/x.d -wrong -o build_test_compileError/src/x.o src/x.cpp"
  end
  
  it 'archive error' do
    expect(File.exists?("spec/testdata/simple/lib/build_test_ok_main_test_archiveError/src/y.cmdline")).to be == false
    expect(File.exists?("spec/testdata/simple/lib/build_test_ok_main_test_archiveError/liblib.a.cmdline")).to be == false
    expect(File.exists?("spec/testdata/simple/main/build_test_archiveError/src/x.cmdline")).to be == false
    expect(File.exists?("spec/testdata/simple/main/build_test_archiveError/main.exe.cmdline")).to be == false
    
    Bake.startBake("simple/main", ["test_archiveError"])

    expect(File.exists?("spec/testdata/simple/lib/build_test_ok_main_test_archiveError/src/y.cmdline")).to be == true
    expect(File.exists?("spec/testdata/simple/lib/build_test_ok_main_test_archiveError/liblib.a.cmdline")).to be == true
    expect(File.exists?("spec/testdata/simple/main/build_test_archiveError/src/x.cmdline")).to be == true
    expect(File.exists?("spec/testdata/simple/main/build_test_archiveError/main.exe.cmdline")).to be == false

    contents = File.read("spec/testdata/simple/lib/build_test_ok_main_test_archiveError/liblib.a.cmdline")  
    expect(contents.strip).to be == "ar -wrong -rc build_test_ok_main_test_archiveError/liblib.a build_test_ok_main_test_archiveError/src/y.o"
  end
     
  it 'link error' do
    expect(File.exists?("spec/testdata/simple/lib/build_test_ok_main_test_linkError/src/y.cmdline")).to be == false
    expect(File.exists?("spec/testdata/simple/lib/build_test_ok_main_test_linkError/liblib.a.cmdline")).to be == false
    expect(File.exists?("spec/testdata/simple/main/build_test_linkError/src/x.cmdline")).to be == false
    expect(File.exists?("spec/testdata/simple/main/build_test_linkError/main.exe.cmdline")).to be == false
    
    Bake.startBake("simple/main", ["test_linkError"])

    expect(File.exists?("spec/testdata/simple/lib/build_test_ok_main_test_linkError/src/y.cmdline")).to be == true
    expect(File.exists?("spec/testdata/simple/lib/build_test_ok_main_test_linkError/liblib.a.cmdline")).to be == true
    expect(File.exists?("spec/testdata/simple/main/build_test_linkError/src/x.cmdline")).to be == true
    expect(File.exists?("spec/testdata/simple/main/build_test_linkError/main.exe.cmdline")).to be == true

    contents = File.read("spec/testdata/simple/main/build_test_linkError/main.exe.cmdline")  
    expect(contents.strip).to be == "g++ -wrong -o build_test_linkError/main.exe build_test_linkError/src/x.o ../lib/build_test_ok_main_test_linkError/liblib.a"
  end  
   
end

end
