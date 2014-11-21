#!/usr/bin/env ruby

require 'common/version'

require 'tocxx'
require 'bake/options/options'
require 'bake/util'
require 'imported/utils/exit_helper'
require 'socket'
require 'imported/utils/cleanup'
require 'fileutils'
require 'helper'

require 'imported/ext/stdout'

module Bake

describe "Makefile" do

  it 'builds' do
    Bake.options = Options.new(["-m", "spec/testdata/make/main", "test"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()
    expect($mystring.include?("make all -j")).to be == true
    expect($mystring.include?("Build done.")).to be == true
  end
  
  it 'cleans' do
    Bake.options = Options.new(["-m", "spec/testdata/make/main", "test", "-c"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()
    expect($mystring.include?("Clean done.")).to be == true
  end
  
end

end
