#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'

module Bake

describe "Order" do
  
  it 'order of libs' do
    Bake.startBake("order/p1", ["test"])
    expect($mystring.include?("-l:u ../p2/build_test_p1_test/libp2.a -L../p2/sp2 -lc ../p2/makeIn2 -Lx1 -lx2 -la -L../p3/sp3 y1/y2 ../p3/makeIn3 -lb -Lu1 -l:u2 make1 make2")).to be == true
  end
  
end

end
