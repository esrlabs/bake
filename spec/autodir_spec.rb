#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'socket'
require 'fileutils'

module Bake

describe "autodir" do

  it 'without no_autodir' do
    Bake.startBake("noAutodir/main", ["-b", "test", "--rebuild"])
    expect($mystring.split("Rebuilding failed.").length).to be == 2
  end

  it 'with no_autodir' do
    Bake.startBake("noAutodir/main", ["-b", "test", "--no-autodir", "--rebuild"])
    expect($mystring.split("Rebuilding done.").length).to be == 2
  end

  it 'without w' do
    Bake.startBake("wPlusRoots/a/c", [])
    expect($mystring.include?("TESTB_D")).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'without w to main' do
    Bake.startBake("wPlusRoots/a/c", ["-w", "spec/testdata/wPlusRoots/a/c"])
    expect($mystring.include?("TESTB_D")).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'without w to e' do
    Bake.startBake("wPlusRoots/a/c", ["-w", "spec/testdata/wPlusRoots/e"])
    expect($mystring.include?("TESTB_E")).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end

end

end
