#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'socket'
require 'fileutils'

module Bake

describe "linkonly" do
  
  it 'not link-only' do
    Bake.startBake("simple/main", ["test_ok"])
      
    expect($mystring.include?("Compiling")).to be == true
    expect($mystring.include?("Creating")).to be == true
    expect($mystring.include?("Linking")).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end
  
  it 'link-only' do
    Bake.startBake("simple/main", ["test_ok", "-c"])
    Bake.startBake("simple/main", ["test_ok", "--link-only"])
      
    expect($mystring.include?("Compiling")).to be == false
    expect($mystring.include?("Creating")).to be == false
    expect($mystring.include?("error")).to be == true
    expect(ExitHelper.exit_code).to be > 0
  end
  
  it 'build and link-only' do
    Bake.startBake("simple/main", ["test_ok"])
    $mystring.clear
    Bake.startBake("simple/main", ["test_ok", "--link-only"])
    expect($mystring.include?("Compiling")).to be == false
    expect($mystring.include?("Creating")).to be == false
    expect($mystring.include?("Linking")).to be == true
    expect($mystring.include?("error")).to be == false
    expect(ExitHelper.exit_code).to be == 0
  end
  
  it 'link-only and makefiles' do
    Bake.startBake("linkonly/libMake", ["test_lib"])
    expect(ExitHelper.exit_code).to be == 0
    $mystring.clear

    Bake.startBake("linkonly/main", ["test_ok"])
    expect(ExitHelper.exit_code).to be == 0
    $mystring.clear
    
    Bake.startBake("linkonly/main", ["test_ok", "--link-only"])
    expect($mystring.include?("Compiling")).to be == false
    expect($mystring.include?("Creating")).to be == false
    expect($mystring.include?("Linking")).to be == true
    expect($mystring.include?("error")).to be == false
    expect(ExitHelper.exit_code).to be == 0
  end
 
end

end
