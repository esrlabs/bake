#!/usr/bin/env ruby

require 'bake/version'

require 'tocxx'
require 'bake/options'
require 'imported/utils/exit_helper'
require 'socket'
require 'imported/utils/cleanup'
require 'fileutils'
require 'helper'

module Bake

describe "..in ex lib" do
  
  it 'with search=true' do
    options = Options.new(["-m", "spec/testdata/exLibBug/sub", "-b", "Debug", "--rebuild"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    expect(($mystring.split("Rebuild done.").length)).to be == 2
	
    options = Options.new(["-m", "spec/testdata/exLibBug/main", "-b", "test1", "--rebuild"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    expect(($mystring.split("Rebuild done.").length)).to be == 3
  end

  it 'with search=false' do
    options = Options.new(["-m", "spec/testdata/exLibBug/sub", "-b", "Debug", "--rebuild"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    expect(($mystring.split("Rebuild done.").length)).to be == 2
	
    options = Options.new(["-m", "spec/testdata/exLibBug/main", "-b", "test2", "--rebuild"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    expect(($mystring.split("Rebuild done.").length)).to be == 3
  end
  
  it 'with searchPath' do
    options = Options.new(["-m", "spec/testdata/exLibBug/sub", "-b", "Debug", "--rebuild"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    expect(($mystring.split("Rebuild done.").length)).to be == 2
	
    options = Options.new(["-m", "spec/testdata/exLibBug/main", "-b", "test3", "--rebuild"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    expect(($mystring.split("Rebuild done.").length)).to be == 3
  end  

  
end

end
