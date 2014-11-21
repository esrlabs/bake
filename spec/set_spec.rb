#!/usr/bin/env ruby

require 'common/version'

require 'tocxx'
require 'bake/options/options'
require 'imported/utils/exit_helper'
require 'socket'
require 'imported/utils/cleanup'
require 'fileutils'
require 'helper'

module Bake

describe "Set" do
  
  it 'value' do
    Bake.options = Options.new(["-m", "spec/testdata/set", "-b", "value"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()
    expect(($mystring.include?"*GUGU*")).to be == true
  end

  it 'cmd' do
    Bake.options = Options.new(["-m", "spec/testdata/set", "-b", "cmd"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()
    expect(($mystring.include?"*GAGA*")).to be == true
  end
  
  it 'cat' do
    Bake.options = Options.new(["-m", "spec/testdata/set", "-b", "cat"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()
    expect(($mystring.include?"*MYTEST ABC*")).to be == true
  end  

  it 'arti' do
    Bake.options = Options.new(["-m", "spec/testdata/set", "-b", "arti"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()
    expect(($mystring.include?"arti/*GAGA*")).to be == true
  end
  
  it 'triple' do
    Bake.options = Options.new(["-m", "spec/testdata/set", "-b", "triple"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()
    expect(($mystring.include?"*GAGAGUGUHUHU*")).to be == true
  end
  
  it 'recursive' do
    Bake.options = Options.new(["-m", "spec/testdata/set", "-b", "recursive"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()
    expect(($mystring.include?"**GUGU*-HUHU *GUGU*.elf*")).to be == true
    expect(($mystring.include?"recursive/HUHU *GUGU*.elf")).to be == true
  end
  
  it 'no cmd' do
    Bake.options = Options.new(["-m", "spec/testdata/set_set/A", "-b", "test"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()
    expect(($mystring.include?"Project A TestA   A")).to be == true
    expect(($mystring.include?"Project B TestA TestB  B")).to be == true
    expect(($mystring.include?"Project C TestA  TestC C")).to be == true
  end

  it 'cmd A' do
    Bake.options = Options.new(["-m", "spec/testdata/set_set/A", "-b", "test", "--set", "a=X"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()
    expect(($mystring.include?"Project A X   A")).to be == true
    expect(($mystring.include?"Project B X TestB  B")).to be == true
    expect(($mystring.include?"Project C X  TestC C")).to be == true
  end
  
  it 'cmd B' do
    Bake.options = Options.new(["-m", "spec/testdata/set_set/A", "-b", "test", "--set", "b=X"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()
    expect(($mystring.include?"Project A TestA X  A")).to be == true
    expect(($mystring.include?"Project B TestA X  B")).to be == true
    expect(($mystring.include?"Project C TestA X TestC C")).to be == true
  end
  
      
end

end
