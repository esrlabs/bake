#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'bake/util'
require 'common/exit_helper'
require 'socket'
require 'fileutils'

require 'common/ext/stdout'

module Bake

describe "Verbose" do

  # a lot more to be tested

  it 'Do not suppress building line' do
    Bake.startBake("simple/main", ["test_ok"])
    expect($mystring.include?("**** Building 1 of 2: lib (test_ok) ****")).to be == true
    expect($mystring.include?("**** Building 2 of 2: main (test_ok) ****")).to be == true
    expect($mystring.include?("Building done.")).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'Suppress building line' do
    Bake.startBake("simple/main", ["test_ok", "-nb"])
    expect($mystring.include?("**** Building 1 of 2: lib (test_ok) ****")).to be == false
    expect($mystring.include?("**** Building 2 of 2: main (test_ok) ****")).to be == false
    expect($mystring.include?("Building done.")).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end

end

end
