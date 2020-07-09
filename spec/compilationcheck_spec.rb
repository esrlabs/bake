#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'socket'
require 'fileutils'

module Bake

describe "CompilationCheck" do

  it 'complete' do
    Bake.startBake("root1/main", ["test", "-w", "spec/testdata/root1", "-w", "spec/testdata/root2", "--adapt", "cc"])
    expect($mystring.include?("Warning: file not included in build: spec/testdata/root1/main/src/main.c")).to be == true
    expect($mystring.include?("Warning: file not included in build: spec/testdata/root1/main/include/notIncludeThisOne2.h")).to be == true
    expect($mystring.include?("Warning: file not excluded in build: spec/testdata/root1/main/include/main.h")).to be == true
    expect($mystring.split("file not included").length).to be == 3
    expect($mystring.split("file not excluded").length).to be == 2
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'rebuild + link only' do
    Bake.startBake("root1/main", ["test", "-w", "spec/testdata/root1", "-w", "spec/testdata/root2", "--adapt", "cc", "--rebuild"])
    expect($mystring.include?("Warning: file not included in build: spec/testdata/root1/main/src/main.c")).to be == true
    expect($mystring.include?("Warning: file not included in build: spec/testdata/root1/main/include/notIncludeThisOne2.h")).to be == true
    expect($mystring.include?("Warning: file not excluded in build: spec/testdata/root1/main/include/main.h")).to be == true
    expect($mystring.split("file not included").length).to be == 3
    expect($mystring.split("file not excluded").length).to be == 2
    expect(ExitHelper.exit_code).to be == 0
    
    Bake.startBake("root1/main", ["test", "-w", "spec/testdata/root1", "-w", "spec/testdata/root2", "--adapt", "cc", "--link-only"])
    expect($mystring.split("file not included").length).to be == 3
    expect($mystring.split("file not excluded").length).to be == 2
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'project only' do
    Bake.startBake("root1/main", ["test", "-w", "spec/testdata/root1", "-w", "spec/testdata/root2", "--adapt", "cc", "-p", "lib1"])
    expect($mystring.include?("file not ")).to be == false
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'prebuild' do
    Bake.startBake("root1/main", ["test", "-w", "spec/testdata/root1", "-w", "spec/testdata/root2", "--adapt", "cc", "--prepro"])
    expect($mystring.include?("file not ")).to be == false
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'file only' do
    Bake.startBake("root1/main", ["test", "-w", "spec/testdata/root1", "-w", "spec/testdata/root2", "--adapt", "cc", "-f", "main.cpp"])
    expect($mystring.include?("file not ")).to be == false
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'compile only' do
    Bake.startBake("root1/main", ["test", "-w", "spec/testdata/root1", "-w", "spec/testdata/root2", "--adapt", "cc", "--compile-only"])
    expect($mystring.include?("file not ")).to be == false
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'adapt' do
    Bake.startBake("root1/main", ["test", "-w", "spec/testdata/root1", "-w", "spec/testdata/root2", "--adapt", "minimum"])
    expect($mystring.include?("10.11.12")).to be == true
    expect(ExitHelper.exit_code).to be > 0
  end

  it 'broken config' do
    Bake.startBake("root1/main", ["test", "-w", "spec/testdata/root1", "--adapt", "cc"])
    expect($mystring.include?("file not ")).to be == false
    expect(ExitHelper.exit_code).to be > 0
  end

  it 'broken file' do
    Bake.startBake("root1/main", ["test", "-w", "spec/testdata/root1", "-w", "spec/testdata/root2", "--adapt", "cc,addBrokenFile"])
    expect($mystring.include?("file not ")).to be == false
    expect(ExitHelper.exit_code).to be > 0
  end

end

end
