#!/usr/bin/env ruby



require 'bake/version'

require 'tocxx'
require 'bake/options'
require 'imported/utils/exit_helper'
require 'socket'
require 'imported/utils/cleanup'
require 'fileutils'
require 'helper'

module Bake

ExitHelper.enable_exit_test

describe "Set" do
  
  after(:all) do
    ExitHelper.reset_exit_code
  end

  before(:each) do
    Utils.cleanup_rake
    $mystring=""
    $sstring=StringIO.open($mystring,"w+")
    $stdoutbackup=$stdout
    $stdout=$sstring
  end
  after(:each) do
    $stdout=$stdoutbackup
  end

  it 'value' do
    options = Options.new(["-m", "spec/testdata/set", "-b", "value"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    expect(($mystring.include?"*GUGU*")).to be == true
  end

  it 'cmd' do
    options = Options.new(["-m", "spec/testdata/set", "-b", "cmd"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    expect(($mystring.include?"*GAGA*")).to be == true
  end
  
  it 'cat' do
    options = Options.new(["-m", "spec/testdata/set", "-b", "cat"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    expect(($mystring.include?"*MYTEST ABC*")).to be == true
  end  

  it 'arti' do
    options = Options.new(["-m", "spec/testdata/set", "-b", "arti"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    expect(($mystring.include?"arti/*GAGA*")).to be == true
  end
  
  it 'triple' do
    options = Options.new(["-m", "spec/testdata/set", "-b", "triple"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    expect(($mystring.include?"*GAGAGUGUHUHU*")).to be == true
  end
  
  it 'recursive' do
    options = Options.new(["-m", "spec/testdata/set", "-b", "recursive"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    expect(($mystring.include?"**GUGU*-HUHU *GUGU*.elf*")).to be == true
    expect(($mystring.include?"recursive/HUHU *GUGU*.elf")).to be == true
  end
  
  it 'no cmd' do
    options = Options.new(["-m", "spec/testdata/set_set/A", "-b", "test"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    expect(($mystring.include?"Project A TestA   A")).to be == true
    expect(($mystring.include?"Project B TestA TestB  B")).to be == true
    expect(($mystring.include?"Project C TestA  TestC C")).to be == true
  end

  it 'cmd A' do
    options = Options.new(["-m", "spec/testdata/set_set/A", "-b", "test", "--set", "a=X"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    expect(($mystring.include?"Project A X   A")).to be == true
    expect(($mystring.include?"Project B X TestB  B")).to be == true
    expect(($mystring.include?"Project C X  TestC C")).to be == true
  end
  
  it 'cmd B' do
    options = Options.new(["-m", "spec/testdata/set_set/A", "-b", "test", "--set", "b=X"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    expect(($mystring.include?"Project A TestA X  A")).to be == true
    expect(($mystring.include?"Project B TestA X  B")).to be == true
    expect(($mystring.include?"Project C TestA X TestC C")).to be == true
  end
  
      
end

end
