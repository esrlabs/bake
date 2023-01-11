#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'

module Bake

describe "Prepro" do

  it 'build' do
    Bake.startBake("prepro/main", ["test", "--prepro"])

    expect(File.exist?("spec/testdata/prepro/main/build/test/src/main.i")).to be == true
    expect(File.exist?("spec/testdata/prepro/main/build/test/src/assembler.i")).to be == false

    expect(ExitHelper.exit_code).to be == 0
  end

  it 'abort on error first level' do
    Bake.startBake("prepro/main", ["test_error1", "-r"])
    expect($mystring.include?("STEP1")).to be == true
    expect($mystring.include?("STEP2")).to be == false
    expect($mystring.include?("STEP3")).to be == false
    expect($mystring.include?("STEP4")).to be == false
    expect($mystring.include?("STEPMAIN1")).to be == false
    expect($mystring.include?("STEPMAIN2")).to be == false
    expect($mystring.include?("Building failed")).to be == true
    expect(ExitHelper.exit_code).to be > 0
  end

  it 'abort on error second level' do
    Bake.startBake("prepro/main", ["test_error2", "-r"])
    expect($mystring.include?("STEP1")).to be == true
    expect($mystring.include?("STEP2")).to be == false
    expect($mystring.include?("STEP3")).to be == false
    expect($mystring.include?("STEP4")).to be == false
    expect($mystring.include?("STEPMAIN1")).to be == false
    expect($mystring.include?("STEPMAIN2")).to be == false
    expect($mystring.include?("Building failed")).to be == true
    expect(ExitHelper.exit_code).to be > 0
  end

  it 'not abort on error first level' do
    Bake.startBake("prepro/main", ["test_error1"])
    expect($mystring.include?("STEP1")).to be == true
    expect($mystring.include?("STEP2")).to be == false
    expect($mystring.include?("STEP3")).to be == false
    expect($mystring.include?("STEP4")).to be == false
    expect($mystring.include?("STEPMAIN1")).to be == false
    expect($mystring.include?("STEPMAIN2")).to be == false
    expect($mystring.include?("Building failed")).to be == true
    expect(ExitHelper.exit_code).to be > 0
  end

  it 'not abort on error second level' do
    Bake.startBake("prepro/main", ["test_error2"])
    expect($mystring.include?("STEP1")).to be == true
    expect($mystring.include?("STEP2")).to be == false
    expect($mystring.include?("STEP3")).to be == false
    expect($mystring.include?("STEP4")).to be == false
    expect($mystring.include?("STEPMAIN1")).to be == false
    expect($mystring.include?("STEPMAIN2")).to be == true
    expect($mystring.include?("Building failed")).to be == true
    expect(ExitHelper.exit_code).to be > 0
  end

end

end
