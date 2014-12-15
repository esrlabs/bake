#!/usr/bin/env ruby

require 'common/version'

require 'tocxx'
require 'bake/options/options'
require 'imported/utils/exit_helper'
require 'fileutils'
require 'helper'

module Bake

describe "Building" do
  
  it 'workspace' do
    expect(File.exists?("spec/testdata/cache/main/test/main.exe")).to be == false
    
    Bake.startBake("cache/main", ["-b", "test", "-v2"])

    expect(File.exists?("spec/testdata/cache/main/test/main.exe")).to be == true
    
    STDERR.puts $mystring
    
    expect($mystring.split("PREMAIN").length).to be == 3
    expect($mystring.split("POSTMAIN").length).to be == 3
    
    
    
    expect($mystring.include?("../lib1/testsub_main_test/liblib1.a makefile/dummy.a")).to be == true # makefile lib shall be put to the end of the lib string
  end

  it 'single lib' do
    expect(File.exists?("spec/testdata/cache/main/test/main.exe")).to be == false
    
    Bake.startBake("cache/main", ["-p", "lib1", "-b", "test"])

    expect(File.exists?("spec/testdata/cache/lib1/testsub_main_test/liblib1.a")).to be == true
    expect(File.exists?("spec/testdata/cache/main/test/main.exe")).to be == false
    
    expect($mystring.split("PRELIB1").length).to be == 3
    expect($mystring.split("POSTLIB1").length).to be == 3    
  end  

  it 'single exe should fail' do
    expect(File.exists?("spec/testdata/cache/lib1/testsub_main_test/src/lib1.o")).to be == false
    expect(File.exists?("spec/testdata/cache/lib1/testsub_main_test/liblib1.a")).to be == false

    expect(File.exists?("spec/testdata/cache/main/test/src/main.o")).to be == false
    expect(File.exists?("spec/testdata/cache/main/test/main.exe")).to be == false
    
    Bake.startBake("cache/main", ["-p", "main", "-b", "test"])

    expect(File.exists?("spec/testdata/cache/lib1/testsub_main_test/src/lib1.o")).to be == false
    expect(File.exists?("spec/testdata/cache/lib1/testsub_main_test/liblib1.a")).to be == false

    expect(File.exists?("spec/testdata/cache/main/test/src/main.o")).to be == true
    expect(File.exists?("spec/testdata/cache/main/test/main.exe")).to be == false
    
    expect($mystring.split("PREMAIN").length).to be == 3
    expect($mystring.split("POSTMAIN").length).to be == 1 # means not executed cause exe build failed
    
    expect(ExitHelper.exit_code).to be > 0
  end  

  it 'single file' do
    expect(File.exists?("spec/testdata/cache/main/test/src/main.o")).to be == false
    expect(File.exists?("spec/testdata/cache/main/test/main.exe")).to be == false

    Bake.startBake("cache/main", ["-b", "test", "-f", "src/main.cpp"])

    expect(File.exists?("spec/testdata/cache/main/test/src/main.o")).to be == true
    expect(File.exists?("spec/testdata/cache/main/test/main.exe")).to be == false
    
    expect(ExitHelper.exit_code).to be == 0
  end  

  it 'clean single file' do
    Bake.startBake("cache/main", ["-b", "test"])

    expect(File.exists?("spec/testdata/cache/main/test/src/main.o")).to be == true
    expect(File.exists?("spec/testdata/cache/main/test/src/main.d")).to be == true
    expect(File.exists?("spec/testdata/cache/main/test/main.exe")).to be == true

    Bake.startBake("cache/main", ["-b", "test", "-f", "src/main.cpp", "-c"])
    
    expect(File.exists?("spec/testdata/cache/main/test/src/main.o")).to be == false
    expect(File.exists?("spec/testdata/cache/main/test/src/main.d")).to be == false
    expect(File.exists?("spec/testdata/cache/main/test/main.exe")).to be == true
    
    expect(ExitHelper.exit_code).to be == 0
  end  

  it 'clean single lib' do
    Bake.startBake("cache/main", ["-b", "test"])
    
    expect(File.exists?("spec/testdata/cache/main/test")).to be == true
    expect(File.exists?("spec/testdata/cache/lib1/testsub_main_test")).to be == true
    expect(File.exists?("spec/testdata/cache/lib1/testsub_main_test/liblib1.a")).to be == true
    expect(File.exists?("spec/testdata/cache/main/test/main.exe")).to be == true

    Bake.startBake("cache/main", ["-b", "test", "-p", "lib1", "-c"])

    expect(File.exists?("spec/testdata/cache/main/test")).to be == true
    expect(File.exists?("spec/testdata/cache/lib1/testsub_main_test")).to be == false
    expect(File.exists?("spec/testdata/cache/lib1/testsub_main_test/liblib1.a")).to be == false
    expect(File.exists?("spec/testdata/cache/main/test/main.exe")).to be == true
    
    expect(ExitHelper.exit_code).to be == 0
  end
    
  it 'clean single lib' do
    Bake.startBake("cache/main", ["-b", "test"])
    
    expect(File.exists?("spec/testdata/cache/main/test")).to be == true
    expect(File.exists?("spec/testdata/cache/lib1/testsub_main_test")).to be == true
    expect(File.exists?("spec/testdata/cache/lib1/testsub_main_test/liblib1.a")).to be == true
    expect(File.exists?("spec/testdata/cache/main/test/main.exe")).to be == true

    Bake.startBake("cache/main", ["-b", "test","-p", "main", "-c"])

    expect(File.exists?("spec/testdata/cache/main/test")).to be == false
    expect(File.exists?("spec/testdata/cache/lib1/testsub_main_test")).to be == true
    expect(File.exists?("spec/testdata/cache/lib1/testsub_main_test/liblib1.a")).to be == true
    expect(File.exists?("spec/testdata/cache/main/test/main.exe")).to be == false
    
    expect(ExitHelper.exit_code).to be == 0
  end  
  
  it 'clobber' do
    Bake.startBake("cache/main", ["-b", "test"])

    expect(File.exists?("spec/testdata/cache/main/.bake")).to be == true
    expect(File.exists?("spec/testdata/cache/lib1/.bake")).to be == true

    Bake.startBake("cache/main", ["-b", "test", "--clobber"])

    expect(File.exists?("spec/testdata/cache/main/.bake")).to be == false
    expect(File.exists?("spec/testdata/cache/lib1/.bake")).to be == false
  end    
  
  it 'clobber project only' do
    Bake.startBake("cache/main", ["-b", "test", "-p", "lib1"])

    expect(File.exists?("spec/testdata/cache/main/.bake")).to be == true
    expect(File.exists?("spec/testdata/cache/lib1/.bake")).to be == true

    Bake.startBake("cache/main", ["-b", "test", "-p", "lib1", "--clobber"])

    expect(File.exists?("spec/testdata/cache/main/.bake")).to be == true
    expect(File.exists?("spec/testdata/cache/lib1/.bake")).to be == false
  end    

end

end
