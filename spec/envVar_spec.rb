#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'bake/util'
require 'common/exit_helper'
require 'socket'
require 'fileutils'

module Bake

describe "EnvVar" do

  it 'test' do
    Bake.startBake("env/main", ["test_C3"])
    expect(ExitHelper.exit_code).to be == 0
    expect($mystring.include?("From bake: val1")).to be == true
    expect($mystring.include?("From subprocess: val1")).to be == true
    expect($mystring.include?("From bake: val2")).to be == true
    expect($mystring.include?("From subprocess: val2")).to be == true
  end

end

end
