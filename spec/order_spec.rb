#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'

module Bake

describe "Order" do

  it 'order of libs 1' do
    Bake.startBake("order/p1", ["test"])
    expect($mystring.include?("-l:u ../p2/build/test_p1_test/libp2.a -L../p2/sp2 -lc ../p2/makeIn2 -Lx1 -lx2 -la -L../p3/sp3 y1/y2 ../p3/makeIn3 -lb -Lu1 -l:u2 make1 make2")).to be == true
  end

  it 'order of libs 2' do # p4->p5->p7, p4->p6->p7
    Bake.startBake("order/p4", ["test"])
    expect($mystring.include?("build/test/p4"+Bake::Toolchain.outputEnding+" build/test/dummy.o -lexP4a ../p5/build/test_p4_test/libp5.a -lexP5a -lexP5b -lexP5c -lexP5d -lexP4b ../p6/build/test_p4_test/libp6.a -lexP6a -lexP6b ../p7/build/test_p4_test/libp7.a -lexP7 -lexP6c -lexP6d -lexP4c")).to be == true
  end

  it 'mix front and back' do
    Bake.startBake("injectTwice/main", ["test", "-v2"])
    expect($mystring.include?("-Ifirst -Isecond -Iforth -Ithird -Ififth -Isixth")).to be == true
  end 

end

end
