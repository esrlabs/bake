#!/usr/bin/env ruby

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'
require 'helper'

module Bake

describe "compiler" do
begin
  
  it 'dcc rebuild' do
    begin
      `dcc`
    rescue Exception
      fail "dcc not installed" # fail only once on non dcc systems
    end
    
    Bake.startBake("compiler/dcc", ["test", "--rebuild"])
    expect($mystring.include?("lib.cpp")).to be == true
    expect($mystring.include?("main.cpp")).to be == true
    expect($mystring.include?("libdcc.a")).to be == true
    expect($mystring.include?("dcc.elf")).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'dcc build' do
      begin
        `dcc`
        Bake.startBake("compiler/dcc", ["test"])
        expect($mystring.include?("lib.cpp")).to be == false
        expect($mystring.include?("main.cpp")).to be == false
        expect($mystring.include?("libdcc.a")).to be == false
        expect($mystring.include?("dcc.elf")).to be == false
        expect(ExitHelper.exit_code).to be == 0
      rescue Exception
      end
    end
  end
  
  it 'dcc touch' do
    begin
      `dcc`
      sleep 1.1
      FileUtils.touch("spec/testdata/compiler/dcc/include/inc1.h")
      
      Bake.startBake("compiler/dcc", ["test"])
      expect($mystring.include?("lib.cpp")).to be == false
      expect($mystring.include?("main.cpp")).to be == true
      expect($mystring.include?("libdcc.a")).to be == false
      expect($mystring.include?("dcc.elf")).to be == true
      expect(ExitHelper.exit_code).to be == 0
    rescue Exception
    end
  end

  it 'dcc dep' do
    begin
      `dcc`
      depStr = File.read("spec/testdata/compiler/dcc/test/src/main.d.bake")
      expect(depStr.include?("inc1.h")).to be == true
      expect(depStr.include?("inc 2.h")).to be == true
    rescue Exception
    end
  end
  
  it 'keil' do
    path = "spec/testdata/compiler/keil"
    Blocks::Compile.convert_depfile("#{path}/dep.d", "#{path}/test_conv_dep.d", "DIR", true)
    
    str = File.read("#{path}/test_conv_dep.d").split("\n")
    expect(str.include?("A/B.h")).to be == true
    expect(str.include?("c:/Program Files (x86)/Keilv1234/ARM/ARMCC/bin/../include/stdint.h")).to be == true
    expect(str.include?("../C/D/util/Utils.h")).to be == true
    expect(str.include?("A/VoiceManagerService.h")).to be == true
    expect(str.include?("../C/D/Service.h")).to be == true
    expect(str.include?("../C/D/os/Handler.h")).to be == true
    expect(str.length).to be == 6
  end
  

end

end
