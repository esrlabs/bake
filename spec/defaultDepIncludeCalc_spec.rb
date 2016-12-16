#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'

module Bake

describe "DefaultDepIncludeCalc" do

  it 'secondDefault' do
    Bake.startBake("defaultDepIncludeCalc/main", ["test1", "-v2"])
    expect(ExitHelper.exit_code).to be == 0
    expect($mystring.include?("build/test1/src/main.d -I../lib/a -I../uds/b -I../uds/c -Id -o build/test1/src/main.o src/main.cpp")).to be == true
  end

  it 'firstDefault' do
    Bake.startBake("defaultDepIncludeCalc/main", ["test2", "-v2"])
    expect(ExitHelper.exit_code).to be == 0
    expect($mystring.include?("build/test2/src/main.d -I../lib/a -I../uds/b -I../uds/c -Id -o build/test2/src/main.o src/main.cpp")).to be == true
  end

  it 'noneDefault' do
    Bake.startBake("defaultDepIncludeCalc/main", ["test3", "-v2"])
    expect(ExitHelper.exit_code).to be == 0
    expect($mystring.include?("build/test3/src/main.d -I../lib/a -I../uds/b -I../uds/c -Id -o build/test3/src/main.o src/main.cpp")).to be == true
  end

  it 'bothDefault' do
    Bake.startBake("defaultDepIncludeCalc/main", ["test4", "-v2"])
    expect(ExitHelper.exit_code).to be == 0
    expect($mystring.include?("build/test4/src/main.d -I../lib/a -I../uds/b -I../uds/c -Id -o build/test4/src/main.o src/main.cpp")).to be == true
  end

end

end
