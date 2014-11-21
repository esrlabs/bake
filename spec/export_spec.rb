#!/usr/bin/env ruby



require 'common/version'

require 'tocxx'
require 'bake/options/options'
require 'imported/utils/exit_helper'
require 'imported/utils/cleanup'
require 'fileutils'
require 'helper'

module Bake

ExitHelper.enable_exit_test

describe "Export" do
  
  before(:each) do
    sleep 1 # needed for timestamp tests
  end
  
  it 'With file rebuild' do
    FileUtils.rm_rf("spec/testdata/root1/lib3/src/x.cpp")
    File.open("spec/testdata/root1/lib3/src/x.cpp", 'w') { |file| file.write("int i = 2;\n") }
    
    Bake.options = Options.new(["-m", "spec/testdata/root1/main", "-b", "rel_test", "--rebuild"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()    
    
    expect($mystring.include?("Compiling src/x.cpp")).to be == true
    expect($mystring.include?("Creating rel_test_main/liblib3.a")).to be == true
    expect($mystring.include?("Linking rel_test/main.exe")).to be == true
    expect($mystring.include?("Rebuild done.")).to be == true
  end
  
  it 'With file build' do
    Bake.options = Options.new(["-m", "spec/testdata/root1/main", "-b", "rel_test"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()    
    
    expect($mystring.include?("Compiling src/x.cpp")).to be == false
    expect($mystring.include?("liblib3.a")).to be == false
    expect($mystring.include?("Linking rel_test/main.exe")).to be == false
    expect($mystring.include?("Build done.")).to be == true
  end  
  
  it 'Without file rebuild' do
    
    FileUtils.rm_rf("spec/testdata/root1/lib3/src/x.cpp")
    
    Bake.options = Options.new(["-m", "spec/testdata/root1/main", "-b", "rel_test", "--rebuild"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()    
    
    expect($mystring.include?("Compiling src/x.cpp")).to be == false
    expect($mystring.include?("liblib3.a")).to be == false
    expect($mystring.include?("Linking rel_test/main.exe")).to be == true
    expect($mystring.include?("Rebuild done.")).to be == true
  end
  it 'Without file clean' do
    
    Bake.options = Options.new(["-m", "spec/testdata/root1/main", "-b", "rel_test", "-c"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()   
    
    expect($mystring.include?("Clean done.")).to be == true
  end
  it 'Without file build' do
    
    Bake.options = Options.new(["-m", "spec/testdata/root1/main", "-b", "rel_test"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()
    
    expect($mystring.include?("Compiling src/x.cpp")).to be == false
    expect($mystring.include?("liblib3.a")).to be == false
    expect($mystring.include?("Linking rel_test/main.exe")).to be == true
    expect($mystring.include?("Build done.")).to be == true
  end
  it 'Without file lib' do
    
    Bake.options = Options.new(["-m", "spec/testdata/root1/main", "-b", "rel_test", "-p", "lib3"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()
    
    expect($mystring.include?("Compiling src/x.cpp")).to be == false
    expect($mystring.include?("liblib3.a")).to be == false
    expect($mystring.include?("Linking rel_test/main.exe")).to be == false
    expect($mystring.include?("Build done.")).to be == true
  end
  it 'Without file lib rebuild' do
    
    Bake.options = Options.new(["-m", "spec/testdata/root1/main", "-b", "rel_test", "-p", "lib3", "--rebuild"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()
    
    expect($mystring.include?("Compiling src/x.cpp")).to be == false
    expect($mystring.include?("liblib3.a")).to be == false
    expect($mystring.include?("Linking rel_test/main.exe")).to be == false
    expect($mystring.include?("Rebuild done.")).to be == true
  end
  it 'Without file main rebuild' do
    
    Bake.options = Options.new(["-m", "spec/testdata/root1/main", "-b", "rel_test", "-p", "main", "--rebuild"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()

    expect($mystring.include?("Compiling src/x.cpp")).to be == false
    expect($mystring.include?("liblib3.a")).to be == false
    expect($mystring.include?("Linking rel_test/main.exe")).to be == true
    expect($mystring.include?("Rebuild done.")).to be == true    
  end
  it 'With file again build' do
    
    FileUtils.rm_rf("spec/testdata/root1/lib3/src/x.cpp")
    File.open("spec/testdata/root1/lib3/src/x.cpp", 'w') { |file| file.write("int i = 2;\n") }
    
    Bake.options = Options.new(["-m", "spec/testdata/root1/main", "-b", "rel_test"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()
    
    expect($mystring.include?("Compiling src/x.cpp")).to be == true
    expect($mystring.include?("Creating rel_test_main/liblib3.a")).to be == true
    expect($mystring.include?("Linking rel_test/main.exe")).to be == true
    expect($mystring.include?("Build done.")).to be == true    
  end

# todo: clobber test

end

end
