#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'

module Bake

describe "OutputDir" do

  def doesExist(prefix, main, lib1, lib2, should)
    expect(File.exist?(prefix+"/"+main+"/main"+Bake::Toolchain.outputEnding)).to be == should
    expect(File.exist?(prefix+"/"+main+"/src/a.o")).to be == should
    expect(File.exist?(prefix+"/"+lib1+"/liblib1.a")).to be == should
    expect(File.exist?(prefix+"/"+lib1+"/src/b.o")).to be == should
    expect(File.exist?(prefix+"/"+lib2+"/liblib2.a")).to be == should
    expect(File.exist?(prefix+"/"+lib2+"/src/c.o")).to be == should
  end


  before(:each) do
    if Utils::OS.windows?
      r = Dir.glob("C:/temp/testOutDir*")
    else
      r = Dir.glob("/tmp/testOutDir*")
    end
    r.each { |f| FileUtils.rm_rf(f) }
  end

  it 'Toolchain Relative Output Dir' do
    doesExist("spec/testdata/outDir", "main/testOut1", "testOut2", "lib1/testOut3", false)
    Bake.startBake("outDir/main", ["testTcRel"])
    doesExist("spec/testdata/outDir", "main/testOut1", "testOut2", "lib1/testOut3", true)
    expect($mystring.include?("echo from main 1: testOut1")).to be == true
    expect($mystring.include?("echo from main 2: ../testOut2")).to be == true

    Bake.startBake("outDir/main", ["testTcRel", "-c"])
    doesExist("spec/testdata/outDir", "main/testOut1", "testOut2", "lib1/testOut3", false)
  end

  it 'DefaultToolchain and Toolchain Relative Output Dir' do
    doesExist("spec/testdata/outDir", "main/testOut1", "testOut2", "lib1/testOut3", false)
    Bake.startBake("outDir/main", ["testDtcTcRel"])
    doesExist("spec/testdata/outDir", "main/testOut1", "testOut2", "lib1/testOut3", true)

    Bake.startBake("outDir/main", ["testDtcTcRel", "-c"])
    doesExist("spec/testdata/outDir", "main/testOut1", "testOut2", "lib1/testOut3", false)
  end

  it 'DefaultToolchain Relative Output Dir' do
    doesExist("spec/testdata/outDir", "main/testOutY", "lib1/testOutY", "lib2/testOutY", false)
    Bake.startBake("outDir/main", ["testDtcRel"])
    doesExist("spec/testdata/outDir", "main/testOutY", "lib1/testOutY", "lib2/testOutY", true)

    Bake.startBake("outDir/main", ["testDtcRel", "-c"])
    doesExist("spec/testdata/outDir", "main/testOutY", "lib1/testOutY", "lib2/testOutY", false)
  end

  it 'DefaultToolchain Relative Output Dir Proj' do
    doesExist("spec/testdata/outDir/main/testOutProj", ".", ".", ".", false)
    Bake.startBake("outDir/main", ["testDtcRelProj"])
    doesExist("spec/testdata/outDir/main/testOutProj", ".", ".", ".", true)

    Bake.startBake("outDir/main", ["testDtcRelProj", "-c"])
    doesExist("spec/testdata/outDir/main/testOutProj", ".", ".", ".", false)
  end

  it 'DefaultToolchain Relative Output Dir Var' do
    doesExist("spec/testdata/outDir",
      "main/testVar/main/main/testOutVar",
      "lib1/testVar/main/lib1/testOutVar",
      "lib2/testVar/main/lib2/testOutVar", false)
    Bake.startBake("outDir/main", ["testDtcRelVar"])
    doesExist("spec/testdata/outDir",
      "main/testVar/main/main/testOutVar",
      "lib1/testVar/main/lib1/testOutVar",
      "lib2/testVar/main/lib2/testOutVar", true)

    Bake.startBake("outDir/main", ["testDtcRelVar", "-c"])
    doesExist("spec/testdata/outDir",
      "main/testVar/main/main/testOutVar",
      "lib1/testVar/main/lib1/testOutVar",
      "lib2/testVar/main/lib2/testOutVar", false)
  end


  it 'Toolchain Absolute Output Dir' do
    doesExist(Utils::OS.windows? ? "C:/temp" : "/tmp", "testOutDirA", "testOutDirB", "testOutDirC", false)
    Bake.startBake("outDir/main", ["testTcAbs"])
    doesExist(Utils::OS.windows? ? "C:/temp" : "/tmp", "testOutDirA", "testOutDirB", "testOutDirC", true)

    Bake.startBake("outDir/main", ["testTcAbs", "-c"])
    doesExist(Utils::OS.windows? ? "C:/temp" : "/tmp", "testOutDirA", "testOutDirB", "testOutDirC", false)
  end

  it 'DefaultToolchain Absolute Output Dir' do
    doesExist(Utils::OS.windows? ? "C:/temp/testOutDirD" : "/tmp/testOutDirD", ".", ".", ".", false)
    Bake.startBake("outDir/main", ["testDtcAbs"])
    doesExist(Utils::OS.windows? ? "C:/temp/testOutDirD" : "/tmp/testOutDirD", ".", ".", ".", true)

    Bake.startBake("outDir/main", ["testDtcAbs", "-c"])
    doesExist(Utils::OS.windows? ? "C:/temp/testOutDirD" : "/tmp/testOutDirD", ".", ".", ".", false)
  end

  it 'DefaultToolchain Absolute Output Dir Different Drive' do

    if Utils::OS.windows?
      `subst t: C:/temp`

      doesExist("T:/testOutDirE", ".", ".", ".", false)
      Bake.startBake("outDir/main", ["testDtcAbsDD"])
      doesExist("T:/testOutDirE", ".", ".", ".", true)

      Bake.startBake("outDir/main", ["testDtcAbsDD", "-c"])
      doesExist("T:/testOutDirE", ".", ".", ".", false)

      `subst t: /D`
    end
  end

  it 'Variables in outputDir toolchain def' do
    Bake.startBake("outputDir2/main", [])
    expect($mystring.include?("lib: main/testMain/lib/testLib")).to be == true
    expect($mystring.include?("main: main/testMain/main/testMain")).to be == true
  end

  it 'OutputDirPostfix' do
    Bake.startBake("outputDirPostfix/main", [])
    expect($mystring.include?("test: build/test_abc")).to be == true
    expect($mystring.include?("test_dep: build/testdep_main_test_testdep")).to be == true
    expect(File.exist?("spec/testdata/outputDirPostfix/main/build/test_abc/libmain.a")).to be == true
    expect(File.exist?("spec/testdata/outputDirPostfix/main/build/testdep_main_test_testdep/libmain.a")).to be == true
  end

end





end
