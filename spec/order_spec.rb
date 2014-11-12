#!/usr/bin/env ruby



require 'bake/version'

require 'tocxx'
require 'bake/options'
require 'imported/utils/exit_helper'
require 'imported/utils/cleanup'
require 'fileutils'
require 'helper'

module Bake

ExitHelper.enable_exit_test

describe "Order" do
  
  before(:all) do
  end

  after(:all) do
  end

  before(:each) do
    $mystring=""
    $sstring=StringIO.open($mystring,"w+")
    $stdoutbackup=$stdout
    $stdout=$sstring
  end
  
  after(:each) do
    $stdout=$stdoutbackup
    ExitHelper.reset_exit_code
  end

  it 'order of libs' do
    options = Options.new(["-m", "spec/testdata/order/p1", "-b", "test"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()

    $mystring.include?("-l:u ../p2/test_p1/libp2.a ../p2/makeIn2 -L../p2/sp2 -lc -Lx1 -lx2 make2 -la -L../p3/sp3 y1/y2 ../p3/makeIn3 -lb make1 -Lu1 -l:u2").should == true
  end
  
end

end
