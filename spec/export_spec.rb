#!/usr/bin/env ruby

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'
require 'helper'

module Bake

describe "Export" do
  
  before(:all) do
    $noCleanTestData = true
  end

  after(:all) do
    $noCleanTestData = false
  end
  
  before(:each) do
    sleep 1 # needed for timestamp tests
  end
  
  it 'With file rebuild' do
    FileUtils.rm_rf("spec/testdata/root1/lib3/src/x.cpp")
    File.open("spec/testdata/root1/lib3/src/x.cpp", 'w') { |file| file.write("int i = 2;\n") }
    
    Bake.startBake("root1/main", ["-b", "rel_test", "--rebuild"])
    
    expect($mystring.include?("Compiling src/x.cpp")).to be == true
    expect($mystring.include?("Creating test_main_rel_test/liblib3.a")).to be == true
    expect($mystring.include?("Linking rel_test/main.exe")).to be == true
    expect($mystring.include?("Rebuilding done.")).to be == true
  end
  
  it 'With file build' do
    Bake.startBake("root1/main", ["-b", "rel_test"])
    
    expect($mystring.include?("Compiling src/x.cpp")).to be == false
    expect($mystring.include?("liblib3.a")).to be == false
    expect($mystring.include?("Linking rel_test/main.exe")).to be == false
    expect($mystring.include?("Building done.")).to be == true
  end  
  
  it 'Without file rebuild' do
    FileUtils.rm_rf("spec/testdata/root1/lib3/src/x.cpp")
    
    Bake.startBake("root1/main", ["-b", "rel_test", "--rebuild"])

    expect($mystring.include?("Compiling src/x.cpp")).to be == false
    expect($mystring.include?("liblib3.a")).to be == true
    expect($mystring.include?("Linking rel_test/main.exe")).to be == true
    expect($mystring.include?("Rebuilding done.")).to be == true
  end
  it 'Without file clean' do
    Bake.startBake("root1/main", ["-b", "rel_test", "-c"])
    expect($mystring.include?("Cleaning done.")).to be == true
  end
  it 'Without file build' do
    Bake.startBake("root1/main", ["-b", "rel_test"])
    
    expect($mystring.include?("Compiling src/x.cpp")).to be == false
    expect($mystring.include?("liblib3.a")).to be == true
    expect($mystring.include?("Linking rel_test/main.exe")).to be == true
    expect($mystring.include?("Building done.")).to be == true
  end
  it 'Without file lib' do
    Bake.startBake("root1/main", ["-b", "rel_test", "-p", "lib3"])
    
    expect($mystring.include?("Compiling src/x.cpp")).to be == false
    expect($mystring.include?("liblib3.a")).to be == false
    expect($mystring.include?("Linking rel_test/main.exe")).to be == false
    expect($mystring.include?("Building done.")).to be == true
  end
  it 'Without file lib rebuild' do
    Bake.startBake("root1/main", ["-b", "rel_test", "-p", "lib3", "--rebuild"])
    
    expect($mystring.include?("Compiling src/x.cpp")).to be == false
    expect($mystring.include?("liblib3.a")).to be == true
    expect($mystring.include?("Linking rel_test/main.exe")).to be == false
    expect($mystring.include?("Rebuilding done.")).to be == true
  end
  it 'Without file main rebuild' do
    Bake.startBake("root1/main", ["-b", "rel_test", "-p", "main", "--rebuild"])

    expect($mystring.include?("Compiling src/x.cpp")).to be == false
    expect($mystring.include?("liblib3.a")).to be == false
    expect($mystring.include?("Linking rel_test/main.exe")).to be == true
    expect($mystring.include?("Rebuilding done.")).to be == true    
  end
  it 'With file again build' do
    
    FileUtils.rm_rf("spec/testdata/root1/lib3/src/x.cpp")
    File.open("spec/testdata/root1/lib3/src/x.cpp", 'w') { |file| file.write("int i = 2;\n") }
    
    Bake.startBake("root1/main", ["-b", "rel_test"])
      
    expect($mystring.include?("Compiling src/x.cpp")).to be == true
    expect($mystring.include?("Creating test_main_rel_test/liblib3.a")).to be == true
    expect($mystring.include?("Linking rel_test/main.exe")).to be == true
    expect($mystring.include?("Building done.")).to be == true    
  end

end

end
