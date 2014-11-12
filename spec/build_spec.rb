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

describe "Building" do
  
  before(:all) do
  end

  after(:all) do
  end

  before(:each) do
    Utils.cleanup_rake
    SpecHelper.clean_testdata_build("cache","main","test")
    SpecHelper.clean_testdata_build("cache","lib1","test_main")

    $mystring=""
    $sstring=StringIO.open($mystring,"w+")
    $stdoutbackup=$stdout
    $stdout=$sstring
  end
  
  after(:each) do
    $stdout=$stdoutbackup

    ExitHelper.reset_exit_code
  end

  it 'workspace' do
    File.exists?("spec/testdata/cache/main/test/main.exe").should == false
    
    options = Options.new(["-m", "spec/testdata/cache/main", "-b", "test", "-v2"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    File.exists?("spec/testdata/cache/main/test/main.exe").should == true
    
    $mystring.split("PREMAIN").length.should == 3
    $mystring.split("POSTMAIN").length.should == 3
    
    $mystring.include?("../lib1/test_main/liblib1.a makefile/dummy.a").should == true # makefile lib shall be put to the end of the lib string
  end

  it 'single lib' do
    File.exists?("spec/testdata/cache/main/test/main.exe").should == false
    
    options = Options.new(["-p", "lib1", "-m", "spec/testdata/cache/main", "-b", "test"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    File.exists?("spec/testdata/cache/lib1/test_main/liblib1.a").should == true
    File.exists?("spec/testdata/cache/main/test/main.exe").should == false
    
    $mystring.split("PRELIB1").length.should == 3
    $mystring.split("POSTLIB1").length.should == 3    
  end  

  it 'single exe should fail' do
    File.exists?("spec/testdata/cache/lib1/test_main/src/lib1.o").should == false
    File.exists?("spec/testdata/cache/lib1/test_main/liblib1.a").should == false

    File.exists?("spec/testdata/cache/main/test/src/main.o").should == false
    File.exists?("spec/testdata/cache/main/test/main.exe").should == false
    
    options = Options.new(["-m", "spec/testdata/cache/main", "-b", "test", "-p", "main"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    File.exists?("spec/testdata/cache/lib1/test_main/src/lib1.o").should == false
    File.exists?("spec/testdata/cache/lib1/test_main/liblib1.a").should == false

    File.exists?("spec/testdata/cache/main/test/src/main.o").should == true
    File.exists?("spec/testdata/cache/main/test/main.exe").should == false
    
    $mystring.split("PREMAIN").length.should == 3
    $mystring.split("POSTMAIN").length.should == 1 # means not executed cause exe build failed
    
    ExitHelper.exit_code.should > 0
  end  

  it 'single file' do
    File.exists?("spec/testdata/cache/main/test/src/main.o").should == false
    File.exists?("spec/testdata/cache/main/test/main.exe").should == false

    options = Options.new(["-m", "spec/testdata/cache/main", "-b", "test", "-f", "src/main.cpp"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    File.exists?("spec/testdata/cache/main/test/src/main.o").should == true
    File.exists?("spec/testdata/cache/main/test/main.exe").should == false
    
    ExitHelper.exit_code.should == 0
  end  

  it 'clean single file' do
    options = Options.new(["-m", "spec/testdata/cache/main", "-b", "test"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    
    File.exists?("spec/testdata/cache/main/test/src/main.o").should == true
    File.exists?("spec/testdata/cache/main/test/src/main.d").should == true
    File.exists?("spec/testdata/cache/main/test/main.exe").should == true

    Utils.cleanup_rake

    options = Options.new(["-m", "spec/testdata/cache/main", "-b", "test", "-f", "src/main.cpp", "-c"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    
    File.exists?("spec/testdata/cache/main/test/src/main.o").should == false
    File.exists?("spec/testdata/cache/main/test/src/main.d").should == false
    File.exists?("spec/testdata/cache/main/test/main.exe").should == true
    
    ExitHelper.exit_code.should == 0
  end  

  it 'clean single lib' do
    options = Options.new(["-m", "spec/testdata/cache/main", "-b", "test"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    File.exists?("spec/testdata/cache/main/test").should == true
    File.exists?("spec/testdata/cache/lib1/test_main").should == true
    File.exists?("spec/testdata/cache/lib1/test_main/liblib1.a").should == true
    File.exists?("spec/testdata/cache/main/test/main.exe").should == true

    Utils.cleanup_rake

    options = Options.new(["-m", "spec/testdata/cache/main", "-p", "lib1", "-b", "test", "-c"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    File.exists?("spec/testdata/cache/main/test").should == true
    File.exists?("spec/testdata/cache/lib1/test_main").should == false
    File.exists?("spec/testdata/cache/lib1/test_main/liblib1.a").should == false
    File.exists?("spec/testdata/cache/main/test/main.exe").should == true
    
    ExitHelper.exit_code.should == 0
  end
    
  it 'clean single lib' do
    options = Options.new(["-m", "spec/testdata/cache/main", "-b", "test"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    File.exists?("spec/testdata/cache/main/test").should == true
    File.exists?("spec/testdata/cache/lib1/test_main").should == true
    File.exists?("spec/testdata/cache/lib1/test_main/liblib1.a").should == true
    File.exists?("spec/testdata/cache/main/test/main.exe").should == true

    Utils.cleanup_rake

    options = Options.new(["-m", "spec/testdata/cache/main", "-b", "test", "-p", "main", "-c"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    File.exists?("spec/testdata/cache/main/test").should == false
    File.exists?("spec/testdata/cache/lib1/test_main").should == true
    File.exists?("spec/testdata/cache/lib1/test_main/liblib1.a").should == true
    File.exists?("spec/testdata/cache/main/test/main.exe").should == false
    
    ExitHelper.exit_code.should == 0
  end  
  
  it 'clobber' do
    options = Options.new(["-m", "spec/testdata/cache/main", "-b", "test"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    File.exists?("spec/testdata/cache/main/.bake").should == true
    File.exists?("spec/testdata/cache/lib1/.bake").should == true

    Utils.cleanup_rake

    options = Options.new(["-m", "spec/testdata/cache/main", "-b", "test", "--clobber"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    File.exists?("spec/testdata/cache/main/.bake").should == false
    File.exists?("spec/testdata/cache/lib1/.bake").should == false
  end    
  
  it 'clobber project only' do
    options = Options.new(["-m", "spec/testdata/cache/main", "-b", "test", "-p", "lib1"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    File.exists?("spec/testdata/cache/main/.bake").should == true
    File.exists?("spec/testdata/cache/lib1/.bake").should == true

    Utils.cleanup_rake

    options = Options.new(["-m", "spec/testdata/cache/main", "-b", "test", "-p", "lib1", "--clobber"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    File.exists?("spec/testdata/cache/main/.bake").should == false
    File.exists?("spec/testdata/cache/lib1/.bake").should == false
  end    

end

end
