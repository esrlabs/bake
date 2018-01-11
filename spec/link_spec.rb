#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'socket'
require 'fileutils'

module Bake

describe "link" do

  it 'touch externalLib' do
    Bake.startBake("simple/main", ["test_ok"])
    expect($mystring.split("Linking").length).to be == 2
    expect(ExitHelper.exit_code).to be == 0
    Bake.startBake("simple/main", ["test_ok"])
    expect($mystring.split("Linking").length).to be == 2
    expect(ExitHelper.exit_code).to be == 0
    Bake.startBake("simple/main", ["test_old"])
    expect($mystring.split("Linking").length).to be == 3
    expect(ExitHelper.exit_code).to be == 0
    Bake.startBake("simple/main", ["test_old"])
    expect($mystring.split("Linking").length).to be == 3
    expect(ExitHelper.exit_code).to be == 0
    sleep(1.1)
    FileUtils.touch("spec/testdata/simple/lib/build/test_ok_main_test_ok/liblib.a")
    Bake.startBake("simple/main", ["test_old"])
    expect($mystring.split("Linking").length).to be == 4
    expect(ExitHelper.exit_code).to be == 0
  end

end

end
