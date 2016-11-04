#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'socket'
require 'fileutils'

module Bake

describe "Config Change" do

  def fixConfigs
    x = File.read("spec/testdata/configchanged/main/Project.meta")
    x.gsub!("Flags add: \"-DGAGA\"", "# TEST")
    File.write("spec/testdata/configchanged/main/Project.meta", x)

    x = File.read("spec/testdata/configchanged/lib/Project.meta")
    x.gsub!("Flags add: \"-DGUGU\"", "# TEST")
    File.write("spec/testdata/configchanged/lib/Project.meta", x)
  end

  before(:all) do
    ENV["CXX"] = "g++"
    ENV["AR"] = "ar"
    $noCleanTestData = true
    fixConfigs
  end

  after(:all) do
    $noCleanTestData = false
    fixConfigs
  end

  before(:each) do
    sleep 1.1 # needed for timestamp tests
  end

  it 'Regular Build GCC_ENV' do
    Bake.startBake("configchanged/main", ["Debug", "--rebuild"])
    expect($mystring.include?("main"+Bake::Toolchain.outputEnding)).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'Again Build GCC_ENV' do
    Bake.startBake("configchanged/main", ["Debug"])
    expect($mystring.include?("Debug/main"+Bake::Toolchain.outputEnding)).to be == false
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'Change Compiler Flags GCC_ENV' do
    ENV["CXXFLAGS"] = "-DGAGA"
    Bake.startBake("configchanged/main", ["Debug"])
    expect($mystring.include?("Compiling src/x.cpp")).to be == true
    expect($mystring.include?("Creating build/lib_main_Debug/liblib.a")).to be == true
    expect($mystring.include?("Linking build/Debug/main"+Bake::Toolchain.outputEnding)).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'Change Archiver Flags GCC_ENV' do
    ENV["ARFLAGS"] = "-s"
    Bake.startBake("configchanged/main", ["Debug"])
    expect($mystring.include?("Compiling src/x.cpp")).to be == false
    expect($mystring.include?("Creating build/lib_main_Debug/liblib.a")).to be == true
    expect($mystring.include?("Linking build/Debug/main"+Bake::Toolchain.outputEnding)).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'Change Linker Flags GCC_ENV' do
    ENV["LDFLAGS"] = "-L src"
    Bake.startBake("configchanged/main", ["Debug"])
    expect($mystring.include?("Compiling src/x.cpp")).to be == false
    expect($mystring.include?("Creating build/lib_main_Debug/liblib.a")).to be == false
    expect($mystring.include?("Linking build/Debug/main"+Bake::Toolchain.outputEnding)).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'Regular Build GCC' do
    Bake.startBake("configchanged/main", ["Test", "--rebuild"])
    expect($mystring.include?("main"+Bake::Toolchain.outputEnding)).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'Again Build GCC' do
    Bake.startBake("configchanged/main", ["Test"])
    expect($mystring.include?("Test/main"+Bake::Toolchain.outputEnding)).to be == false
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'Touch config files GCC' do
    FileUtils.touch("spec/testdata/configchanged/main/Project.meta")
    FileUtils.touch("spec/testdata/configchanged/lib/Project.meta")
    Bake.startBake("configchanged/main", ["Test"])
    expect($mystring.include?("Test/main"+Bake::Toolchain.outputEnding)).to be == false
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'Change main config file GCC' do
    x = File.read("spec/testdata/configchanged/main/Project.meta")
    x.gsub!("# TEST", "Flags add: \"-DGAGA\"")
    sleep(1)
    File.write("spec/testdata/configchanged/main/Project.meta", x)
    Bake.startBake("configchanged/main", ["Test"])
    expect($mystring.include?("Compiling src/x.cpp")).to be == true
    expect($mystring.include?("Creating build/lib_main_Test/liblib.a")).to be == true
    expect($mystring.include?("Linking build/Test/main"+Bake::Toolchain.outputEnding)).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'Change lib config file GCC' do
    x = File.read("spec/testdata/configchanged/lib/Project.meta")
    x.gsub!("# TEST", "Flags add: \"-DGUGU\"")
    sleep(1)
    File.write("spec/testdata/configchanged/lib/Project.meta", x)
    Bake.startBake("configchanged/main", ["Test"])
    expect($mystring.include?("Compiling src/x.cpp")).to be == true
    expect($mystring.include?("Creating build/lib_main_Test/liblib.a")).to be == true
    expect($mystring.include?("Linking build/Test/main"+Bake::Toolchain.outputEnding)).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'Again Build 2 GCC' do
    Bake.startBake("configchanged/main", ["Test"])
    expect($mystring.include?("Test/main"+Bake::Toolchain.outputEnding)).to be == false
    expect(ExitHelper.exit_code).to be == 0
  end

end

end
