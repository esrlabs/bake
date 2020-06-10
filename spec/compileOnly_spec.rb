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

  it 'linkDirectly' do
    Bake.startBake("compileOnly/main", ["test_ld", "-v2"])

    expect($mystring.include?("g++ -c -MD -MF build/test2_ld_main_test_ld/src/lib2.d -o build/test2_ld_main_test_ld/src/lib2.o src/lib2.cpp")).to be == true
    expect($mystring.include?("No source files, library won't be created")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test1_ld_main_test_ld/src/lib1a.d -o build/test1_ld_main_test_ld/src/lib1a.o src/lib1a.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test1_ld_main_test_ld/src/lib1b.d -o build/test1_ld_main_test_ld/src/lib1b.o src/lib1b.cpp")).to be == true
    expect($mystring.include?("ar -rc build/test1_ld_main_test_ld/libmain.a build/test1_ld_main_test_ld/src/lib1b.o")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test_ld/src/lib.d -o build/test_ld/src/lib.o src/lib.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test_ld/src/main.d -o build/test_ld/src/main.o src/main.cpp")).to be == true
    expect($mystring.include?("g++ -o build/test_ld/main#{Bake::Toolchain.outputEnding} build/test_ld/src/main.o build/test_ld/src/lib.o build/test1_ld_main_test_ld/src/lib1a.o build/test1_ld_main_test_ld/libmain.a build/test2_ld_main_test_ld/src/lib2.o")).to be == true

    expect(ExitHelper.exit_code).to be == 0
  end

end

end
