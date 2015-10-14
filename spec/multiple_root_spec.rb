#!/usr/bin/env ruby

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'
require 'helper'

module Bake

describe "Multiple root" do
  
  it 'single root' do
    expect(File.exists?("spec/testdata/root1/main/build_test/main.exe")).to be == false
    Bake.startBake("root1/main", ["test"])
    expect(ExitHelper.exit_code).to be > 0
    expect($mystring.split("Project.meta not found").length).to be == 2
  end
  
  it 'both roots' do
    expect(File.exists?("spec/testdata/root1/main/build_test/main.exe")).to be == false
    Bake.startBake("root1/main", ["test", "-w", "spec/testdata/root1", "-w", "spec/testdata/root2"])
    expect(File.exists?("spec/testdata/root1/main/build_test/main.exe")).to be == true
  end
  
  it 'wrong root' do
    expect(File.exists?("spec/testdata/root1/main/build_test/main.exe")).to be == false
    expect { Bake.startBake("root1/main", ["test", "-w", "spec/testdata/root1", "-w", "spec/testdata/root2/lib3"]) }.to raise_error(SystemExit)
    expect(ExitHelper.exit_code).to be > 0
    expect($mystring.split("lib3 does not exist").length).to be == 2
  end  
  
  it 'forgotten root' do
    expect(File.exists?("spec/testdata/root1/main/build_test/main.exe")).to be == false
    Bake.startBake("root1/main", ["test", "-w", "spec/testdata/root1"])
    expect(ExitHelper.exit_code).to be > 0    
    expect($mystring.split("Error: lib2/Project.meta not found").length).to be == 2
  end   
 
  it 'invalid root' do
    expect(File.exists?("spec/testdata/root1/main/build_test/main.exe")).to be == false
    expect { Bake.startBake("root1/main", ["test", "-w", "spec/testdata/GIBTS_DOCH_GAR_NICHT"]) }.to raise_error(SystemExit)
    expect($mystring.split("Error: Directory spec/testdata/GIBTS_DOCH_GAR_NICHT does not exist").length).to be == 2
  end    
  
  it 'auto root overwritten wrong' do
    expect(File.exists?("spec/testdata/root1/mainAutoRoot/build_test/mainAutoRoot.exe")).to be == false
    Bake.startBake("root1/mainAutoRoot", ["test", "-w", "spec/testdata/root1"])
    expect($mystring.include?("Error: lib2")).to be == true
    expect(File.exists?("spec/testdata/root1/mainAutoRoot/build_test/mainAutoRoot.exe")).to be == false
  end  
  
  it 'auto root overwritten right' do
    expect(File.exists?("spec/testdata/root1/mainAutoRoot/build_test/mainAutoRoot.exe")).to be == false
    Bake.startBake("root1/mainAutoRoot", ["test", "-w", "spec/testdata/root1", "-w", "spec/testdata/root2"])
    expect(File.exists?("spec/testdata/root1/mainAutoRoot/build_test/mainAutoRoot.exe")).to be == true
  end  

  it 'auto root' do
    expect(File.exists?("spec/testdata/root1/mainAutoRoot/build_test/mainAutoRoot.exe")).to be == false
    Bake.startBake("root1/mainAutoRoot", ["test"])
    expect(File.exists?("spec/testdata/root1/mainAutoRoot/build_test/mainAutoRoot.exe")).to be == true
  end
  
  it 'Roots.bake' do
    Bake.startBake("rrmeta/a/b/c/d", ["test"])
    expect(ExitHelper.exit_code).to be == 0
  end
  
end

end
