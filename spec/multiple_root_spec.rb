#!/usr/bin/env ruby

require 'common/version'

require 'tocxx'
require 'bake/options/options'
require 'imported/utils/exit_helper'
require 'imported/utils/cleanup'
require 'fileutils'
require 'helper'

module Bake

describe "Multiple root" do
  
  it 'single root' do
    expect(File.exists?("spec/testdata/root1/main/test/main.exe")).to be == false
    
    Bake.options = Options.new(["-m", "spec/testdata/root1/main", "-b", "test"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    expect { tocxx.doit() }.to raise_error(ExitHelperException)
  end
  
  it 'both roots' do
    expect(File.exists?("spec/testdata/root1/main/test/main.exe")).to be == false
    
    Bake.options = Options.new(["-m", "spec/testdata/root1/main", "-b", "test", "-w", "spec/testdata/root1", "-w", "spec/testdata/root2"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()

    expect(File.exists?("spec/testdata/root1/main/test/main.exe")).to be == true
  end
  
  it 'root multiple define' do
    expect(File.exists?("spec/testdata/root1/main/test/main.exe")).to be == false
    
    Bake.options = Options.new(["-m", "spec/testdata/root1/main", "-b", "test", "-w", "spec/testdata/root2", "-w", "spec/testdata/root1"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()

    expect(File.exists?("spec/testdata/root1/main/test/main.exe")).to be == true
  end
  
  it 'wrong root' do
    expect(File.exists?("spec/testdata/root1/main/test/main.exe")).to be == false
    
    Bake.options = Options.new(["-m", "spec/testdata/root1/main", "-b", "test", "-w", "spec/testdata/root1", "-w", "spec/testdata/root2/lib3"])
    expect { Bake.options.parse_options() }.to raise_error(ExitHelperException)
    
    expect($mystring.split("lib3 does not exist").length).to be == 2
  end  
  
  it 'forgotten root' do
    expect(File.exists?("spec/testdata/root1/main/test/main.exe")).to be == false
    
    Bake.options = Options.new(["-m", "spec/testdata/root1/main", "-b", "test", "-w", "spec/testdata/root1"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
  expect { tocxx.doit() }.to raise_error(ExitHelperException)
    
    expect($mystring.split("Error: lib2/Project.meta not found").length).to be == 2
  end   
 
  it 'invalid root' do
    expect(File.exists?("spec/testdata/root1/main/test/main.exe")).to be == false
    
    Bake.options = Options.new(["-m", "spec/testdata/root1/main", "-b", "test", "-w", "spec/testdata/GIBTS_DOCH_GAR_NICHT"])
    expect { Bake.options.parse_options() }.to raise_error(ExitHelperException)
    
    expect($mystring.split("Error: Directory spec/testdata/GIBTS_DOCH_GAR_NICHT does not exist").length).to be == 2
  end    

end

end
