#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'bake/util'
require 'common/exit_helper'
require 'socket'
require 'fileutils'

module Bake

describe "Fileutil" do

  it 'sleep echo off' do
    ENV["FILEUTIL_TEST_OFF"] = "off"
    timeStart = Time.now
    Bake.startBake("steps/main", ["test2"])
    timeDiff = Time.now - timeStart

    expect(ExitHelper.exit_code).to be == 0
    expect(timeDiff).to be > 4
    expect(timeDiff).to be < 20
    expect($mystring.include?("Sleeping")).to be == false
  end

  it 'sleep echo on' do
    ENV["FILEUTIL_TEST_OFF"] = nil
    Bake.startBake("steps/main", ["test2"])
    expect(ExitHelper.exit_code).to be == 0
    expect($mystring.include?("Sleeping 5.0")).to be == true
  end


  it 'file operations echo off' do
    ENV["FILEUTIL_TEST_OFF"] = "off"
    Bake.startBake("steps/main", ["test1"])
    expect(ExitHelper.exit_code).to be == 0
    expect(File.exist?("spec/testdata/steps/main/test/a")).to be == true
    expect(File.exist?("spec/testdata/steps/main/test/x/b.txt")).to be == true
    expect(File.exist?("spec/testdata/steps/main/test/z.txt")).to be == true
    expect(File.exist?("spec/testdata/steps/main/test/g/b.txt")).to be == true
    expect(File.exist?("spec/testdata/steps/main/test/a/b")).to be == false
    expect($mystring.include?("Touching")).to be == false
    expect($mystring.include?("Moving")).to be == false
    expect($mystring.include?("Copying")).to be == false
    expect($mystring.include?("Removing")).to be == false
    expect($mystring.include?("Making")).to be == false
  end

  it 'file operations echo on' do
    ENV["FILEUTIL_TEST_OFF"] = nil
    Bake.startBake("steps/main", ["test1"])
    expect(ExitHelper.exit_code).to be == 0
    expect($mystring.include?("Touching")).to be == true
    expect($mystring.include?("Moving")).to be == true
    expect($mystring.include?("Copying")).to be == true
    expect($mystring.include?("Removing")).to be == true
    expect($mystring.include?("Making")).to be == true
  end

  it 'wildcards' do
    Bake.startBake("steps/main", ["test4"])
    expect(ExitHelper.exit_code).to be == 0
    expect(File.exist?("spec/testdata/steps/main/test/y/a.txt")).to be == true
    expect(File.exist?("spec/testdata/steps/main/test/y/b.txt")).to be == true
    expect(File.exist?("spec/testdata/steps/main/test/z/a.txt")).to be == true
    expect(File.exist?("spec/testdata/steps/main/test/z/y/b.txt")).to be == true
  end

  it 'no source' do
    Bake.startBake("steps/main", ["test5"])
    expect(ExitHelper.exit_code).to be > 0
    expect($mystring.include?("source of file-step must not be empty")).to be == true
  end
    
  it 'no target' do
    Bake.startBake("steps/main", ["test6"])
    expect(ExitHelper.exit_code).to be > 0
    expect($mystring.include?("target of file-step must not be empty")).to be == true
  end

end

end
