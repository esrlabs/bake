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
  
  before(:all) do
  end

  after(:all) do
  end

  before(:each) do
    Utils.cleanup_rake
    sleep 1
    
    $mystring=""
    $sstring=StringIO.open($mystring,"w+")
    $stdoutbackup=$stdout
    $stdout=$sstring
  end
  
  after(:each) do
    $stdout=$stdoutbackup
    ExitHelper.reset_exit_code
  end

  it 'With file rebuild' do
    FileUtils.rm_rf("spec/testdata/root1/lib3/src/x.cpp")
    File.open("spec/testdata/root1/lib3/src/x.cpp", 'w') { |file| file.write("int i = 2;\n") }
    
    options = Options.new(["-m", "spec/testdata/root1/main", "-b", "rel_test", "--rebuild"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()    
    
    $mystring.include?("Compiling src/x.cpp").should == true
    $mystring.include?("Creating rel_test_main/liblib3.a").should == true
    $mystring.include?("Linking rel_test/main.exe").should == true
    $mystring.include?("Rebuild done.").should == true
  end
  
  it 'With file build' do
    options = Options.new(["-m", "spec/testdata/root1/main", "-b", "rel_test"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()    
    
    $mystring.include?("Compiling src/x.cpp").should == false
    $mystring.include?("liblib3.a").should == false
    $mystring.include?("Linking rel_test/main.exe").should == false
    $mystring.include?("Build done.").should == true
  end  
  
  it 'Without file rebuild' do
    
    FileUtils.rm_rf("spec/testdata/root1/lib3/src/x.cpp")
    
    options = Options.new(["-m", "spec/testdata/root1/main", "-b", "rel_test", "--rebuild"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()    
    
    $mystring.include?("Compiling src/x.cpp").should == false
    $mystring.include?("liblib3.a").should == false
    $mystring.include?("Linking rel_test/main.exe").should == true
    $mystring.include?("Rebuild done.").should == true
  end
  it 'Without file clean' do
    
    options = Options.new(["-m", "spec/testdata/root1/main", "-b", "rel_test", "-c"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()   
    
    $mystring.include?("Clean done.").should == true
  end
  it 'Without file build' do
    
    options = Options.new(["-m", "spec/testdata/root1/main", "-b", "rel_test"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    
    $mystring.include?("Compiling src/x.cpp").should == false
    $mystring.include?("liblib3.a").should == false
    $mystring.include?("Linking rel_test/main.exe").should == true
    $mystring.include?("Build done.").should == true
  end
  it 'Without file lib' do
    
    options = Options.new(["-m", "spec/testdata/root1/main", "-b", "rel_test", "-p", "lib3"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    
    $mystring.include?("Compiling src/x.cpp").should == false
    $mystring.include?("liblib3.a").should == false
    $mystring.include?("Linking rel_test/main.exe").should == false
    $mystring.include?("Build done.").should == true
  end
  it 'Without file lib rebuild' do
    
    options = Options.new(["-m", "spec/testdata/root1/main", "-b", "rel_test", "-p", "lib3", "--rebuild"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    
    $mystring.include?("Compiling src/x.cpp").should == false
    $mystring.include?("liblib3.a").should == false
    $mystring.include?("Linking rel_test/main.exe").should == false
    $mystring.include?("Rebuild done.").should == true
  end
  it 'Without file main rebuild' do
    
    options = Options.new(["-m", "spec/testdata/root1/main", "-b", "rel_test", "-p", "main", "--rebuild"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    $mystring.include?("Compiling src/x.cpp").should == false
    $mystring.include?("liblib3.a").should == false
    $mystring.include?("Linking rel_test/main.exe").should == true
    $mystring.include?("Rebuild done.").should == true    
  end
  it 'With file again build' do
    
    FileUtils.rm_rf("spec/testdata/root1/lib3/src/x.cpp")
    File.open("spec/testdata/root1/lib3/src/x.cpp", 'w') { |file| file.write("int i = 2;\n") }
    
    options = Options.new(["-m", "spec/testdata/root1/main", "-b", "rel_test"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    
    $mystring.include?("Compiling src/x.cpp").should == true
    $mystring.include?("Creating rel_test_main/liblib3.a").should == true
    $mystring.include?("Linking rel_test/main.exe").should == true
    $mystring.include?("Build done.").should == true    
  end

# todo: clobber test

end

end
