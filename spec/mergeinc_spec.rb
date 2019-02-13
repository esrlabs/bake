#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'socket'
require 'fileutils'

module Bake

describe "Merge-Inc" do

  it 'libs and main' do
    Bake.startBake("root1/main", ["test", "-w", "spec/testdata/root1", "-w", "spec/testdata/root2", "-v2", "--merge-inc", "--adapt", "spec/testdata/root1/main/NoLinkerScript.adapt"])

    expect($mystring.include?("g++ -c -MD -MF build/test_main_test/src/lib2.d -Ibuild/test_main_test/mergedIncludes1 -o build/test_main_test/src/lib2.o src/lib2.cpp")).to be == true
    expect($mystring.include?("ar -rc build/test_main_test/liblib1.a build/test_main_test/src/anotherOne.o build/test_main_test/src/lib1.o")).to be == true
    expect($mystring.include?("g++ -nostdlib -o build/test/main#{Bake::Toolchain.outputEnding} build/test/src/main.o ../lib1/build/test_main_test/liblib1.a ../../root2/lib2/build/test_main_test/liblib2.a")).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'no inc merge' do
    Bake.startBake("mergeincludes/main", ["test2", "-v2", "--adapt", "allyes_remove"])

    expect($mystring.include?("g++ -c -MD -MF build/test1_main_test2/src/c1.d -Iinclude/c1 -o build/test1_main_test2/src/c1.o src/c1.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test1_main_test2/src/c1.d -Iinclude/c1 -o build/test1_main_test2/src/c1.o src/c1.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test2_main_test2/src/c2.d -Iinclude/c2 -o build/test2_main_test2/src/c2.o src/c2.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test3_main_test2/src/c3.d -Iinclude/c3 -o build/test3_main_test2/src/c3.o src/c3.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test4_main_test2/src/c4.d -Iinclude/c4 -o build/test4_main_test2/src/c4.o src/c4.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test2/src/c2.d -Iinclude/c1 -Iinclude/c2 -I../lib/include/c1 -I../lib/include/c2 -I../lib/include/c3 -I../lib/include/c4 -o build/test2/src/c2.o src/c2.cpp")).to be == true

    expect(ExitHelper.exit_code).to be == 0
  end

  it 'extend inc merge' do
    Bake.startBake("mergeincludes/main", ["test2", "-v2", "--adapt", "allyes_add"])

    expect($mystring.include?("g++ -c -MD -MF build/test1_main_test2/src/c1.d -Iinclude/c1 -o build/test1_main_test2/src/c1.o src/c1.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test1_main_test2/src/c1.d -Iinclude/c1 -o build/test1_main_test2/src/c1.o src/c1.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test2_main_test2/src/c2.d -Ibuild/test2_main_test2/mergedIncludes1 -o build/test2_main_test2/src/c2.o src/c2.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test3_main_test2/src/c3.d -Ibuild/test3_main_test2/mergedIncludes1 -o build/test3_main_test2/src/c3.o src/c3.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test4_main_test2/src/c4.d -Ibuild/test4_main_test2/mergedIncludes1 -o build/test4_main_test2/src/c4.o src/c4.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test2/src/c2.d -Iinclude/c1 -Iinclude/c2 -I../lib/include/c1 -Ibuild/test2/mergedIncludes1 -o build/test2/src/c2.o src/c2.cpp")).to be == true

    expect(ExitHelper.exit_code).to be == 0
  end

  it 'replace inc merge' do
    Bake.startBake("mergeincludes/main", ["test2", "-v2", "--adapt", "allyes_replace"])

    expect($mystring.include?("g++ -c -MD -MF build/test1_main_test2/src/c1.d -Iinclude/c1 -o build/test1_main_test2/src/c1.o src/c1.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test1_main_test2/src/c1.d -Iinclude/c1 -o build/test1_main_test2/src/c1.o src/c1.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test2_main_test2/src/c2.d -Ibuild/test2_main_test2/mergedIncludes1 -o build/test2_main_test2/src/c2.o src/c2.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test3_main_test2/src/c3.d -Ibuild/test3_main_test2/mergedIncludes1 -o build/test3_main_test2/src/c3.o src/c3.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test4_main_test2/src/c4.d -Ibuild/test4_main_test2/mergedIncludes1 -o build/test4_main_test2/src/c4.o src/c4.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test2/src/c2.d -Iinclude/c1 -Iinclude/c2 -I../lib/include/c1 -Ibuild/test2/mergedIncludes1 -o build/test2/src/c2.o src/c2.cpp")).to be == true

    expect(ExitHelper.exit_code).to be == 0
  end

  it 'main inc merge' do
    Bake.startBake("mergeincludes/main", ["test2", "-v2", "--adapt", "allyes_main"])

    expect($mystring.include?("g++ -c -MD -MF build/test1_main_test2/src/c1.d -Ibuild/test1_main_test2/mergedIncludes1 -o build/test1_main_test2/src/c1.o src/c1.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test1_main_test2/src/c1.d -Iinclude/c1 -o build/test1_main_test2/src/c1.o src/c1.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test2_main_test2/src/c2.d -Iinclude/c2 -o build/test2_main_test2/src/c2.o src/c2.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test3_main_test2/src/c3.d -Ibuild/test3_main_test2/mergedIncludes1 -o build/test3_main_test2/src/c3.o src/c3.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test4_main_test2/src/c4.d -Iinclude/c4 -o build/test4_main_test2/src/c4.o src/c4.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test2/src/c2.d -Ibuild/test2/mergedIncludes2 -I../lib/include/c1 -I../lib/include/c2 -Ibuild/test2/mergedIncludes1 -I../lib/include/c4 -o build/test2/src/c2.o src/c2.cpp")).to be == true

    expect(ExitHelper.exit_code).to be == 0
  end  

  it 'org inc merge' do
    Bake.startBake("mergeincludes/main", ["test2", "-v2"])

    expect($mystring.include?("g++ -c -MD -MF build/test1_main_test2/src/c1.d -Iinclude/c1 -o build/test1_main_test2/src/c1.o src/c1.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test1_main_test2/src/c1.d -Iinclude/c1 -o build/test1_main_test2/src/c1.o src/c1.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test2_main_test2/src/c2.d -Iinclude/c2 -o build/test2_main_test2/src/c2.o src/c2.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test3_main_test2/src/c3.d -Ibuild/test3_main_test2/mergedIncludes1 -o build/test3_main_test2/src/c3.o src/c3.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test4_main_test2/src/c4.d -Iinclude/c4 -o build/test4_main_test2/src/c4.o src/c4.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test2/src/c2.d -Iinclude/c1 -Iinclude/c2 -I../lib/include/c1 -I../lib/include/c2 -Ibuild/test2/mergedIncludes1 -I../lib/include/c4 -o build/test2/src/c2.o src/c2.cpp")).to be == true

    expect(ExitHelper.exit_code).to be == 0
  end

  it 'cmd inc merge' do
    Bake.startBake("mergeincludes/main", ["test2", "-v2", "--merge-inc"])

    expect($mystring.include?("g++ -c -MD -MF build/test1_main_test2/src/c1.d -Ibuild/test1_main_test2/mergedIncludes1 -o build/test1_main_test2/src/c1.o src/c1.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test1_main_test2/src/c1.d -Ibuild/test1_main_test2/mergedIncludes1 -o build/test1_main_test2/src/c1.o src/c1.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test2_main_test2/src/c2.d -Iinclude/c2 -o build/test2_main_test2/src/c2.o src/c2.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test3_main_test2/src/c3.d -Ibuild/test3_main_test2/mergedIncludes1 -o build/test3_main_test2/src/c3.o src/c3.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test4_main_test2/src/c4.d -Ibuild/test4_main_test2/mergedIncludes1 -o build/test4_main_test2/src/c4.o src/c4.cpp")).to be == true
    expect($mystring.include?("g++ -c -MD -MF build/test2/src/c2.d -Ibuild/test2/mergedIncludes2 -I../lib/include/c2 -Ibuild/test2/mergedIncludes1 -o build/test2/src/c2.o src/c2.cpp")).to be == true

    
    expect(ExitHelper.exit_code).to be == 0
  end

end

end

