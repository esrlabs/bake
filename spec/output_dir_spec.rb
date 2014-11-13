#!/usr/bin/env ruby

require 'bake/version'

require 'tocxx'
require 'bake/options'
require 'imported/utils/exit_helper'
require 'imported/utils/cleanup'
require 'fileutils'
require 'helper'

module Bake

def self.start(opt)
  options = Options.new(opt)
  options.parse_options()
  tocxx = Bake::ToCxx.new(options)
  tocxx.doit()
  tocxx.start()
end

describe "OutputDir" do
  
  def doesExist(prefix, main, lib1, lib2, should)
    expect(File.exists?(prefix+"/"+main+"/main.exe")).to be == should
    expect(File.exists?(prefix+"/"+main+"/src/a.o")).to be == should
    expect(File.exists?(prefix+"/"+lib1+"/liblib1.a")).to be == should
    expect(File.exists?(prefix+"/"+lib1+"/src/b.o")).to be == should
    expect(File.exists?(prefix+"/"+lib2+"/liblib2.a")).to be == should
    expect(File.exists?(prefix+"/"+lib2+"/src/c.o")).to be == should
  end
  

  before(:each) do
    SpecHelper.clean_testdata_build("outDir","main","test*")
    SpecHelper.clean_testdata_build("outDir","lib1","test*")
    SpecHelper.clean_testdata_build("outDir","lib2","test*")
    SpecHelper.clean_testdata_build("outDir",".","test*")

    if Utils::OS.windows?
      r = Dir.glob("C:/temp/testOutDir*")
    else
      r = Dir.glob("/tmp/testOutDir*")
    end
    r.each { |f| FileUtils.rm_rf(f) }
    
  end
  
  it 'Toolchain Relative Output Dir' do
    doesExist("spec/testdata/outDir", "main/testOut1", "testOut2", "lib1/testOut3", false)
    opt = ["-m", "spec/testdata/outDir/main", "-b", "testTcRel"]
    Bake::start(opt)
    doesExist("spec/testdata/outDir", "main/testOut1", "testOut2", "lib1/testOut3", true)
    
    Utils.cleanup_rake
    opt << "-c"
    Bake::start(opt)
    doesExist("spec/testdata/outDir", "main/testOut1", "testOut2", "lib1/testOut3", false)
  end
  
  it 'DefaultToolchain and Toolchain Relative Output Dir' do
    doesExist("spec/testdata/outDir", "main/testOut1", "testOut2", "lib1/testOut3", false)
    opt = ["-m", "spec/testdata/outDir/main", "-b", "testDtcTcRel"]
    Bake::start(opt)
    doesExist("spec/testdata/outDir", "main/testOut1", "testOut2", "lib1/testOut3", true)
    
    Utils.cleanup_rake
    opt << "-c"
    Bake::start(opt)
    doesExist("spec/testdata/outDir", "main/testOut1", "testOut2", "lib1/testOut3", false)
  end  
 
  it 'DefaultToolchain Relative Output Dir' do
    doesExist("spec/testdata/outDir", "main/testOutY", "lib1/testOutY", "lib2/testOutY", false)
    opt = ["-m", "spec/testdata/outDir/main", "-b", "testDtcRel"]
    Bake::start(opt)
    doesExist("spec/testdata/outDir", "main/testOutY", "lib1/testOutY", "lib2/testOutY", true)
    
    Utils.cleanup_rake
    opt << "-c"
    Bake::start(opt)
    doesExist("spec/testdata/outDir", "main/testOutY", "lib1/testOutY", "lib2/testOutY", false)
  end 
  
  it 'DefaultToolchain Relative Output Dir Proj' do
    doesExist("spec/testdata/outDir/main/testOutProj", ".", ".", ".", false)
    opt = ["-m", "spec/testdata/outDir/main", "-b", "testDtcRelProj"]
    Bake::start(opt)
    doesExist("spec/testdata/outDir/main/testOutProj", ".", ".", ".", true)
    
    Utils.cleanup_rake
    opt << "-c"
    Bake::start(opt)
    doesExist("spec/testdata/outDir/main/testOutProj", ".", ".", ".", false)
  end   
  
  it 'DefaultToolchain Relative Output Dir Var' do
    doesExist("spec/testdata/outDir",
      "main/testVar/main/main/testOutVar",
      "lib1/testVar/main/lib1/testOutVar",
      "lib2/testVar/main/lib2/testOutVar", false)

    opt = ["-m", "spec/testdata/outDir/main", "-b", "testDtcRelVar"]
    Bake::start(opt)
    doesExist("spec/testdata/outDir",
      "main/testVar/main/main/testOutVar",
      "lib1/testVar/main/lib1/testOutVar",
      "lib2/testVar/main/lib2/testOutVar", true)
      
    Utils.cleanup_rake
    opt << "-c"
    Bake::start(opt)
    doesExist("spec/testdata/outDir",
      "main/testVar/main/main/testOutVar",
      "lib1/testVar/main/lib1/testOutVar",
      "lib2/testVar/main/lib2/testOutVar", false)
  end  
  
  
  it 'Toolchain Absolute Output Dir' do
    doesExist(Utils::OS.windows? ? "C:/temp" : "/tmp", "testOutDirA", "testOutDirB", "testOutDirC", false)
    opt = ["-m", "spec/testdata/outDir/main", "-b", "testTcAbs"]
    Bake::start(opt)
    doesExist(Utils::OS.windows? ? "C:/temp" : "/tmp", "testOutDirA", "testOutDirB", "testOutDirC", true)
    
    Utils.cleanup_rake
    opt << "-c"
    Bake::start(opt)
    doesExist(Utils::OS.windows? ? "C:/temp" : "/tmp", "testOutDirA", "testOutDirB", "testOutDirC", false)
  end  
  
  it 'DefaultToolchain Absolute Output Dir' do
    doesExist(Utils::OS.windows? ? "C:/temp/testOutDirD" : "/tmp/testOutDirD", ".", ".", ".", false)
    opt = ["-m", "spec/testdata/outDir/main", "-b", "testDtcAbs"]
    Bake::start(opt)
    doesExist(Utils::OS.windows? ? "C:/temp/testOutDirD" : "/tmp/testOutDirD", ".", ".", ".", true)
    
    Utils.cleanup_rake
    opt << "-c"
    Bake::start(opt)
    doesExist(Utils::OS.windows? ? "C:/temp/testOutDirD" : "/tmp/testOutDirD", ".", ".", ".", false)
  end    

  it 'DefaultToolchain Absolute Output Dir Different Drive' do
    
    if Utils::OS.windows?
      `subst t: C:/temp` 
          
      doesExist("T:/testOutDirE", ".", ".", ".", false)
      opt = ["-m", "spec/testdata/outDir/main", "-b", "testDtcAbsDD"]
      Bake::start(opt)
      doesExist("T:/testOutDirE", ".", ".", ".", true)

      Utils.cleanup_rake
      opt << "-c"
      Bake::start(opt)
      doesExist("T:/testOutDirE", ".", ".", ".", false)
            
      `subst t: /D`
    end
  end  
  
  
end





end
