#!/usr/bin/env ruby

require 'common/version'

require 'tocxx'
require 'bake/options/options'
require 'imported/utils/exit_helper'
require 'socket'
require 'imported/utils/cleanup'
require 'fileutils'
require 'helper'

module Bake

describe "autodir" do
  
  it 'without no_autodir' do
    Bake.options = Options.new(["-m", "spec/testdata/noAutodir/main", "-b", "test", "--rebuild"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()
    expect($mystring.split("Rebuild failed.").length).to be == 2
  end

  it 'with no_autodir' do
    Bake.options = Options.new(["-m", "spec/testdata/noAutodir/main", "-b", "test", "--no_autodir", "--rebuild"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()
    expect($mystring.split("Rebuild done.").length).to be == 2
  end
  
end

end
