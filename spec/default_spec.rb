#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'

module Bake

describe "Default" do

  it 'lib explicit config' do
    Bake.startBake("default/libD", ["--rebuild", "testL1A"])
    expect($mystring.include?("libD (testL1A)")).to be == true
    expect($mystring.include?("testL1B")).to be == false
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'lib default config' do
    Bake.startBake("default/libD", ["--rebuild"])
    expect($mystring.include?("libD (testL1B)")).to be == true
    expect($mystring.include?("testL1A")).to be == false
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'lib no default config' do
    Bake.startBake("default/libNoD", ["--rebuild"])
    expect($mystring.include?("* testL2A")).to be == true
    expect($mystring.include?("* testL2B")).to be == true
    expect($mystring.include?("* testL2C")).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'main sub default config' do
    Bake.startBake("default/mainD", ["--rebuild"])
    expect($mystring.include?("libD (testL1B)")).to be == true
    expect($mystring.include?("mainD (test2)")).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'sub no default config' do
    Bake.startBake("default/mainD", ["--rebuild", "test1"])
    expect($mystring.include?("mainD/Project.meta")).to be == true
    expect($mystring.include?("libNoD/Project.meta")).to be == true
    expect($mystring.include?("No default config")).to be == true
    expect(ExitHelper.exit_code).to be > 0
  end

  it 'main ref itself per default' do
    Bake.startBake("default/mainD", ["--rebuild", "test3"])
    expect($mystring.include?("libD (testL1B)")).to be == true
    expect($mystring.include?("mainD (test2)")).to be == true
    expect($mystring.include?("mainD (test3)")).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end

end

end
