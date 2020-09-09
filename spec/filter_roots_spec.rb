#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'bake/util'
require 'common/exit_helper'
require 'socket'
require 'fileutils'

module Bake

describe "Filter roots" do

  it 'no config' do
    Bake.startBake("filterRoots/main", [])
    expect(ExitHelper.exit_code).to be > 0
  end

  it 'first config' do
    Bake.startBake("filterRoots/main", ["--adapt", "ada2", "--do", "test1"])
    expect(ExitHelper.exit_code).to be == 0
    expect($mystring.include?("test1_cl")).to be == true
    expect($mystring.include?("test2_cl")).to be == false
    expect($mystring.include?("ada1_cl")).to be == false
    expect($mystring.include?("ada2_cl")).to be == false
  end

  it 'second config' do
    Bake.startBake("filterRoots/main", ["--adapt", "ada2", "--do", "test2"])
    expect(ExitHelper.exit_code).to be == 0
    expect($mystring.include?("test1_cl")).to be == false
    expect($mystring.include?("test2_cl")).to be == true
    expect($mystring.include?("ada1_cl")).to be == false
    expect($mystring.include?("ada2_cl")).to be == false
  end

  it 'first config one adapt' do
    Bake.startBake("filterRoots/main", ["--adapt", "ada2", "--do", "test1", "--do", "ada1"])
    expect(ExitHelper.exit_code).to be == 0
    expect($mystring.include?("test1_cl")).to be == true
    expect($mystring.include?("test2_cl")).to be == false
    expect($mystring.include?("ada1_cl")).to be == true
    expect($mystring.include?("ada2_cl")).to be == false
  end

  it 'second config two adapts' do
    Bake.startBake("filterRoots/main", ["--adapt", "ada2", "--do", "test2", "--do", "ada1" , "--do", "ada2"])
    expect(ExitHelper.exit_code).to be == 0
    expect($mystring.include?("test1_cl")).to be == false
    expect($mystring.include?("test2_cl")).to be == true
    expect($mystring.include?("ada1_cl")).to be == true
    expect($mystring.include?("ada2_cl")).to be == true
  end

end

end
