#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'socket'
require 'fileutils'

module Bake

describe "compileOnly" do

  it 'notLink' do
    Bake.startBake("compileOnly/main", ["-v2"])
      
    expect($mystring.include?("src/lib2.cpp")).to be == true
    expect($mystring.include?("src/lib1a.cpp")).to be == true
    expect($mystring.include?("src/lib1b.cpp")).to be == true
    expect($mystring.include?("src/lib.cpp")).to be == true
    expect($mystring.include?("src/main.cpp")).to be == true
      
    expect($mystring.include?("test2_main_test/libmain.a")).to be == false
      
    expect($mystring.split("lib1a.o").length).to be == 2
    expect($mystring.split("lib.o").length).to be == 2
    expect($mystring.split("lib2.o").length).to be == 2
    
    expect($mystring.split("lib1b.o").length).to be == 3
    expect($mystring.split("main.o").length).to be == 3
    
    expect(ExitHelper.exit_code).to be == 0
  end

end

end
