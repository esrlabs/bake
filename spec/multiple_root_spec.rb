#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'

module Bake

describe "Multiple root" do

  it 'single root' do
    expect(File.exists?("spec/testdata/root1/main/build/test/main"+Bake::Toolchain.outputEnding)).to be == false
    Bake.startBake("root1/main", ["test"])
    expect(ExitHelper.exit_code).to be > 0
    expect($mystring.split("Project.meta not found").length).to be == 2
  end

  it 'both roots' do
    expect(File.exists?("spec/testdata/root1/main/build/test/main"+Bake::Toolchain.outputEnding)).to be == false
    Bake.startBake("root1/main", ["test", "-w", "spec/testdata/root1", "-w", "spec/testdata/root2", "--adapt", "nols"])
    expect(File.exists?("spec/testdata/root1/main/build/test/main"+Bake::Toolchain.outputEnding)).to be == true
  end

  it 'wrong root' do
    expect(File.exists?("spec/testdata/root1/main/build/test/main"+Bake::Toolchain.outputEnding)).to be == false
    expect { Bake.startBake("root1/main", ["test", "-w", "spec/testdata/root1", "-w", "spec/testdata/root2/lib3", "--adapt", "nols"]) }.to raise_error(SystemExit)
    expect(ExitHelper.exit_code).to be > 0
    expect($mystring.split("lib3 does not exist").length).to be == 2
  end

  it 'forgotten root' do
    expect(File.exists?("spec/testdata/root1/main/build/test/main"+Bake::Toolchain.outputEnding)).to be == false
    Bake.startBake("root1/main", ["test", "-w", "spec/testdata/root1", "--adapt", "nols"])
    expect(ExitHelper.exit_code).to be > 0
    expect($mystring.split("Error: lib2/Project.meta not found").length).to be == 2
  end

  it 'invalid root' do
    expect(File.exists?("spec/testdata/root1/main/build/test/main"+Bake::Toolchain.outputEnding)).to be == false
    expect { Bake.startBake("root1/main", ["test", "-w", "spec/testdata/GIBTS_DOCH_GAR_NICHT", "--adapt", "nols"]) }.to raise_error(SystemExit)
    expect($mystring.split("Error: Directory spec/testdata/GIBTS_DOCH_GAR_NICHT does not exist").length).to be == 2
  end

  it 'auto root overwritten wrong (but roots.bake is taken)' do
    expect(File.exists?("spec/testdata/root1/mainAutoRoot/build/test/mainAutoRoot"+Bake::Toolchain.outputEnding)).to be == false
    Bake.startBake("root1/mainAutoRoot", ["test", "-w", "spec/testdata/root1", "--adapt", "nols"])
    expect($mystring.include?("Building done")).to be == true
    expect(File.exists?("spec/testdata/root1/mainAutoRoot/build/test/mainAutoRoot"+Bake::Toolchain.outputEnding)).to be == true
  end

  it 'auto root overwritten right' do
    expect(File.exists?("spec/testdata/root1/mainAutoRoot/build/test/mainAutoRoot"+Bake::Toolchain.outputEnding)).to be == false
    Bake.startBake("root1/mainAutoRoot", ["test", "-w", "spec/testdata/root1", "-w", "spec/testdata/root2", "--adapt", "nols"])
    expect(File.exists?("spec/testdata/root1/mainAutoRoot/build/test/mainAutoRoot"+Bake::Toolchain.outputEnding)).to be == true
  end

  it 'auto root' do
    expect(File.exists?("spec/testdata/root1/mainAutoRoot/build/test/mainAutoRoot"+Bake::Toolchain.outputEnding)).to be == false
    Bake.startBake("root1/mainAutoRoot", ["test", "--adapt", "nols"])
    expect(File.exists?("spec/testdata/root1/mainAutoRoot/build/test/mainAutoRoot"+Bake::Toolchain.outputEnding)).to be == true
  end

  it 'roots.bake' do
    Bake.startBake("rrmeta/a/b/c/d", ["test"])
    expect(ExitHelper.exit_code).to be == 0
  end
  
  it 'roots.bake' do
    Bake.startBake("root1/mainRoots", ["test2", "-v2", "-w", "spec/testdata/root2", "-w", "spec/testdata/root2/lib2/ls"])

    expect($mystring.include?("g++ -c -MD -MF build/test1_mainRoots_test2/src/main1.d -I../../root2 -I../../root2/lib2/ls -o build/test1_mainRoots_test2/src/main1.o src/main1.cpp")).to be == true    
    expect($mystring.include?("g++ -c -MD -MF build/test2/src/main2.d -Iinclude -I../../root2 -I../../root2/lib2/ls -o build/test2/src/main2.o src/main2.cpp")).to be == true    

    expect(ExitHelper.exit_code).to be == 0
  end  

end

end
