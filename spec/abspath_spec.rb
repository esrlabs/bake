#!/usr/bin/env ruby

require 'helper'
require 'socket'
require 'fileutils'
require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'

module Bake

describe "abspaths" do

  it 'rel' do
    Bake.startBake("errorParser/error", ["test"])
    expect($mystring.include?("src/main.cpp:3")).to be == true
    expect($mystring.include?("spec/testdata/errorParser/error/src/main.cpp:3")).to be == false
  end
  it 'absOld' do
    Bake.startBake("errorParser/error", ["test", "--show_abs_paths"])
    expect($mystring.include?("spec/testdata/errorParser/error/src/main.cpp:3")).to be == true
  end
  it 'absNew' do
    Bake.startBake("errorParser/error", ["test", "--abs-paths"])
    expect($mystring.include?("spec/testdata/errorParser/error/src/main.cpp:3")).to be == true
  end

end

end
