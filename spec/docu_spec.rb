#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'

module Bake

describe "Docu" do

  it 'inteDefault' do
    Bake.startBake("docu/main", ["testinteDefault", "--docu"])
    expect($mystring.include?("Docu_of_lib1")).to be == true
    expect($mystring.include?("Docu_of_main")).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'overwriteDefault' do
    Bake.startBake("docu/main", ["testoverwriteDefault", "--docu"])
    expect($mystring.include?("Docu_of_testself")).to be == true
    expect($mystring.include?("Docu_of_testoverwriteDefault")).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'onlySub' do
    Bake.startBake("docu/main", ["testonlySub", "--docu"])
    expect($mystring.include?("Docu_of_testself")).to be == true
    expect($mystring.include?("No documentation command specified")).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'broken' do
    Bake.startBake("docu/main", ["testbroken", "--docu"])
    expect($mystring.include?("kaputt")).to be == true
    expect($mystring.include?("No documentation command specified")).to be == true
    expect(ExitHelper.exit_code).to be > 0
  end

  it 'unbroken' do
    Bake.startBake("docu/main", ["testbroken", "-p", "main,testbroken", "--docu"])
    expect($mystring.include?("kaputt")).to be == false
    expect($mystring.include?("No documentation command specified")).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end

end

end
