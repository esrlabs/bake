#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'bake/util'
require 'common/exit_helper'
require 'socket'
require 'fileutils'

module Bake

describe "Depth" do

  it 'only_roots_bake' do
    Bake.startBake("depth/main", [])
    expect(ExitHelper.exit_code).to be == 0
    expect($mystring.include?("spec/testdata/depth/main/2/3 (depth: 1)")).to be == true
  end

  it 'with adapt' do
    Bake.startBake("depth/main", ["--adapt", "adapt"])
    expect(ExitHelper.exit_code).to be > 0
    expect($mystring.include?("Adaption project adapt not found")).to be == true
    expect($mystring.include?("Checking root")).to be == false
  end

  it 'with max root' do
    Bake.startBake("depth/main", ["--adapt", "adapt", "-w", "spec/testdata/depth"])
    expect(ExitHelper.exit_code).to be == 0

    expect($mystring.split("spec/testdata/depth (depth: max)").length).to be == 2
    expect($mystring.split("spec/testdata/depth/main/2/3 (depth: 1)").length).to be == 2
    expect($mystring.split("Warning: Project lib exists more than once").length).to be == 2
    expect($mystring.split("spec/testdata/depth/1/2/3/4/lib (chosen)").length).to be == 2
    expect($mystring.split("spec/testdata/depth/main/2/3/lib").length).to be == 2
  end

  it 'with depth 2' do
    Bake.startBake("depth/main", ["--adapt", "adapt", "-w", "spec/testdata/depth, 3"])
    expect(ExitHelper.exit_code).to be == 0

    expect($mystring.split("spec/testdata/depth (depth: 3)").length).to be == 2
    expect($mystring.split("spec/testdata/depth/main/2/3 (depth: 1)").length).to be == 2
    expect($mystring.split("Warning: Project lib exists more than once").length).to be == 1
    expect($mystring.split("spec/testdata/depth/1/2/3/4/lib (chosen)").length).to be == 1
    expect($mystring.split("spec/testdata/depth/main/2/3/lib").length).to be == 2
  end

  it 'with same' do
    Bake.startBake("depth/main", ["--adapt", "adapt", "-w", "spec/testdata/depth, 3", "-w", "spec/testdata/depth, 3"])
    expect(ExitHelper.exit_code).to be == 0

    expect($mystring.split("spec/testdata/depth (depth: 3)").length).to be == 2
    expect($mystring.split("spec/testdata/depth/main/2/3 (depth: 1)").length).to be == 2
    expect($mystring.split("Warning: Project lib exists more than once").length).to be == 1
    expect($mystring.split("spec/testdata/depth/1/2/3/4/lib (chosen)").length).to be == 1
    expect($mystring.split("spec/testdata/depth/main/2/3/lib").length).to be == 2
  end

  it 'with less' do
    Bake.startBake("depth/main", ["--adapt", "adapt", "-w", "spec/testdata/depth, 3", "-w", "spec/testdata/depth, 1"])
    expect(ExitHelper.exit_code).to be == 0

    expect($mystring.split("spec/testdata/depth (depth: 3)").length).to be == 2
    expect($mystring.split("spec/testdata/depth (depth: 1)").length).to be == 1
    expect($mystring.split("spec/testdata/depth/main/2/3 (depth: 1)").length).to be == 2
    expect($mystring.split("Warning: Project lib exists more than once").length).to be == 1
    expect($mystring.split("spec/testdata/depth/1/2/3/4/lib (chosen)").length).to be == 1
    expect($mystring.split("spec/testdata/depth/main/2/3/lib").length).to be == 2
  end

  it 'with more' do
    Bake.startBake("depth/main", ["--adapt", "adapt", "-w", "spec/testdata/depth, 3", "-w", "spec/testdata/depth, 4"])
    expect(ExitHelper.exit_code).to be == 0

    expect($mystring.split("spec/testdata/depth (depth: 3)").length).to be == 2
    expect($mystring.split("spec/testdata/depth (depth: 4)").length).to be == 2
    expect($mystring.split("spec/testdata/depth/main/2/3 (depth: 1)").length).to be == 2
    expect($mystring.split("Warning: Project lib exists more than once").length).to be == 1
    expect($mystring.split("spec/testdata/depth/1/2/3/4/lib (chosen)").length).to be == 1
    expect($mystring.split("spec/testdata/depth/main/2/3/lib").length).to be == 2
  end

  it 'with very depth' do
    Bake.startBake("depth/main", ["--adapt", "adapt", "-w", "spec/testdata/depth,100"])
    expect(ExitHelper.exit_code).to be == 0

    expect($mystring.split("spec/testdata/depth (depth: 100)").length).to be == 2
    expect($mystring.split("spec/testdata/depth/main/2/3 (depth: 1)").length).to be == 2
    expect($mystring.split("Warning: Project lib exists more than once").length).to be == 2
  end

  it 'with depth 0 too high' do
    Bake.startBake("depth/main", ["--adapt", "adapt", "-w", "spec/testdata/depth/1/2,0"])
    expect(ExitHelper.exit_code).to be > 0
    expect($mystring.include?("Adaption project adapt not found")).to be == true
    expect($mystring.include?("Checking root")).to be == false
  end

  it 'with depth exact' do
    Bake.startBake("depth/main", ["--adapt", "adapt", "-w", "spec/testdata/depth/1/2/adapt,0"])
    expect(ExitHelper.exit_code).to be == 0

    expect($mystring.split("spec/testdata/depth/1/2/adapt (depth: 0)").length).to be == 2
    expect($mystring.split("spec/testdata/depth/main/2/3 (depth: 1)").length).to be == 2
    expect($mystring.split("Warning: Project lib exists more than once").length).to be == 1
    expect($mystring.split("spec/testdata/depth/1/2/3/4/lib (chosen)").length).to be == 1
    expect($mystring.split("spec/testdata/depth/main/2/3/lib").length).to be == 2
  end

end

end
