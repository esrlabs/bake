#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'

module Bake

describe "Prebuilding" do

  it 'Everything' do
    Bake.startBake("prebuild/main", ["testPre1", "--rebuild"])
    expect($mystring.split("**** Building 1 of 6: main (testa) ****").length).to be == 2
    expect($mystring.split("Compiling src/maina.cpp").length).to be == 2
    expect($mystring.split("Creating build/testa_main_testPre1/libmain.a").length).to be == 2
    expect($mystring.split("**** Building 2 of 6: lib2 (testa) ****").length).to be == 2
    expect($mystring.split("Compiling src/lib2a.cpp").length).to be == 2
    expect($mystring.split("Creating build/testa_main_testPre1/liblib2.a").length).to be == 2
    expect($mystring.split("**** Building 3 of 6: lib2 (testb) ****").length).to be == 2
    expect($mystring.split("Compiling src/lib2b.cpp").length).to be == 2
    expect($mystring.split("Creating build/testb_main_testPre1/liblib2.a").length).to be == 2
    expect($mystring.split("**** Building 4 of 6: lib1 (test) ****").length).to be == 2
    expect($mystring.split("Compiling src/lib1a.cpp").length).to be == 2
    expect($mystring.split("Creating build/test_main_testPre1/liblib1.a").length).to be == 2
    expect($mystring.split("**** Building 5 of 6: main (test) ****").length).to be == 2
    expect($mystring.split("echo PRESTEP").length).to be == 2
    expect($mystring.split("Compiling src/main.cpp").length).to be == 2
    expect($mystring.split("Linking build/test_main_testPre1/main.exe").length).to be == 2
    expect($mystring.split("**** Building 6 of 6: main (testPre1) ****").length).to be == 2

    expect($mystring.split("**** Skipping 1 of 6: main (testa) ****").length).to be == 1
    expect($mystring.split("**** Skipping 2 of 6: lib2 (testa) ****").length).to be == 1
    expect($mystring.split("**** Skipping 3 of 6: lib2 (testb) ****").length).to be == 1
    expect($mystring.split("**** Skipping 4 of 6: lib1 (test) ****").length).to be == 1
    expect($mystring.split("**** Skipping 5 of 6: main (test) ****").length).to be == 1
    expect($mystring.split("**** Skipping 6 of 6: main (testPre1) ****").length).to be == 1

    expect($mystring.split("Rebuilding done.").length).to be == 2

    expect(ExitHelper.exit_code).to be == 0

    Bake.startBake("prebuild/main", ["testPre1", "--rebuild", "--prebuild"])
    expect($mystring.split("**** Building 1 of 6: main (testa) ****").length).to be == 2
    expect($mystring.split("Compiling src/maina.cpp").length).to be == 2
    expect($mystring.split("Creating build/testa_main_testPre1/libmain.a").length).to be == 2
    expect($mystring.split("**** Building 2 of 6: lib2 (testa) ****").length).to be == 2
    expect($mystring.split("Compiling src/lib2a.cpp").length).to be == 2
    expect($mystring.split("Creating build/testa_main_testPre1/liblib2.a").length).to be == 2
    expect($mystring.split("**** Building 3 of 6: lib2 (testb) ****").length).to be == 2
    expect($mystring.split("Compiling src/lib2b.cpp").length).to be == 2
    expect($mystring.split("Creating build/testb_main_testPre1/liblib2.a").length).to be == 2
    expect($mystring.split("**** Building 4 of 6: lib1 (test) ****").length).to be == 2
    expect($mystring.split("Compiling src/lib1a.cpp").length).to be == 2
    expect($mystring.split("Creating build/test_main_testPre1/liblib1.a").length).to be == 2
    expect($mystring.split("**** Building 5 of 6: main (test) ****").length).to be == 2
    expect($mystring.split("echo PRESTEP").length).to be == 2
    expect($mystring.split("Compiling src/main.cpp").length).to be == 2
    expect($mystring.split("Linking build/test_main_testPre1/main.exe").length).to be == 2
    expect($mystring.split("**** Building 6 of 6: main (testPre1) ****").length).to be == 2

    expect($mystring.split("**** Skipping 1 of 6: main (testa) ****").length).to be == 2
    expect($mystring.split("**** Skipping 2 of 6: lib2 (testa) ****").length).to be == 2
    expect($mystring.split("**** Skipping 3 of 6: lib2 (testb) ****").length).to be == 2
    expect($mystring.split("**** Skipping 4 of 6: lib1 (test) ****").length).to be == 2
    expect($mystring.split("**** Skipping 5 of 6: main (test) ****").length).to be == 2
    expect($mystring.split("**** Skipping 6 of 6: main (testPre1) ****").length).to be == 2

    expect($mystring.split("Rebuilding done.").length).to be == 3

    expect(ExitHelper.exit_code).to be == 0
  end

  it 'Except main' do
    Bake.startBake("prebuild/main", ["testPre2", "--rebuild"])
    expect($mystring.split("**** Building 1 of 6: main (testa) ****").length).to be == 2
    expect($mystring.split("Compiling src/maina.cpp").length).to be == 2
    expect($mystring.split("Creating build/testa_main_testPre2/libmain.a").length).to be == 2
    expect($mystring.split("**** Building 2 of 6: lib2 (testa) ****").length).to be == 2
    expect($mystring.split("Compiling src/lib2a.cpp").length).to be == 2
    expect($mystring.split("Creating build/testa_main_testPre2/liblib2.a").length).to be == 2
    expect($mystring.split("**** Building 3 of 6: lib2 (testb) ****").length).to be == 2
    expect($mystring.split("Compiling src/lib2b.cpp").length).to be == 2
    expect($mystring.split("Creating build/testb_main_testPre2/liblib2.a").length).to be == 2
    expect($mystring.split("**** Building 4 of 6: lib1 (test) ****").length).to be == 2
    expect($mystring.split("Compiling src/lib1a.cpp").length).to be == 2
    expect($mystring.split("Creating build/test_main_testPre2/liblib1.a").length).to be == 2
    expect($mystring.split("**** Building 5 of 6: main (test) ****").length).to be == 2
    expect($mystring.split("echo PRESTEP").length).to be == 2
    expect($mystring.split("Compiling src/main.cpp").length).to be == 2
    expect($mystring.split("Linking build/test_main_testPre2/main.exe").length).to be == 2
    expect($mystring.split("**** Building 6 of 6: main (testPre2) ****").length).to be == 2

    expect($mystring.split("**** Skipping 1 of 6: main (testa) ****").length).to be == 1
    expect($mystring.split("**** Skipping 2 of 6: lib2 (testa) ****").length).to be == 1
    expect($mystring.split("**** Skipping 3 of 6: lib2 (testb) ****").length).to be == 1
    expect($mystring.split("**** Skipping 4 of 6: lib1 (test) ****").length).to be == 1
    expect($mystring.split("**** Skipping 5 of 6: main (test) ****").length).to be == 1
    expect($mystring.split("**** Skipping 6 of 6: main (testPre2) ****").length).to be == 1

    expect($mystring.split("Rebuilding done.").length).to be == 2

    expect(ExitHelper.exit_code).to be == 0

    Bake.startBake("prebuild/main", ["testPre2", "--rebuild", "--prebuild"])
    expect($mystring.split("**** Building 1 of 6: main (testa) ****").length).to be == 3
    expect($mystring.split("Compiling src/maina.cpp").length).to be == 3
    expect($mystring.split("Creating build/testa_main_testPre2/libmain.a").length).to be == 3
    expect($mystring.split("**** Building 2 of 6: lib2 (testa) ****").length).to be == 2
    expect($mystring.split("Compiling src/lib2a.cpp").length).to be == 2
    expect($mystring.split("Creating build/testa_main_testPre2/liblib2.a").length).to be == 2
    expect($mystring.split("**** Building 3 of 6: lib2 (testb) ****").length).to be == 2
    expect($mystring.split("Compiling src/lib2b.cpp").length).to be == 2
    expect($mystring.split("Creating build/testb_main_testPre2/liblib2.a").length).to be == 2
    expect($mystring.split("**** Building 4 of 6: lib1 (test) ****").length).to be == 2
    expect($mystring.split("Compiling src/lib1a.cpp").length).to be == 2
    expect($mystring.split("Creating build/test_main_testPre2/liblib1.a").length).to be == 2
    expect($mystring.split("**** Building 5 of 6: main (test) ****").length).to be == 3
    expect($mystring.split("echo PRESTEP").length).to be == 3
    expect($mystring.split("Compiling src/main.cpp").length).to be == 3
    expect($mystring.split("Linking build/test_main_testPre2/main.exe").length).to be == 3
    expect($mystring.split("**** Building 6 of 6: main (testPre2) ****").length).to be == 3

    expect($mystring.split("**** Skipping 1 of 6: main (testa) ****").length).to be == 1
    expect($mystring.split("**** Skipping 2 of 6: lib2 (testa) ****").length).to be == 2
    expect($mystring.split("**** Skipping 3 of 6: lib2 (testb) ****").length).to be == 2
    expect($mystring.split("**** Skipping 4 of 6: lib1 (test) ****").length).to be == 2
    expect($mystring.split("**** Skipping 5 of 6: main (test) ****").length).to be == 1
    expect($mystring.split("**** Skipping 6 of 6: main (testPre2) ****").length).to be == 1

    expect($mystring.split("Rebuilding done.").length).to be == 3

    expect(ExitHelper.exit_code).to be == 0
  end

  it 'Except lib2' do
    Bake.startBake("prebuild/main", ["testPre3", "--rebuild"])
    expect($mystring.split("**** Building 1 of 6: main (testa) ****").length).to be == 2
    expect($mystring.split("Compiling src/maina.cpp").length).to be == 2
    expect($mystring.split("Creating build/testa_main_testPre3/libmain.a").length).to be == 2
    expect($mystring.split("**** Building 2 of 6: lib2 (testa) ****").length).to be == 2
    expect($mystring.split("Compiling src/lib2a.cpp").length).to be == 2
    expect($mystring.split("Creating build/testa_main_testPre3/liblib2.a").length).to be == 2
    expect($mystring.split("**** Building 3 of 6: lib2 (testb) ****").length).to be == 2
    expect($mystring.split("Compiling src/lib2b.cpp").length).to be == 2
    expect($mystring.split("Creating build/testb_main_testPre3/liblib2.a").length).to be == 2
    expect($mystring.split("**** Building 4 of 6: lib1 (test) ****").length).to be == 2
    expect($mystring.split("Compiling src/lib1a.cpp").length).to be == 2
    expect($mystring.split("Creating build/test_main_testPre3/liblib1.a").length).to be == 2
    expect($mystring.split("**** Building 5 of 6: main (test) ****").length).to be == 2
    expect($mystring.split("echo PRESTEP").length).to be == 2
    expect($mystring.split("Compiling src/main.cpp").length).to be == 2
    expect($mystring.split("Linking build/test_main_testPre3/main.exe").length).to be == 2
    expect($mystring.split("**** Building 6 of 6: main (testPre3) ****").length).to be == 2

    expect($mystring.split("**** Skipping 1 of 6: main (testa) ****").length).to be == 1
    expect($mystring.split("**** Skipping 2 of 6: lib2 (testa) ****").length).to be == 1
    expect($mystring.split("**** Skipping 3 of 6: lib2 (testb) ****").length).to be == 1
    expect($mystring.split("**** Skipping 4 of 6: lib1 (test) ****").length).to be == 1
    expect($mystring.split("**** Skipping 5 of 6: main (test) ****").length).to be == 1
    expect($mystring.split("**** Skipping 6 of 6: main (testPre3) ****").length).to be == 1

    expect($mystring.split("Rebuilding done.").length).to be == 2

    expect(ExitHelper.exit_code).to be == 0

    Bake.startBake("prebuild/main", ["testPre3", "--rebuild", "--prebuild"])
    expect($mystring.split("**** Building 1 of 6: main (testa) ****").length).to be == 2
    expect($mystring.split("Compiling src/maina.cpp").length).to be == 2
    expect($mystring.split("Creating build/testa_main_testPre3/libmain.a").length).to be == 2
    expect($mystring.split("**** Building 2 of 6: lib2 (testa) ****").length).to be == 3
    expect($mystring.split("Compiling src/lib2a.cpp").length).to be == 3
    expect($mystring.split("Creating build/testa_main_testPre3/liblib2.a").length).to be == 3
    expect($mystring.split("**** Building 3 of 6: lib2 (testb) ****").length).to be == 3
    expect($mystring.split("Compiling src/lib2b.cpp").length).to be == 3
    expect($mystring.split("Creating build/testb_main_testPre3/liblib2.a").length).to be == 3
    expect($mystring.split("**** Building 4 of 6: lib1 (test) ****").length).to be == 2
    expect($mystring.split("Compiling src/lib1a.cpp").length).to be == 2
    expect($mystring.split("Creating build/test_main_testPre3/liblib1.a").length).to be == 2
    expect($mystring.split("**** Building 5 of 6: main (test) ****").length).to be == 2
    expect($mystring.split("echo PRESTEP").length).to be == 2
    expect($mystring.split("Compiling src/main.cpp").length).to be == 2
    expect($mystring.split("Linking build/test_main_testPre3/main.exe").length).to be == 2
    expect($mystring.split("**** Building 6 of 6: main (testPre3) ****").length).to be == 2

    expect($mystring.split("**** Skipping 1 of 6: main (testa) ****").length).to be == 2
    expect($mystring.split("**** Skipping 2 of 6: lib2 (testa) ****").length).to be == 1
    expect($mystring.split("**** Skipping 3 of 6: lib2 (testb) ****").length).to be == 1
    expect($mystring.split("**** Skipping 4 of 6: lib1 (test) ****").length).to be == 2
    expect($mystring.split("**** Skipping 5 of 6: main (test) ****").length).to be == 2
    expect($mystring.split("**** Skipping 6 of 6: main (testPre3) ****").length).to be == 2

    expect($mystring.split("Rebuilding done.").length).to be == 3

    expect(ExitHelper.exit_code).to be == 0
  end

  it 'Except lib2;testa and main;test' do
    Bake.startBake("prebuild/main", ["testPre4", "--rebuild"])
    expect($mystring.split("**** Building 1 of 6: main (testa) ****").length).to be == 2
    expect($mystring.split("Compiling src/maina.cpp").length).to be == 2
    expect($mystring.split("Creating build/testa_main_testPre4/libmain.a").length).to be == 2
    expect($mystring.split("**** Building 2 of 6: lib2 (testa) ****").length).to be == 2
    expect($mystring.split("Compiling src/lib2a.cpp").length).to be == 2
    expect($mystring.split("Creating build/testa_main_testPre4/liblib2.a").length).to be == 2
    expect($mystring.split("**** Building 3 of 6: lib2 (testb) ****").length).to be == 2
    expect($mystring.split("Compiling src/lib2b.cpp").length).to be == 2
    expect($mystring.split("Creating build/testb_main_testPre4/liblib2.a").length).to be == 2
    expect($mystring.split("**** Building 4 of 6: lib1 (test) ****").length).to be == 2
    expect($mystring.split("Compiling src/lib1a.cpp").length).to be == 2
    expect($mystring.split("Creating build/test_main_testPre4/liblib1.a").length).to be == 2
    expect($mystring.split("**** Building 5 of 6: main (test) ****").length).to be == 2
    expect($mystring.split("echo PRESTEP").length).to be == 2
    expect($mystring.split("Compiling src/main.cpp").length).to be == 2
    expect($mystring.split("Linking build/test_main_testPre4/main.exe").length).to be == 2
    expect($mystring.split("**** Building 6 of 6: main (testPre4) ****").length).to be == 2

    expect($mystring.split("**** Skipping 1 of 6: main (testa) ****").length).to be == 1
    expect($mystring.split("**** Skipping 2 of 6: lib2 (testa) ****").length).to be == 1
    expect($mystring.split("**** Skipping 3 of 6: lib2 (testb) ****").length).to be == 1
    expect($mystring.split("**** Skipping 4 of 6: lib1 (test) ****").length).to be == 1
    expect($mystring.split("**** Skipping 5 of 6: main (test) ****").length).to be == 1
    expect($mystring.split("**** Skipping 6 of 6: main (testPre4) ****").length).to be == 1

    expect($mystring.split("Rebuilding done.").length).to be == 2

    expect(ExitHelper.exit_code).to be == 0

    Bake.startBake("prebuild/main", ["testPre4", "--rebuild", "--prebuild"])
    expect($mystring.split("**** Building 1 of 6: main (testa) ****").length).to be == 2
    expect($mystring.split("Compiling src/maina.cpp").length).to be == 2
    expect($mystring.split("Creating build/testa_main_testPre4/libmain.a").length).to be == 2
    expect($mystring.split("**** Building 2 of 6: lib2 (testa) ****").length).to be == 3
    expect($mystring.split("Compiling src/lib2a.cpp").length).to be == 3
    expect($mystring.split("Creating build/testa_main_testPre4/liblib2.a").length).to be == 3
    expect($mystring.split("**** Building 3 of 6: lib2 (testb) ****").length).to be == 2
    expect($mystring.split("Compiling src/lib2b.cpp").length).to be == 2
    expect($mystring.split("Creating build/testb_main_testPre4/liblib2.a").length).to be == 2
    expect($mystring.split("**** Building 4 of 6: lib1 (test) ****").length).to be == 2
    expect($mystring.split("Compiling src/lib1a.cpp").length).to be == 2
    expect($mystring.split("Creating build/test_main_testPre4/liblib1.a").length).to be == 2
    expect($mystring.split("**** Building 5 of 6: main (test) ****").length).to be == 3
    expect($mystring.split("echo PRESTEP").length).to be == 3
    expect($mystring.split("Compiling src/main.cpp").length).to be == 3
    expect($mystring.split("Linking build/test_main_testPre4/main.exe").length).to be == 3
    expect($mystring.split("**** Building 6 of 6: main (testPre4) ****").length).to be == 2

    expect($mystring.split("**** Skipping 1 of 6: main (testa) ****").length).to be == 2
    expect($mystring.split("**** Skipping 2 of 6: lib2 (testa) ****").length).to be == 1
    expect($mystring.split("**** Skipping 3 of 6: lib2 (testb) ****").length).to be == 2
    expect($mystring.split("**** Skipping 4 of 6: lib1 (test) ****").length).to be == 2
    expect($mystring.split("**** Skipping 5 of 6: main (test) ****").length).to be == 1
    expect($mystring.split("**** Skipping 6 of 6: main (testPre4) ****").length).to be == 2

    expect($mystring.split("Rebuilding done.").length).to be == 3

    expect(ExitHelper.exit_code).to be == 0
  end

  it 'Collect prebuild stuff' do
    Bake.startBake("prebuild/main", ["testPre5", "--rebuild", "--prebuild"])

    expect($mystring.split("**** Skipping 1 of 7: main (testa) ****").length).to be == 2
    expect($mystring.split("**** Building 2 of 7: lib2 (testa) ****").length).to be == 2
    expect($mystring.split("Compiling src/lib2a.cpp").length).to be == 2
    expect($mystring.split("Creating build/testa_main_testPre5/liblib2.a").length).to be == 2
    expect($mystring.split("**** Skipping 3 of 7: lib2 (testb) ****").length).to be == 2
    expect($mystring.split("**** Skipping 4 of 7: lib1 (test) ****").length).to be == 2
    expect($mystring.split("**** Building 5 of 7: main (test) ****").length).to be == 2
    expect($mystring.split("echo PRESTEP").length).to be == 2
    expect($mystring.split("Compiling src/main.cpp").length).to be == 2
    expect($mystring.split("Linking build/test_main_testPre5/main.exe").length).to be == 2
    expect($mystring.split("**** Skipping 6 of 7: lib1 (testPre) ****").length).to be == 2
    expect($mystring.split("**** Skipping 7 of 7: main (testPre5) ****").length).to be == 2
    expect($mystring.split("Rebuilding failed.").length).to be == 2

    expect(ExitHelper.exit_code).to be > 0
  end

  it 'Warnings' do
    Bake.startBake("prebuild/main", ["testPre6", "--prebuild"])

    expect($mystring.split("Warning: prebuild project testWrong not found").length).to be == 2
    expect($mystring.split("Warning: prebuild config testWrong of project main not found").length).to be == 2
    expect($mystring.split("**** Skipping 1 of 1: main (testPre6) ****").length).to be == 2

    expect(ExitHelper.exit_code).to be == 0
  end


end

end
