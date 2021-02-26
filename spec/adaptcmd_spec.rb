#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'bake/util'
require 'common/exit_helper'
require 'socket'
require 'fileutils'

module Bake

describe "AdaptCmd" do

  it 'No filter' do
    Bake.startBake("adaptCmd/main", ["--adapt", "ad1,spec/testdata/adaptCmd/Adapt.meta"])
    expect($mystring.include?("ad1all_main_test_main1")).to be == true
    expect($mystring.include?("ad2main_main_test_main1")).to be == true
    expect($mystring.include?("ad1all_main_test_main2")).to be == true
    expect($mystring.include?("ad2main_main_test_main2")).to be == true
    expect($mystring.include?("ad1all_lib_test_lib1")).to be == true
    expect($mystring.include?("ad1lib_lib_test_lib1")).to be == true
    expect($mystring.include?("ad1all_lib_test_lib2")).to be == true
    expect($mystring.include?("ad1lib_lib_test_lib2")).to be == true
  end

  it 'Empty filter' do
    Bake.startBake("adaptCmd/main", ["--adapt", "ad1[],spec/testdata/adaptCmd/Adapt.meta[]"])
    expect($mystring.include?("ad1all_main_test_main1")).to be == true
    expect($mystring.include?("ad2main_main_test_main1")).to be == true
    expect($mystring.include?("ad1all_main_test_main2")).to be == true
    expect($mystring.include?("ad2main_main_test_main2")).to be == true
    expect($mystring.include?("ad1all_lib_test_lib1")).to be == true
    expect($mystring.include?("ad1lib_lib_test_lib1")).to be == true
    expect($mystring.include?("ad1all_lib_test_lib2")).to be == true
    expect($mystring.include?("ad1lib_lib_test_lib2")).to be == true
  end

  it '__ALL__' do
    Bake.startBake("adaptCmd/main", ["--adapt", "ad1[__ALL__],spec/testdata/adaptCmd/Adapt.meta[__ALL__]"])
    expect($mystring.include?("ad1all_main_test_main1")).to be == true
    expect($mystring.include?("ad2main_main_test_main1")).to be == true
    expect($mystring.include?("ad1all_main_test_main2")).to be == true
    expect($mystring.include?("ad2main_main_test_main2")).to be == true
    expect($mystring.include?("ad1all_lib_test_lib1")).to be == true
    expect($mystring.include?("ad1lib_lib_test_lib1")).to be == true
    expect($mystring.include?("ad1all_lib_test_lib2")).to be == true
    expect($mystring.include?("ad1lib_lib_test_lib2")).to be == true
  end

  it '__MAIN__' do
    Bake.startBake("adaptCmd/main", ["--adapt", "ad1[__MAIN__],spec/testdata/adaptCmd/Adapt.meta[__MAIN__]"])
    expect($mystring.include?("ad1all_main_test_main1")).to be == true
    expect($mystring.include?("ad2main_main_test_main1")).to be == true
    expect($mystring.include?("ad1all_main_test_main2")).to be == true
    expect($mystring.include?("ad2main_main_test_main2")).to be == true
    expect($mystring.include?("ad1all_lib_test_lib1")).to be == false
    expect($mystring.include?("ad1lib_lib_test_lib1")).to be == false
    expect($mystring.include?("ad1all_lib_test_lib2")).to be == false
    expect($mystring.include?("ad1lib_lib_test_lib2")).to be == false
  end

  it 'main' do
    Bake.startBake("adaptCmd/main", ["--adapt", "ad1[main],spec/testdata/adaptCmd/Adapt.meta[main]"])
    expect($mystring.include?("ad1all_main_test_main1")).to be == true
    expect($mystring.include?("ad2main_main_test_main1")).to be == true
    expect($mystring.include?("ad1all_main_test_main2")).to be == true
    expect($mystring.include?("ad2main_main_test_main2")).to be == true
    expect($mystring.include?("ad1all_lib_test_lib1")).to be == false
    expect($mystring.include?("ad1lib_lib_test_lib1")).to be == false
    expect($mystring.include?("ad1all_lib_test_lib2")).to be == false
    expect($mystring.include?("ad1lib_lib_test_lib2")).to be == false
  end

  it 'liStart' do
    Bake.startBake("adaptCmd/main", ["--adapt", "ad1[li*],spec/testdata/adaptCmd/Adapt.meta[li*]"])
    expect($mystring.include?("ad1all_main_test_main1")).to be == false
    expect($mystring.include?("ad2main_main_test_main1")).to be == false
    expect($mystring.include?("ad1all_main_test_main2")).to be == false
    expect($mystring.include?("ad2main_main_test_main2")).to be == false
    expect($mystring.include?("ad1all_lib_test_lib1")).to be == true
    expect($mystring.include?("ad1lib_lib_test_lib1")).to be == true
    expect($mystring.include?("ad1all_lib_test_lib2")).to be == true
    expect($mystring.include?("ad1lib_lib_test_lib2")).to be == true
  end

  it 'lib;main' do
    Bake.startBake("adaptCmd/main", ["--adapt", "ad1[lib;main],spec/testdata/adaptCmd/Adapt.meta[lib;main]"])
    expect($mystring.include?("ad1all_main_test_main1")).to be == true
    expect($mystring.include?("ad2main_main_test_main1")).to be == true
    expect($mystring.include?("ad1all_main_test_main2")).to be == true
    expect($mystring.include?("ad2main_main_test_main2")).to be == true
    expect($mystring.include?("ad1all_lib_test_lib1")).to be == true
    expect($mystring.include?("ad1lib_lib_test_lib1")).to be == true
    expect($mystring.include?("ad1all_lib_test_lib2")).to be == true
    expect($mystring.include?("ad1lib_lib_test_lib2")).to be == true
  end

  it 'lib;other' do
    Bake.startBake("adaptCmd/main", ["--adapt", "ad1[lib;other],spec/testdata/adaptCmd/Adapt.meta[lib;other]"])
    expect($mystring.include?("ad1all_main_test_main1")).to be == false
    expect($mystring.include?("ad2main_main_test_main1")).to be == false
    expect($mystring.include?("ad1all_main_test_main2")).to be == false
    expect($mystring.include?("ad2main_main_test_main2")).to be == false
    expect($mystring.include?("ad1all_lib_test_lib1")).to be == true
    expect($mystring.include?("ad1lib_lib_test_lib1")).to be == true
    expect($mystring.include?("ad1all_lib_test_lib2")).to be == true
    expect($mystring.include?("ad1lib_lib_test_lib2")).to be == true
  end

  it 'other' do
    Bake.startBake("adaptCmd/main", ["--adapt", "ad1[other],spec/testdata/adaptCmd/Adapt.meta[other]"])
    expect($mystring.include?("ad1all_main_test_main1")).to be == false
    expect($mystring.include?("ad2main_main_test_main1")).to be == false
    expect($mystring.include?("ad1all_main_test_main2")).to be == false
    expect($mystring.include?("ad2main_main_test_main2")).to be == false
    expect($mystring.include?("ad1all_lib_test_lib1")).to be == false
    expect($mystring.include?("ad1lib_lib_test_lib1")).to be == false
    expect($mystring.include?("ad1all_lib_test_lib2")).to be == false
    expect($mystring.include?("ad1lib_lib_test_lib2")).to be == false
  end

end

end
