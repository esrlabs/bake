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

describe "..in ex lib" do
  
  it 'with search=true' do
    Bake.options = Options.new(["-m", "spec/testdata/exLibBug/sub", "-b", "Debug", "--rebuild"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()
    expect(($mystring.split("Rebuild done.").length)).to be == 2
	
    Bake.options = Options.new(["-m", "spec/testdata/exLibBug/main", "-b", "test1", "--rebuild"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()
    expect(($mystring.split("Rebuild done.").length)).to be == 3
  end

  it 'with search=false' do
    Bake.options = Options.new(["-m", "spec/testdata/exLibBug/sub", "-b", "Debug", "--rebuild"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()
    expect(($mystring.split("Rebuild done.").length)).to be == 2
	
    Bake.options = Options.new(["-m", "spec/testdata/exLibBug/main", "-b", "test2", "--rebuild"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()
    expect(($mystring.split("Rebuild done.").length)).to be == 3
  end
  
  it 'with searchPath' do
    Bake.options = Options.new(["-m", "spec/testdata/exLibBug/sub", "-b", "Debug", "--rebuild"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()
    expect(($mystring.split("Rebuild done.").length)).to be == 2
	
    Bake.options = Options.new(["-m", "spec/testdata/exLibBug/main", "-b", "test3", "--rebuild"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.doit()
    tocxx.start()
    expect(($mystring.split("Rebuild done.").length)).to be == 3
  end  

  
end

end
