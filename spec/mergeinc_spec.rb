#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'socket'
require 'fileutils'

module Bake

describe "Merge-Inc" do

  it 'normal build with one sub yes' do
    Bake.startBake("mergeincludes/main", ["test2", "-v2"])

    expect($mystring.include?("g++ -c -MD -MF build/test1_main_test2/src/c1.d -Iinclude/c1 -o build/test1_main_test2/src/c1.o src/c1.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test3_main_test2/src/c3.d -Ibuild/test3_main_test2/mergedIncludes1 -o build/test3_main_test2/src/c3.o src/c3.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test1_main_test2/src/c1.d -Iinclude/c1 -o build/test1_main_test2/src/c1.o src/c1.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test4_main_test2/src/c4.d -Iinclude/c4 -o build/test4_main_test2/src/c4.o src/c4.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test2_main_test2/src/c2.d -Iinclude/c2 -o build/test2_main_test2/src/c2.o src/c2.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test2/src/c2.d -Iinclude/c1 -Iinclude/c2 -I../lib/include/c1 -I../lib/include/c2 -I../lib/include/c3 -I../lib/include/c4 -o build/test2/src/c2.o src/c2.cpp")).to be == true

    expect(ExitHelper.exit_code).to be == 0
  end

  it 'build with merge main' do
    Bake.startBake("mergeincludes/main", ["test2", "-v2", "--adapt", "merge_main"])

    expect($mystring.include?("g++ -c -MD -MF build/test1_main_test2/src/c1.d -Iinclude/c1 -o build/test1_main_test2/src/c1.o src/c1.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test3_main_test2/src/c3.d -Ibuild/test3_main_test2/mergedIncludes1 -o build/test3_main_test2/src/c3.o src/c3.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test1_main_test2/src/c1.d -Iinclude/c1 -o build/test1_main_test2/src/c1.o src/c1.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test4_main_test2/src/c4.d -Iinclude/c4 -o build/test4_main_test2/src/c4.o src/c4.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test2_main_test2/src/c2.d -Iinclude/c2 -o build/test2_main_test2/src/c2.o src/c2.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test2/src/c2.d -Ibuild/test2/mergedIncludes2 -I../lib/include/c2 -Ibuild/test2/mergedIncludes1 -o build/test2/src/c2.o src/c2.")).to be == true

    expect(ExitHelper.exit_code).to be == 0
  end

it 'build with merge all' do
    Bake.startBake("mergeincludes/main", ["test2", "-v2", "--adapt", "merge_all"])

    expect($mystring.include?("g++ -c -MD -MF build/test1_main_test2/src/c1.d -Ibuild/test1_main_test2/mergedIncludes1 -o build/test1_main_test2/src/c1.o src/c1.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test1_main_test2/src/c1.d -Ibuild/test1_main_test2/mergedIncludes1 -o build/test1_main_test2/src/c1.o src/c1.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test2_main_test2/src/c2.d -Iinclude/c2 -o build/test2_main_test2/src/c2.o src/c2.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test3_main_test2/src/c3.d -Ibuild/test3_main_test2/mergedIncludes1 -o build/test3_main_test2/src/c3.o src/c3.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test4_main_test2/src/c4.d -Ibuild/test4_main_test2/mergedIncludes1 -o build/test4_main_test2/src/c4.o src/c4.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test2/src/c2.d -Ibuild/test2/mergedIncludes2 -I../lib/include/c2 -Ibuild/test2/mergedIncludes1 -o build/test2/src/c2.o src/c2.")).to be == true

    expect(ExitHelper.exit_code).to be == 0
  end

  it 'build with merge none' do
    Bake.startBake("mergeincludes/main", ["test2", "-v2", "--adapt", "merge_none"])

    expect($mystring.include?("mergedIncludes")).to be == false

    expect(ExitHelper.exit_code).to be == 0
  end

  it 'build with merge broken adapt' do
    Bake.startBake("mergeincludes/main", ["test2", "-v2", "--adapt", "merge_broken"])

    expect($mystring.include?("Allowed modes are")).to be == true

    expect(ExitHelper.exit_code).to be > 0
  end

  it 'normal build with main inc merge' do
    Bake.startBake("mergeincludes/main", ["test3", "-v2"])

    expect($mystring.include?("g++ -c -MD -MF build/test1_main_test3/src/c1.d -Iinclude/c1 -o build/test1_main_test3/src/c1.o src/c1.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test3/src/c2.d -Ibuild/test3/mergedIncludes1 -o build/test3/src/c2.o src/c2.cpp")).to be == true

    expect(ExitHelper.exit_code).to be == 0
  end

  it 'normal build with merge broken' do
    Bake.startBake("mergeincludes/main2", ["test4", "-v2"])

    expect($mystring.include?("Allowed modes are")).to be == true

    expect(ExitHelper.exit_code).to be > 0
  end

end

end

