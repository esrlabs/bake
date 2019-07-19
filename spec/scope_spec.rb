#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'socket'
require 'fileutils'

module Bake

describe "scope" do

  it 'toolchain just GCC' do
    Bake.startBake("scope/toolchain", ["test_GCC"])
    expect($mystring.include?("GCC_no")).to be == true
    expect($mystring.include?("GCC_old")).to be == true
    expect($mystring.include?("GCC_new")).to be == true
    expect($mystring.include?("GCC_both")).to be == true
    expect($mystring.include?("GCC23")).to be == false
    expect($mystring.include?("GCC234")).to be == false
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'toolchain also GCC2 and GCC3' do
    Bake.startBake("scope/toolchain", ["test_GCC23"])
    expect($mystring.include?("GCC_no")).to be == true
    expect($mystring.include?("GCC_old")).to be == true
    expect($mystring.include?("GCC_new")).to be == true
    expect($mystring.include?("GCC_both")).to be == true
    expect($mystring.include?("GCC23")).to be == true
    expect($mystring.include?("GCC234")).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'target z4a' do
    Bake.startBake("scope/target", ["test_z4a"])
    expect($mystring.include?("no_target")).to be == true
    expect($mystring.include?("target_z4a")).to be == true
    expect($mystring.include?("target_z4b")).to be == false
    expect($mystring.include?("target_z4ab")).to be == true
    expect($mystring.include?("target_wild_z4ab")).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'target z4a and z4b' do
    Bake.startBake("scope/target", ["test_z4ab"])
    expect($mystring.include?("no_target")).to be == true
    expect($mystring.include?("target_z4a")).to be == true
    expect($mystring.include?("target_z4b")).to be == true
    expect($mystring.include?("target_z4ab")).to be == true
    expect($mystring.include?("target_wild_z4ab")).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'target z4a and z4b in one string' do
    Bake.startBake("scope/target", ["test_z4abo"])
    expect($mystring.include?("no_target")).to be == true
    expect($mystring.include?("target_z4a")).to be == true
    expect($mystring.include?("target_z4b")).to be == true
    expect($mystring.include?("target_z4ab")).to be == true
    expect($mystring.include?("target_wild_z4ab")).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end
  
  it 'mix different scopes' do
    Bake.startBake("scope/mix", ["test"])
    expect($mystring.include?("GCC2_high")).to be == false
    expect($mystring.include?("GCC2_low")).to be == true
    expect($mystring.include?("GCC2_la")).to be == true
    expect($mystring.include?("GCC2_bl")).to be == false
    expect($mystring.include?("GCC2_hla")).to be == true
    expect($mystring.include?("GCC_hla")).to be == true
    expect($mystring.include?("GCC_test")).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end

end

end
