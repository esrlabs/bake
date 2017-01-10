#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'bake/util'
require 'common/exit_helper'
require 'socket'
require 'fileutils'
require 'common/utils'

module Bake

describe "Local Adapt" do

  it 'with external adapt' do
    Bake.startBake("localAdapt/main1", ["--adapt", "gcc"])

    expect($mystring.include?("WINDOWS ADAPT1 lib")).to be == (Utils::OS.name == "Windows")
    expect($mystring.include?("LINUX ADAPT1 lib")).to be == (Utils::OS.name == "Linux")
    expect($mystring.include?("MAC ADAPT1 lib")).to be == (Utils::OS.name == "Mac")
    expect($mystring.include?("ADAPT2 lib")).to be == true
    expect($mystring.include?("ADAPT3 lib")).to be == true
    expect($mystring.include?("ADAPT4 lib")).to be == false
    expect($mystring.include?("ADAPT5 lib")).to be == false
    expect($mystring.include?("WINDOWS ADAPT1 main1")).to be == (Utils::OS.name == "Windows")
    expect($mystring.include?("LINUX ADAPT1 main1")).to be == (Utils::OS.name == "Linux")
    expect($mystring.include?("MAC ADAPT1 main1")).to be == (Utils::OS.name == "Mac")
    expect($mystring.include?("ADAPT2 main1")).to be == true
    expect($mystring.include?("ADAPT3 main1")).to be == false
    expect($mystring.include?("ADAPT4 main1")).to be == false
    expect($mystring.include?("ADAPT5 main1")).to be == true
  end

  it 'without external adapt' do
    Bake.startBake("localAdapt/main1", ["test2"])

    expect($mystring.include?("ADAPT1 lib")).to be == false
    expect($mystring.include?("ADAPT2 lib")).to be == true
    expect($mystring.include?("ADAPT3 lib")).to be == true
    expect($mystring.include?("ADAPT4 lib")).to be == false
    expect($mystring.include?("ADAPT5 lib")).to be == false
    expect($mystring.include?("ADAPT1 main1")).to be == false
    expect($mystring.include?("ADAPT2 main1")).to be == true
    expect($mystring.include?("ADAPT3 main1")).to be == false
    expect($mystring.include?("ADAPT4 main1")).to be == false
    expect($mystring.include?("ADAPT5 main1")).to be == true
  end

  it 'conditions are anded' do
    Bake.startBake("localAdapt/com", ["test"])
    expect($mystring.include?("And1")).to be == true
    expect($mystring.include?("And2")).to be == false
  end

  it 'read main data before using it for adapt' do
    Bake.startBake("localAdapt/com", ["test"])
    expect($mystring.include?("nosources/src")).to be == true
    expect($mystring.include?("generated/src")).to be == false
  end

  it 'wildcards' do
    Bake.startBake("localAdapt/com", ["test"])
    expect($mystring.include?("Wildcard01")).to be == true
    expect($mystring.include?("Wildcard02")).to be == false
    expect($mystring.include?("Wildcard03")).to be == false
    expect($mystring.include?("Wildcard04")).to be == true
    expect($mystring.include?("Wildcard05")).to be == true
    expect($mystring.include?("Wildcard06")).to be == false
    expect($mystring.include?("Wildcard07")).to be == false
    expect($mystring.include?("Wildcard08")).to be == true
    expect($mystring.include?("Wildcard09")).to be == true
    expect($mystring.include?("Wildcard10")).to be == false
    expect($mystring.include?("Wildcard11")).to be == false
    expect($mystring.include?("Wildcard12")).to be == true
    expect($mystring.include?("Wildcard13")).to be == true
    expect($mystring.include?("Wildcard14")).to be == false
    expect($mystring.include?("Wildcard15")).to be == false
    expect($mystring.include?("Wildcard16")).to be == true
  end

  it 'change dt and adapt sub' do
    Bake.startBake("localAdapt/main2", ["test_extend_dt"])
    expect($mystring.include?("EXTEND_DIAB")).to be == true
    expect($mystring.include?("EXTEND_GCC")).to be == true
  end

end

end
