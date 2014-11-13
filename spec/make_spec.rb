#!/usr/bin/env ruby

require 'bake/version'

require 'tocxx'
require 'bake/options'
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
    options = Options.new(["-m", "spec/testdata/make/main", "test"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    expect($mystring.include?("make all -j")).to be == true
    expect($mystring.include?("Build done.")).to be == true
  end
  
  it 'cleans' do
    options = Options.new(["-m", "spec/testdata/make/main", "test", "-c"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    expect($mystring.include?("Clean done.")).to be == true
  end
  
end

end
