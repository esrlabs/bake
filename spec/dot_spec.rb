#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'

module Bake

describe "Dot" do

  it 'Everything' do
    Bake.startBake("prebuild/main", ["testPre1", "--dot", "spec/testdata/prebuild/testdot.dot"])
    expect(ExitHelper.exit_code).to be == 0
    content = File.read("spec/testdata/prebuild/testdot.dot")
    expect(content.include?"\"main,testPre1\" -> \"main,test\"").to be == true
    expect(content.include?"\"main,test\" -> \"main,testa\"").to be == true
    expect(content.include?"\"main,test\" -> \"lib1,test\"").to be == true
    expect(content.include?"\"main,test\" -> \"lib2,testa\"").to be == true
    expect(content.include?"\"main,test\" -> \"lib2,testb\"").to be == true
    expect(content.include?"\"lib1,test\" -> \"lib2,testa\"").to be == true
    expect(content.include?"\"lib1,test\" -> \"lib2,testb\"").to be == true
    expect(content.include?"subgraph cluster_main").to be == true
    expect(content.include?"subgraph cluster_lib1").to be == true
    expect(content.include?"subgraph cluster_lib2").to be == true
  end

  it 'Only one project' do
    Bake.startBake("prebuild/main", ["testPre1", "--dot", "spec/testdata/prebuild/testdot.dot", "-p", "lib2"])
    expect(ExitHelper.exit_code).to be == 0
    content = File.read("spec/testdata/prebuild/testdot.dot")
    expect(content.include?"\"main,testPre1\" -> \"main,test\"").to be == false
    expect(content.include?"\"main,test\" -> \"main,testa\"").to be == false
    expect(content.include?"\"main,test\" -> \"lib1,test\"").to be == false
    expect(content.include?"\"main,test\" -> \"lib2,testa\"").to be == true
    expect(content.include?"\"main,test\" -> \"lib2,testb\"").to be == true
    expect(content.include?"\"lib1,test\" -> \"lib2,testa\"").to be == true
    expect(content.include?"\"lib1,test\" -> \"lib2,testb\"").to be == true
    expect(content.include?"subgraph cluster_main").to be == true
    expect(content.include?"subgraph cluster_lib1").to be == true
    expect(content.include?"subgraph cluster_lib2").to be == true
  end

  it 'Only one config' do
    Bake.startBake("prebuild/main", ["testPre1", "--dot", "spec/testdata/prebuild/testdot.dot", "-p", "main,test"])
    expect(ExitHelper.exit_code).to be == 0
    content = File.read("spec/testdata/prebuild/testdot.dot")
    expect(content.include?"\"main,testPre1\" -> \"main,test\"").to be == true
    expect(content.include?"\"main,test\" -> \"main,testa\"").to be == true
    expect(content.include?"\"main,test\" -> \"lib1,test\"").to be == true
    expect(content.include?"\"main,test\" -> \"lib2,testa\"").to be == true
    expect(content.include?"\"main,test\" -> \"lib2,testb\"").to be == true
    expect(content.include?"\"lib1,test\" -> \"lib2,testa\"").to be == false
    expect(content.include?"\"lib1,test\" -> \"lib2,testb\"").to be == false
    expect(content.include?"subgraph cluster_main").to be == true
    expect(content.include?"subgraph cluster_lib1").to be == true
    expect(content.include?"subgraph cluster_lib2").to be == true
  end

  it 'No dep to other project' do
    Bake.startBake("prebuild/main", ["testPre1", "--dot", "spec/testdata/prebuild/testdot.dot", "-p", "main,testPre1"])
    expect(ExitHelper.exit_code).to be == 0
    content = File.read("spec/testdata/prebuild/testdot.dot")
    expect(content.include?"\"main,testPre1\" -> \"main,test\"").to be == true
    expect(content.include?"\"main,test\" -> \"main,testa\"").to be == false
    expect(content.include?"\"main,test\" -> \"lib1,test\"").to be == false
    expect(content.include?"\"main,test\" -> \"lib2,testa\"").to be == false
    expect(content.include?"\"main,test\" -> \"lib2,testb\"").to be == false
    expect(content.include?"\"lib1,test\" -> \"lib2,testa\"").to be == false
    expect(content.include?"\"lib1,test\" -> \"lib2,testb\"").to be == false
    expect(content.include?"subgraph cluster_main").to be == true
    expect(content.include?"subgraph cluster_lib1").to be == false
    expect(content.include?"subgraph cluster_lib2").to be == false
  end


end

end
