#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'

module Bake

describe "Incs" do

  it 'inject_and_inherit' do
    Bake.startBake("incTest/main", ["test", "-v2", "--rebuild"])
    
    expect($mystring.include?("c1.d -I../../main/main1 -I../../main/main2 -I../child1/child1_1 -Ichild1_2 -Ichild1_3 -I../../main/main3 -o")).to be == true
    expect($mystring.include?("l.d -I../main/main1 -I../main/main2 -Ilib1 -Ilib2 -I../sub/child1/child1_1 -I../sub/child1/child1_2 -I../child2/child2_1 -I../main/main3 -o")).to be == true
    expect($mystring.include?("m.d -Imain1 -Imain2 -Imain3 -Imain4 -I../sub/child1/child1_1 -I../sub/child1/child1_2 -I../child2/child2_1 -o")).to be == true
  end
  
  it 'merging' do
    Bake.startBake("incTest/main", ["test_main", "-v2", "--rebuild"])
    
    expect($mystring.include?("l.d -I../main/main3 -I../main/main4 -Ilib3 -Ilib1 -Ilib4 -Ilib2 -I../main/main2 -I../main/main1 -o")).to be == true
    expect($mystring.include?("m.d -Imain1 -Imain2 -Imain3 -Imain4 -I../lib/lib3 -I../lib/lib1 -o")).to be == true
  end
  
end

end
