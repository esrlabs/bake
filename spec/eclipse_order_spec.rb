#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'

module Bake

describe "Eclipse Order" do
  
  it 'normal' do
    Bake.startBake("eclipseOrder/main", ["test_normal", "-v2"])
    buildStr =  
      "build/test_normal/a/x.o " +
      "build/test_normal/a/y.o " +
      "build/test_normal/b/a/x.o " +
      "build/test_normal/b/a/y.o " +
      "build/test_normal/b/b/x.o " +
      "build/test_normal/b/b/y.o " +
      "build/test_normal/b/c/x.o " +
      "build/test_normal/b/c/y.o " +
      "build/test_normal/b/d/x.o " +
      "build/test_normal/b/x.o " +
      "build/test_normal/b/y.o " +
      "build/test_normal/c/x.o " +
      "build/test_normal/c/y.o"
    expect($mystring.include?(buildStr)).to be == true
  end
  
  it 'eclipse' do
    Bake.startBake("eclipseOrder/main", ["test_eclipse", "-v2"])
    buildStr =  
      "build/test_eclipse/c/x.o " +
      "build/test_eclipse/c/y.o " +
      "build/test_eclipse/b/x.o " +
      "build/test_eclipse/b/y.o " +
      "build/test_eclipse/b/d/x.o " +
      "build/test_eclipse/b/c/x.o " +
      "build/test_eclipse/b/c/y.o " +
      "build/test_eclipse/b/b/x.o " +
      "build/test_eclipse/b/b/y.o " +
      "build/test_eclipse/b/a/x.o " +
      "build/test_eclipse/b/a/y.o " +
      "build/test_eclipse/a/x.o " +
      "build/test_eclipse/a/y.o"
    expect($mystring.include?(buildStr)).to be == true
  end
    
end

end
