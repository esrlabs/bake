#!/usr/bin/env ruby



require 'bake/version'

require 'tocxx'
require 'bake/options'
require 'imported/utils/exit_helper'
require 'imported/utils/cleanup'
require 'fileutils'
require 'helper'

module Bake

ExitHelper.enable_exit_test

describe "Export" do
  
  before(:each) do
    sleep 1
  end
  
  it 'With file rebuild' do
    FileUtils.rm_rf("spec/testdata/root1/lib3/src/x.cpp")
    File.open("spec/testdata/root1/lib3/src/x.cpp", 'w') { |file| file.write("int i = 2;\n") }
    
    options = Options.new(["-m", "spec/testdata/root1/main", "-b", "rel_test", "--rebuild"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()    
    
    expect($mystring.include?("Compiling src/x.cpp")).to be == true
    expect($mystring.include?("Creating rel_test_main/liblib3.a")).to be == true
    expect($mystring.include?("Linking rel_test/main.exe")).to be == true
    expect($mystring.include?("Rebuild done.")).to be == true
  end
  
  it 'With file build' do
    options = Options.new(["-m", "spec/testdata/root1/main", "-b", "rel_test"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()    
    
    expect($mystring.include?("Compiling src/x.cpp")).to be == false
    expect($mystring.include?("liblib3.a")).to be == false
    expect($mystring.include?("Linking rel_test/main.exe")).to be == false
    expect($mystring.include?("Build done.")).to be == true
  end  
  
  it 'Without file rebuild' do
    
    FileUtils.rm_rf("spec/testdata/root1/lib3/src/x.cpp")
    
    options = Options.new(["-m", "spec/testdata/root1/main", "-b", "rel_test", "--rebuild"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()    
    
    expect($mystring.include?("Compiling src/x.cpp")).to be == false
    expect($mystring.include?("liblib3.a")).to be == false
    expect($mystring.include?("Linking rel_test/main.exe")).to be == true
    expect($mystring.include?("Rebuild done.")).to be == true
  end
  it 'Without file clean' do
    
    options = Options.new(["-m", "spec/testdata/root1/main", "-b", "rel_test", "-c"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()   
    
    expect($mystring.include?("Clean done.")).to be == true
  end
  it 'Without file build' do
    
    options = Options.new(["-m", "spec/testdata/root1/main", "-b", "rel_test"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    
    expect($mystring.include?("Compiling src/x.cpp")).to be == false
    expect($mystring.include?("liblib3.a")).to be == false
    expect($mystring.include?("Linking rel_test/main.exe")).to be == true
    expect($mystring.include?("Build done.")).to be == true
  end
  it 'Without file lib' do
    
    options = Options.new(["-m", "spec/testdata/root1/main", "-b", "rel_test", "-p", "lib3"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    
    expect($mystring.include?("Compiling src/x.cpp")).to be == false
    expect($mystring.include?("liblib3.a")).to be == false
    expect($mystring.include?("Linking rel_test/main.exe")).to be == false
    expect($mystring.include?("Build done.")).to be == true
  end
  it 'Without file lib rebuild' do
    
    options = Options.new(["-m", "spec/testdata/root1/main", "-b", "rel_test", "-p", "lib3", "--rebuild"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    
    expect($mystring.include?("Compiling src/x.cpp")).to be == false
    expect($mystring.include?("liblib3.a")).to be == false
    expect($mystring.include?("Linking rel_test/main.exe")).to be == false
    expect($mystring.include?("Rebuild done.")).to be == true
  end
  it 'Without file main rebuild' do
    
    options = Options.new(["-m", "spec/testdata/root1/main", "-b", "rel_test", "-p", "main", "--rebuild"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
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
    
    options = Options.new(["-m", "spec/testdata/root1/main", "-b", "rel_test"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
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
