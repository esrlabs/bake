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

end

end
