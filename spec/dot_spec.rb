#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'

module Bake
  
  def self.sanitize4Regex(x)
    x.gsub("\"","\\\"").gsub("/","\/")
  end
    
  def self.checkDep(content,d1,d2)
    d1 = sanitize4Regex(d1)
    d2 = sanitize4Regex(d2)
    content.match(/#{d1}\" -> \"[a-zA-Z0-9:\/]*\/#{d2}\"/) != nil
  end

  def self.checkSubgraph(content,d)
    d = sanitize4Regex(d)
    content.match(/cluster_[a-zA-Z0-9:\/]*#{d}\"/) != nil
  end

  def self.checkLabel(content,d,l)
    d = sanitize4Regex(d)
    content.match(/#{d}\" \[label = \"#{l}\"/) != nil
  end

describe "Dot" do

  it 'Everything' do
    Bake.startBake("prebuild/main", ["testPre1", "--dot", "spec/testdata/prebuild/testdot.dot"])
    expect(ExitHelper.exit_code).to be == 0
    content = File.read("spec/testdata/prebuild/testdot.dot")

    expect(Bake.checkDep(content, "main,testPre1","main,test")).to be == true
    expect(Bake.checkDep(content, "main,test","main,testa")).to be == true
    expect(Bake.checkDep(content, "main,test","lib1,test")).to be == true
    expect(Bake.checkDep(content, "main,test","lib2,testa")).to be == true
    expect(Bake.checkDep(content, "main,test","lib2,testb")).to be == true
    expect(Bake.checkDep(content, "lib1,test","lib2,testa")).to be == true
    expect(Bake.checkDep(content, "lib1,test","lib2,testb")).to be == true

    expect(Bake.checkSubgraph(content, "prebuild/main")).to be == true
    expect(Bake.checkSubgraph(content, "prebuild/lib1")).to be == true
    expect(Bake.checkSubgraph(content, "prebuild/lib2")).to be == true

    expect(Bake.checkLabel(content, "prebuild/main,testPre1", "testPre1")).to be == true
    expect(Bake.checkLabel(content, "prebuild/main,test", "test")).to be == true
    expect(Bake.checkLabel(content, "prebuild/main,testa", "testa")).to be == true
    expect(Bake.checkLabel(content, "prebuild/lib1,test", "test")).to be == true
    expect(Bake.checkLabel(content, "prebuild/lib2,testa", "testa")).to be == true
    expect(Bake.checkLabel(content, "prebuild/lib2,testb", "testb")).to be == true
      
    expect(content.include?("digraph \"main_testPre1\"")).to be == true
  end


  it 'Only one project' do
    Bake.startBake("prebuild/main", ["testPre1", "--dot", "spec/testdata/prebuild/testdot.dot", "-p", "lib2"])
    expect(ExitHelper.exit_code).to be == 0
    content = File.read("spec/testdata/prebuild/testdot.dot")

    expect(Bake.checkDep(content, "main,testPre1","main,test")).to be == false
    expect(Bake.checkDep(content, "main,test","main,testa")).to be == false
    expect(Bake.checkDep(content, "main,test","lib1,test")).to be == false
    expect(Bake.checkDep(content, "main,test","lib2,testa")).to be == true
    expect(Bake.checkDep(content, "main,test","lib2,testb")).to be == true
    expect(Bake.checkDep(content, "lib1,test","lib2,testa")).to be == true
    expect(Bake.checkDep(content, "lib1,test","lib2,testb")).to be == true

    expect(Bake.checkSubgraph(content, "prebuild/main")).to be == true
    expect(Bake.checkSubgraph(content, "prebuild/lib1")).to be == true
    expect(Bake.checkSubgraph(content, "prebuild/lib2")).to be == true

    expect(Bake.checkLabel(content, "prebuild/main,testPre1", "testPre1")).to be == false
    expect(Bake.checkLabel(content, "prebuild/main,test", "test")).to be == true
    expect(Bake.checkLabel(content, "prebuild/main,testa", "testa")).to be == false
    expect(Bake.checkLabel(content, "prebuild/lib1,test", "test")).to be == true
    expect(Bake.checkLabel(content, "prebuild/lib2,testa", "testa")).to be == true
    expect(Bake.checkLabel(content, "prebuild/lib2,testb", "testb")).to be == true

    expect(content.include?("digraph \"lib2\"")).to be == true
end

  it 'Only one config' do
    Bake.startBake("prebuild/main", ["testPre1", "--dot", "spec/testdata/prebuild/testdot.dot", "-p", "main,test"])
    expect(ExitHelper.exit_code).to be == 0
    content = File.read("spec/testdata/prebuild/testdot.dot")

    expect(Bake.checkDep(content, "main,testPre1","main,test")).to be == true
    expect(Bake.checkDep(content, "main,test","main,testa")).to be == true
    expect(Bake.checkDep(content, "main,test","lib1,test")).to be == true
    expect(Bake.checkDep(content, "main,test","lib2,testa")).to be == true
    expect(Bake.checkDep(content, "main,test","lib2,testb")).to be == true
    expect(Bake.checkDep(content, "lib1,test","lib2,testa")).to be == false
    expect(Bake.checkDep(content, "lib1,test","lib2,testb")).to be == false

    expect(Bake.checkSubgraph(content, "prebuild/main")).to be == true
    expect(Bake.checkSubgraph(content, "prebuild/lib1")).to be == true
    expect(Bake.checkSubgraph(content, "prebuild/lib2")).to be == true

    expect(Bake.checkLabel(content, "prebuild/main,testPre1", "testPre1")).to be == true
    expect(Bake.checkLabel(content, "prebuild/main,test", "test")).to be == true
    expect(Bake.checkLabel(content, "prebuild/main,testa", "testa")).to be == true
    expect(Bake.checkLabel(content, "prebuild/lib1,test", "test")).to be == true
    expect(Bake.checkLabel(content, "prebuild/lib2,testa", "testa")).to be == true
    expect(Bake.checkLabel(content, "prebuild/lib2,testb", "testb")).to be == true
      
    expect(content.include?("digraph \"main_test\"")).to be == true
  end

  it 'No dep to other project' do
    Bake.startBake("prebuild/main", ["testPre1", "--dot", "spec/testdata/prebuild/testdot.dot", "-p", "main,testPre1"])
    expect(ExitHelper.exit_code).to be == 0
    content = File.read("spec/testdata/prebuild/testdot.dot")
    expect(Bake.checkDep(content, "main,testPre1","main,test")).to be == true
    expect(Bake.checkDep(content, "main,test","main,testa")).to be == false
    expect(Bake.checkDep(content, "main,test","lib1,test")).to be == false
    expect(Bake.checkDep(content, "main,test","lib2,testa")).to be == false
    expect(Bake.checkDep(content, "main,test","lib2,testb")).to be == false
    expect(Bake.checkDep(content, "lib1,test","lib2,testa")).to be == false
    expect(Bake.checkDep(content, "lib1,test","lib2,testb")).to be == false

    expect(Bake.checkSubgraph(content, "prebuild/main")).to be == true
    expect(Bake.checkSubgraph(content, "prebuild/lib1")).to be == false
    expect(Bake.checkSubgraph(content, "prebuild/lib2")).to be == false

    expect(Bake.checkLabel(content, "prebuild/main,testPre1", "testPre1")).to be == true
    expect(Bake.checkLabel(content, "prebuild/main,test", "test")).to be == true
    expect(Bake.checkLabel(content, "prebuild/main,testa", "testa")).to be == false
    expect(Bake.checkLabel(content, "prebuild/lib1,test", "test")).to be == false
    expect(Bake.checkLabel(content, "prebuild/lib2,testa", "testa")).to be == false
    expect(Bake.checkLabel(content, "prebuild/lib2,testb", "testb")).to be == false
      
    expect(content.include?("digraph \"main_testPre1\"")).to be == true
  end

  it 'Default filename' do
    Bake.startBake("prebuild/main", ["testPre1", "--dot", "-p", "main,testPre1"])
    expect(ExitHelper.exit_code).to be == 0
    content = File.exist?("spec/testdata/prebuild/main/testPre1.dot")
  end

  it 'project level' do
    Bake.startBake("prebuild/main", ["testPre1", "--dot", "spec/testdata/prebuild/testdot.dot", "--dot-project-level"])
    expect(ExitHelper.exit_code).to be == 0
    content = File.read("spec/testdata/prebuild/testdot.dot")

    Bake.checkDep(content, "spec/testdata/prebuild/main","spec/testdata/prebuild/lib1")
    Bake.checkDep(content, "spec/testdata/prebuild/main","spec/testdata/prebuild/lib2")
    Bake.checkDep(content, "spec/testdata/prebuild/lib1","spec/testdata/prebuild/lib2")

    Bake.checkLabel(content, "spec/testdata/prebuild/main", "main")
    Bake.checkLabel(content, "spec/testdata/prebuild/lib1", "lib1")
    Bake.checkLabel(content, "spec/testdata/prebuild/lib2", "lib2")

    expect(content.include?("digraph \"main\"")).to be == true
  end

end

end
