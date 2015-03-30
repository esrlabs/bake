#!/usr/bin/env ruby

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'socket'
require 'fileutils'
require 'helper'

module Bake

describe "Set" do

  it 'value' do
    Bake.startBake("set", ["value"])
    expect(($mystring.include?"*GUGU*")).to be == true
  end

  it 'cmd' do
    Bake.startBake("set", ["cmd"])
    expect(($mystring.include?"*GAGA*")).to be == true
  end
  
  it 'cat' do
    Bake.startBake("set", ["cat"])
    expect(($mystring.include?"*MYTEST ABC*")).to be == true
  end  

  it 'arti' do
    Bake.startBake("set", ["arti"])
    expect(($mystring.include?"arti/*GAGA*")).to be == true
  end
  
  it 'triple' do
    Bake.startBake("set", ["triple"])
    expect(($mystring.include?"*GAGAGUGUHUHU*")).to be == true
  end
  
  it 'recursive' do
    Bake.startBake("set", ["recursive"])
    expect(($mystring.include?"**GUGU*-HUHU *GUGU*.elf*")).to be == true
    expect(($mystring.include?"recursive/HUHU *GUGU*.elf")).to be == true
  end
  
  it 'no cmd' do
    Bake.startBake("set_set/A", ["test"])
    expect(($mystring.include?"Project A TestA   A")).to be == true
    expect(($mystring.include?"Project B TestA TestB  B")).to be == true
    expect(($mystring.include?"Project C TestA  TestC C")).to be == true
  end

  it 'cmd A' do
    Bake.startBake("set_set/A", ["test", "--set", "a=X"])
    expect(($mystring.include?"Project A X   A")).to be == true
    expect(($mystring.include?"Project B X TestB  B")).to be == true
    expect(($mystring.include?"Project C X  TestC C")).to be == true
  end
  
  it 'cmd B' do
    Bake.startBake("set_set/A", ["test", "--set", "b=X"])
    expect(($mystring.include?"Project A TestA X  A")).to be == true
    expect(($mystring.include?"Project B TestA X  B")).to be == true
    expect(($mystring.include?"Project C TestA X TestC C")).to be == true
  end
  
  it 'flag' do
    Bake.startBake("set", ["testFlag", "-v2"])
    expect(($mystring.include?"SUB-O3")).to be == true
    expect(($mystring.include?"SUBtestFlagSub")).to be == true
    expect(($mystring.include?"MAIN-O3")).to be == true
    expect(($mystring.include?"MAINtestFlag")).to be == true
    
    expect(($mystring.include?"-set")).to be == false
    expect(($mystring.split("-DX=").length)).to be == 3
    
    expect(($mystring.include?"main.d -O2 -DXtestFlagSubX")).to be == true
    expect(($mystring.include?"main.d -DXtestFlagX")).to be == true
    
    expect(($mystring.include?"-DtestFlagSub")).to be == true
    expect(($mystring.include?"-DtestFlag ")).to be == false

    expect(($mystring.include?" -O3")).to be == false
    
    expect(($mystring.split("GAGA").length)).to be == 2
  end  
  
  it 'cmd does not work' do
    Bake.startBake("set", ["cmdBroken"])
    expect(($mystring.include?"echo **")).to be == true
    expect(($mystring.include?"will be set to \"\"")).to be == true
  end 
  
  it 'setenv' do
    Bake.startBake("set", ["setEnv"])
    expect(($mystring.include?"IT_WORKS")).to be == true
  end 
      
end

end
