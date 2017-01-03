#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'bake/util'
require 'common/exit_helper'
require 'socket'
require 'fileutils'

module Bake

describe "Echo" do

  it 'off' do
    Bake.startBake("env/main", ["test_C3"])
    expect(ExitHelper.exit_code).to be == 0
    expect($mystring.include?("ruby printEnv")).to be == false
    expect($mystring.include?("echo From")).to be == false
    expect($mystring.include?("make all")).to be == false
    expect($mystring.include?("From bake")).to be == true
    expect($mystring.include?("From subprocess")).to be == true
    expect($mystring.include?("echo echo on")).to be == true
    expect($mystring.include?("echo echo wrong")).to be == true
  end

  it 'v3' do
    Bake.startBake("env/main", ["test_C3", "-v3"])
    expect(ExitHelper.exit_code).to be == 0
    expect($mystring.include?("ruby printEnv")).to be == true
    expect($mystring.include?("echo From")).to be == true
    expect($mystring.include?("make all")).to be == true
    expect($mystring.include?("From bake")).to be == true
    expect($mystring.include?("From subprocess")).to be == true
    expect($mystring.include?("echo echo on")).to be == true
    expect($mystring.include?("echo echo wrong")).to be == true
  end

end

end
