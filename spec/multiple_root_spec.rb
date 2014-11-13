#!/usr/bin/env ruby

require 'bake/version'

require 'tocxx'
require 'bake/options'
require 'imported/utils/exit_helper'
require 'imported/utils/cleanup'
require 'fileutils'
require 'helper'

module Bake

describe "Multiple root" do
  
  before(:each) do
    SpecHelper.clean_testdata_build("root1","main","test")
    SpecHelper.clean_testdata_build("root1","lib1","test_main")
    SpecHelper.clean_testdata_build("root2","lib2","test_main")
  end
  
  it 'single root' do
    expect(File.exists?("spec/testdata/root1/main/test/main.exe")).to be == false
    
    options = Options.new(["-m", "spec/testdata/root1/main", "-b", "test"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    expect { tocxx.doit() }.to raise_error(ExitHelperException)
  end
  
  it 'both roots' do
    expect(File.exists?("spec/testdata/root1/main/test/main.exe")).to be == false
    
    options = Options.new(["-m", "spec/testdata/root1/main", "-b", "test", "-w", "spec/testdata/root1", "-w", "spec/testdata/root2"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    expect(File.exists?("spec/testdata/root1/main/test/main.exe")).to be == true
  end
  
  it 'root multiple define' do
    expect(File.exists?("spec/testdata/root1/main/test/main.exe")).to be == false
    
    options = Options.new(["-m", "spec/testdata/root1/main", "-b", "test", "-w", "spec/testdata/root2", "-w", "spec/testdata/root1"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    expect(File.exists?("spec/testdata/root1/main/test/main.exe")).to be == true
  end
  
  it 'wrong root' do
    expect(File.exists?("spec/testdata/root1/main/test/main.exe")).to be == false
    
    options = Options.new(["-m", "spec/testdata/root1/main", "-b", "test", "-w", "spec/testdata/root1", "-w", "spec/testdata/root2/lib3"])
    expect { options.parse_options() }.to raise_error(ExitHelperException)
    
    expect($mystring.split("lib3 does not exist").length).to be == 2
  end  
  
  it 'forgotten root' do
    expect(File.exists?("spec/testdata/root1/main/test/main.exe")).to be == false
    
    options = Options.new(["-m", "spec/testdata/root1/main", "-b", "test", "-w", "spec/testdata/root1"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
  expect { tocxx.doit() }.to raise_error(ExitHelperException)
    
    expect($mystring.split("Error: lib2/Project.meta not found").length).to be == 2
  end   
 
  it 'invalid root' do
    expect(File.exists?("spec/testdata/root1/main/test/main.exe")).to be == false
    
    options = Options.new(["-m", "spec/testdata/root1/main", "-b", "test", "-w", "spec/testdata/GIBTS_DOCH_GAR_NICHT"])
    expect { options.parse_options() }.to raise_error(ExitHelperException)
    
    expect($mystring.split("Error: Directory spec/testdata/GIBTS_DOCH_GAR_NICHT does not exist").length).to be == 2
  end    

end

end
