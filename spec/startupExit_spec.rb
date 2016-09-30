#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'

module Bake

describe "StartupExit" do

  it 'passed' do
    Bake.startBake("startupExit/main", ["-b", "test1"])

    expect(ExitHelper.exit_code).to be == 0
    expect($mystring.include?("LIB_STARTUP1")).to be == true
    expect($mystring.include?("LIB_STARTUP2")).to be == true
    expect($mystring.include?("MAIN_STARTUP1")).to be == true
    expect($mystring.include?("MAIN_STARTUP1")).to be == true

    expect($mystring.include?("LIB_MAIN")).to be == true
    expect($mystring.include?("MAIN_MAIN")).to be == true

    expect($mystring.include?("LIB_EXIT1")).to be == true
    expect($mystring.include?("LIB_EXIT2")).to be == true
    expect($mystring.include?("MAIN_EXIT1")).to be == true
    expect($mystring.include?("MAIN_EXIT1")).to be == true
  end

  it 'error' do
    Bake.startBake("startupExit/main", ["-b", "test2"])

    expect(ExitHelper.exit_code).to be > 0
    expect($mystring.include?("LIB_STARTUP1")).to be == true
    expect($mystring.include?("LIB_STARTUP2")).to be == true
    expect($mystring.include?("MAIN_STARTUP1")).to be == true
    expect($mystring.include?("MAIN_STARTUP1")).to be == true

    expect($mystring.include?("LIB_MAIN")).to be == true
    expect($mystring.include?("MAIN_MAIN")).to be == true

    expect($mystring.include?("LIB_EXIT1")).to be == true
    expect($mystring.include?("LIB_EXIT2")).to be == true
    expect($mystring.include?("MAIN_EXIT1")).to be == true
    expect($mystring.include?("MAIN_EXIT1")).to be == true
  end

  it 'error stop' do
    Bake.startBake("startupExit/main", ["-b", "test2", "-r"])

    expect(ExitHelper.exit_code).to be > 0
    expect($mystring.include?("LIB_STARTUP1")).to be == true
    expect($mystring.include?("LIB_STARTUP2")).to be == true
    expect($mystring.include?("MAIN_STARTUP1")).to be == true
    expect($mystring.include?("MAIN_STARTUP1")).to be == true

    expect($mystring.include?("LIB_MAIN")).to be == false
    expect($mystring.include?("MAIN_MAIN")).to be == false

    expect($mystring.include?("LIB_EXIT1")).to be == true
    expect($mystring.include?("LIB_EXIT2")).to be == true
    expect($mystring.include?("MAIN_EXIT1")).to be == true
    expect($mystring.include?("MAIN_EXIT1")).to be == true
  end

  it 'exit code invalid' do
    Bake.startBake("startupExit/main", ["-b", "test3", "-r"])
    expect(ExitHelper.exit_code).to be > 0
    expect($mystring.include?("MAIN_WORKS")).to be == true
  end

  it 'exit code valid' do
    Bake.startBake("startupExit/main", ["-b", "test4", "-r"])
    expect(ExitHelper.exit_code).to be == 0
    expect($mystring.include?("MAIN_WORKS")).to be == true
  end

  it 'startup and exit if file compile' do
    Bake.startBake("startupExit/main", ["-b", "test5", "-f", "."])
    expect(ExitHelper.exit_code).to be == 0
    expect($mystring.include?("MAIN_STARTUP1")).to be == true
    expect($mystring.include?("MAIN_STARTUP2")).to be == true
    expect($mystring.include?("MAIN_EXIT1")).to be == true
    expect($mystring.include?("MAIN_EXIT2")).to be == true
  end

end

end
