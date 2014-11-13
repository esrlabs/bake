#!/usr/bin/env ruby

require 'bake/version'

require 'tocxx'
require 'bake/options'
require 'imported/utils/exit_helper'
require 'imported/utils/cleanup'
require 'fileutils'
require 'helper'

module Bake

describe "Building" do
  
  before(:each) do
    SpecHelper.clean_testdata_build("cache","main","test")
    SpecHelper.clean_testdata_build("cache","lib1","test_main")
  end
  
  it 'workspace' do
    expect(File.exists?("spec/testdata/cache/main/test/main.exe")).to be == false
    
    options = Options.new(["-m", "spec/testdata/cache/main", "-b", "test", "-v2"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    expect(File.exists?("spec/testdata/cache/main/test/main.exe")).to be == true
    
    expect($mystring.split("PREMAIN").length).to be == 3
    expect($mystring.split("POSTMAIN").length).to be == 3
    
    expect($mystring.include?("../lib1/test_main/liblib1.a makefile/dummy.a")).to be == true # makefile lib shall be put to the end of the lib string
  end

  it 'single lib' do
    expect(File.exists?("spec/testdata/cache/main/test/main.exe")).to be == false
    
    options = Options.new(["-p", "lib1", "-m", "spec/testdata/cache/main", "-b", "test"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    expect(File.exists?("spec/testdata/cache/lib1/test_main/liblib1.a")).to be == true
    expect(File.exists?("spec/testdata/cache/main/test/main.exe")).to be == false
    
    expect($mystring.split("PRELIB1").length).to be == 3
    expect($mystring.split("POSTLIB1").length).to be == 3    
  end  

  it 'single exe should fail' do
    expect(File.exists?("spec/testdata/cache/lib1/test_main/src/lib1.o")).to be == false
    expect(File.exists?("spec/testdata/cache/lib1/test_main/liblib1.a")).to be == false

    expect(File.exists?("spec/testdata/cache/main/test/src/main.o")).to be == false
    expect(File.exists?("spec/testdata/cache/main/test/main.exe")).to be == false
    
    options = Options.new(["-m", "spec/testdata/cache/main", "-b", "test", "-p", "main"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    expect(File.exists?("spec/testdata/cache/lib1/test_main/src/lib1.o")).to be == false
    expect(File.exists?("spec/testdata/cache/lib1/test_main/liblib1.a")).to be == false

    expect(File.exists?("spec/testdata/cache/main/test/src/main.o")).to be == true
    expect(File.exists?("spec/testdata/cache/main/test/main.exe")).to be == false
    
    expect($mystring.split("PREMAIN").length).to be == 3
    expect($mystring.split("POSTMAIN").length).to be == 1 # means not executed cause exe build failed
    
    expect(ExitHelper.exit_code).to be > 0
  end  

  it 'single file' do
    expect(File.exists?("spec/testdata/cache/main/test/src/main.o")).to be == false
    expect(File.exists?("spec/testdata/cache/main/test/main.exe")).to be == false

    options = Options.new(["-m", "spec/testdata/cache/main", "-b", "test", "-f", "src/main.cpp"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    expect(File.exists?("spec/testdata/cache/main/test/src/main.o")).to be == true
    expect(File.exists?("spec/testdata/cache/main/test/main.exe")).to be == false
    
    expect(ExitHelper.exit_code).to be == 0
  end  

  it 'clean single file' do
    options = Options.new(["-m", "spec/testdata/cache/main", "-b", "test"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    
    expect(File.exists?("spec/testdata/cache/main/test/src/main.o")).to be == true
    expect(File.exists?("spec/testdata/cache/main/test/src/main.d")).to be == true
    expect(File.exists?("spec/testdata/cache/main/test/main.exe")).to be == true

    Utils.cleanup_rake

    options = Options.new(["-m", "spec/testdata/cache/main", "-b", "test", "-f", "src/main.cpp", "-c"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    
    expect(File.exists?("spec/testdata/cache/main/test/src/main.o")).to be == false
    expect(File.exists?("spec/testdata/cache/main/test/src/main.d")).to be == false
    expect(File.exists?("spec/testdata/cache/main/test/main.exe")).to be == true
    
    expect(ExitHelper.exit_code).to be == 0
  end  

  it 'clean single lib' do
    options = Options.new(["-m", "spec/testdata/cache/main", "-b", "test"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    expect(File.exists?("spec/testdata/cache/main/test")).to be == true
    expect(File.exists?("spec/testdata/cache/lib1/test_main")).to be == true
    expect(File.exists?("spec/testdata/cache/lib1/test_main/liblib1.a")).to be == true
    expect(File.exists?("spec/testdata/cache/main/test/main.exe")).to be == true

    Utils.cleanup_rake

    options = Options.new(["-m", "spec/testdata/cache/main", "-p", "lib1", "-b", "test", "-c"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    expect(File.exists?("spec/testdata/cache/main/test")).to be == true
    expect(File.exists?("spec/testdata/cache/lib1/test_main")).to be == false
    expect(File.exists?("spec/testdata/cache/lib1/test_main/liblib1.a")).to be == false
    expect(File.exists?("spec/testdata/cache/main/test/main.exe")).to be == true
    
    expect(ExitHelper.exit_code).to be == 0
  end
    
  it 'clean single lib' do
    options = Options.new(["-m", "spec/testdata/cache/main", "-b", "test"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    expect(File.exists?("spec/testdata/cache/main/test")).to be == true
    expect(File.exists?("spec/testdata/cache/lib1/test_main")).to be == true
    expect(File.exists?("spec/testdata/cache/lib1/test_main/liblib1.a")).to be == true
    expect(File.exists?("spec/testdata/cache/main/test/main.exe")).to be == true

    Utils.cleanup_rake

    options = Options.new(["-m", "spec/testdata/cache/main", "-b", "test", "-p", "main", "-c"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    expect(File.exists?("spec/testdata/cache/main/test")).to be == false
    expect(File.exists?("spec/testdata/cache/lib1/test_main")).to be == true
    expect(File.exists?("spec/testdata/cache/lib1/test_main/liblib1.a")).to be == true
    expect(File.exists?("spec/testdata/cache/main/test/main.exe")).to be == false
    
    expect(ExitHelper.exit_code).to be == 0
  end  
  
  it 'clobber' do
    options = Options.new(["-m", "spec/testdata/cache/main", "-b", "test"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    expect(File.exists?("spec/testdata/cache/main/.bake")).to be == true
    expect(File.exists?("spec/testdata/cache/lib1/.bake")).to be == true

    Utils.cleanup_rake

    options = Options.new(["-m", "spec/testdata/cache/main", "-b", "test", "--clobber"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    expect(File.exists?("spec/testdata/cache/main/.bake")).to be == false
    expect(File.exists?("spec/testdata/cache/lib1/.bake")).to be == false
  end    
  
  it 'clobber project only' do
    options = Options.new(["-m", "spec/testdata/cache/main", "-b", "test", "-p", "lib1"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    expect(File.exists?("spec/testdata/cache/main/.bake")).to be == true
    expect(File.exists?("spec/testdata/cache/lib1/.bake")).to be == true

    Utils.cleanup_rake

    options = Options.new(["-m", "spec/testdata/cache/main", "-b", "test", "-p", "lib1", "--clobber"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    expect(File.exists?("spec/testdata/cache/main/.bake")).to be == false
    expect(File.exists?("spec/testdata/cache/lib1/.bake")).to be == false
  end    

end

end
