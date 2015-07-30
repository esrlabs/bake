#!/usr/bin/env ruby

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'
require 'helper'

module Bake

describe "Incs" do

  it 'infix_and_inherit' do
    Bake.startBake("incTest/main", ["test", "-v2", "--rebuild"])
    
    expect($mystring.include?("c1.d -Imain1 -Imain2 -Ichild1_1 -Ichild1_2 -Ichild1_3 -Imain3 -o")).to be == true
    expect($mystring.include?("c2.d -Imain1 -Imain2 -Ichild2_1 -Ichild2_2 -Imain3 -o")).to be == true
    expect($mystring.include?("l.d -Imain1 -Imain2 -Ilib1 -Ilib2 -Ichild1_1 -Ichild1_2 -Ichild2_1 -Imain3 -o")).to be == true
    expect($mystring.include?("m.d -Imain1 -Imain2 -Imain3 -Imain4 -Ichild1_1 -Ichild1_2 -Ichild2_1 -o")).to be == true
  end
  
  it 'merging' do
    Bake.startBake("incTest/main", ["test_main", "-v2", "--rebuild"])
    
    expect($mystring.include?("l.d -Imain3 -Imain4 -Ilib3 -Ilib1 -Ilib4 -Ilib2 -Imain2 -Imain1 -o")).to be == true
    expect($mystring.include?("m.d -Imain1 -Imain2 -Imain3 -Imain4 -Ilib3 -Ilib1 -o")).to be == true
  end
  
end

end
