#!/usr/bin/env ruby

require 'common/version'

require 'tocxx'
require 'bake/options/options'
require 'bake/util'
require 'imported/utils/exit_helper'
require 'socket'
require 'fileutils'
require 'helper'

require 'imported/ext/stdout'

module Bake

describe "Makefile" do

  it 'builds' do
    Bake.startBake("make/main", ["test"])
    expect($mystring.include?("make all")).to be == true
    expect($mystring.include?("Building done.")).to be == true
  end
  
  it 'cleans' do
    Bake.startBake("make/main",  ["test", "-c"])
    expect($mystring.include?("Cleaning done.")).to be == true
  end
  
end

end
