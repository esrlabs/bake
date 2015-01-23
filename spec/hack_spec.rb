#!/usr/bin/env ruby

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'
require 'helper'

module Bake

describe "Hacks" do
  
  it 'deppath' do
    Bake.startBake("hacks/main", ["testDepHeader"])
    expect($mystring.split("Compiling").length).to be == 2
    expect(ExitHelper.exit_code).to be == 0

    Bake.startBake("hacks/main", ["testDepHeader"])
    expect($mystring.split("Compiling").length).to be == 2
    expect(ExitHelper.exit_code).to be == 0
  end
  
  it 'lintpipe' do
    expect(File.exists?("spec/testdata/hacks/main/test_lib_lib_lintout.xml")).to be == false
    expect(File.exists?("spec/testdata/hacks/main/test_main_testLintPipe_lintout.xml")).to be == false
    
    Bake.startBake("hacks/main", ["testLintPipe", "--lint"])
      
    expect(File.exists?("spec/testdata/hacks/main/test_lib_lib_lintout.xml")).to be == true
    expect(File.exists?("spec/testdata/hacks/main/test_main_testLintPipe_lintout.xml")).to be == true
  end
  
end

end
