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

    expect($mystring.split("**** Building 1 of 5: main (testa) ****").length).to be == 2
    expect($mystring.split("Compiling main (testa): src/maina.cpp").length).to be == 2
    expect($mystring.split("Creating  main (testa): build/testa_main_testPre1/libmain.a").length).to be == 2
    expect($mystring.split("**** Building 2 of 5: lib2 (testa) ****").length).to be == 2
    expect($mystring.split("Compiling lib2 (testa): src/lib2a.cpp").length).to be == 2
    expect($mystring.split("Creating  lib2 (testb): build/testb_main_testPre1/liblib2.a").length).to be == 2
    expect($mystring.split("**** Building 3 of 5: lib2 (testb) ****").length).to be == 2
    expect($mystring.split("Compiling lib2 (testb): src/lib2b.cpp").length).to be == 2
    expect($mystring.split("Creating  lib2 (testa): build/testa_main_testPre1/liblib2.a").length).to be == 2
    expect($mystring.split("**** Building 4 of 5: lib1 (test) ****").length).to be == 2
    expect($mystring.split("Compiling lib1 (test): src/lib1a.cpp").length).to be == 2
    expect($mystring.split("Creating  lib1 (test): build/test_main_testPre1/liblib1.a").length).to be == 2
    expect($mystring.split("**** Building 5 of 5: main (test) ****").length).to be == 2
    expect($mystring.split("echo PRESTEP").length).to be == 2
    expect($mystring.split("Compiling main (test): src/main.cpp").length).to be == 2
    expect($mystring.split("Linking   main (test): build/test_main_testPre1/main"+Bake::Toolchain.outputEnding).length).to be == 2

    expect($mystring.split("**** Using 1 of 5: main (testa) ****").length).to be == 1
    expect($mystring.split("**** Using 2 of 5: lib2 (testa) ****").length).to be == 1
    expect($mystring.split("**** Using 3 of 5: lib2 (testb) ****").length).to be == 1
    expect($mystring.split("**** Using 4 of 5: lib1 (test) ****").length).to be == 1
    expect($mystring.split("**** Using 5 of 5: main (test) ****").length).to be == 1

    expect($mystring.split("Rebuilding done.").length).to be == 2

    expect(ExitHelper.exit_code).to be == 0

    Bake.startBake("prebuild/main", ["testPre1", "--prebuild"])
    expect($mystring.split("**** Building 1 of 5: main (testa) ****").length).to be == 2
    expect($mystring.split("Compiling main (testa): src/maina.cpp").length).to be == 2
    expect($mystring.split("Creating  main (testa): build/testa_main_testPre1/libmain.a").length).to be == 2
    expect($mystring.split("**** Building 2 of 5: lib2 (testa) ****").length).to be == 2
    expect($mystring.split("Compiling lib2 (testa): src/lib2a.cpp").length).to be == 2
    expect($mystring.split("Creating  lib2 (testb): build/testb_main_testPre1/liblib2.a").length).to be == 2
    expect($mystring.split("**** Building 3 of 5: lib2 (testb) ****").length).to be == 2
    expect($mystring.split("Compiling lib2 (testb): src/lib2b.cpp").length).to be == 2
    expect($mystring.split("Creating  lib2 (testa): build/testa_main_testPre1/liblib2.a").length).to be == 2
    expect($mystring.split("**** Building 4 of 5: lib1 (test) ****").length).to be == 2
    expect($mystring.split("Compiling lib1 (test): src/lib1a.cpp").length).to be == 2
    expect($mystring.split("Creating  lib1 (test): build/test_main_testPre1/liblib1.a").length).to be == 2
    expect($mystring.split("**** Building 5 of 5: main (test) ****").length).to be == 2
    expect($mystring.split("echo PRESTEP").length).to be == 2
    expect($mystring.split("Compiling main (test): src/main.cpp").length).to be == 2
    expect($mystring.split("Linking   main (test): build/test_main_testPre1/main"+Bake::Toolchain.outputEnding).length).to be == 2

    expect($mystring.split("**** Using 1 of 5: main (testa) ****").length).to be == 2
    expect($mystring.split("**** Using 2 of 5: lib2 (testa) ****").length).to be == 2
    expect($mystring.split("**** Using 3 of 5: lib2 (testb) ****").length).to be == 2
    expect($mystring.split("**** Using 4 of 5: lib1 (test) ****").length).to be == 2
    expect($mystring.split("**** Using 5 of 5: main (test) ****").length).to be == 2

    expect($mystring.split("Building done.").length).to be == 2

    expect(ExitHelper.exit_code).to be == 0
  end

  it 'Except main' do
    Bake.startBake("prebuild/main", ["testPre2", "--rebuild"])
    expect($mystring.split("**** Building 1 of 5: main (testa) ****").length).to be == 2
    expect($mystring.split("Compiling main (testa): src/maina.cpp").length).to be == 2
    expect($mystring.split("Creating  main (testa): build/testa_main_testPre2/libmain.a").length).to be == 2
    expect($mystring.split("**** Building 2 of 5: lib2 (testa) ****").length).to be == 2
    expect($mystring.split("Compiling lib2 (testa): src/lib2a.cpp").length).to be == 2
    expect($mystring.split("Creating  lib2 (testb): build/testb_main_testPre2/liblib2.a").length).to be == 2
    expect($mystring.split("**** Building 3 of 5: lib2 (testb) ****").length).to be == 2
    expect($mystring.split("Compiling lib2 (testb): src/lib2b.cpp").length).to be == 2
    expect($mystring.split("Creating  lib2 (testa): build/testa_main_testPre2/liblib2.a").length).to be == 2
    expect($mystring.split("**** Building 4 of 5: lib1 (test) ****").length).to be == 2
    expect($mystring.split("Compiling lib1 (test): src/lib1a.cpp").length).to be == 2
    expect($mystring.split("Creating  lib1 (test): build/test_main_testPre2/liblib1.a").length).to be == 2
    expect($mystring.split("**** Building 5 of 5: main (test) ****").length).to be == 2
    expect($mystring.split("echo PRESTEP").length).to be == 2
    expect($mystring.split("Compiling main (test): src/main.cpp").length).to be == 2
    expect($mystring.split("Linking   main (test): build/test_main_testPre2/main"+Bake::Toolchain.outputEnding).length).to be == 2

    expect($mystring.split("**** Using 1 of 5: main (testa) ****").length).to be == 1
    expect($mystring.split("**** Using 2 of 5: lib2 (testa) ****").length).to be == 1
    expect($mystring.split("**** Using 3 of 5: lib2 (testb) ****").length).to be == 1
    expect($mystring.split("**** Using 4 of 5: lib1 (test) ****").length).to be == 1
    expect($mystring.split("**** Using 5 of 5: main (test) ****").length).to be == 1

    expect($mystring.split("Rebuilding done.").length).to be == 2

    expect(ExitHelper.exit_code).to be == 0

    Bake.startBake("prebuild/main", ["testPre2", "--prebuild"])
    expect($mystring.split("**** Building 1 of 5: main (testa) ****").length).to be == 3
    expect($mystring.split("Compiling main (testa): src/maina.cpp").length).to be == 2
    expect($mystring.split("Creating  main (testa): build/testa_main_testPre2/libmain.a").length).to be == 2
    expect($mystring.split("**** Building 2 of 5: lib2 (testa) ****").length).to be == 2
    expect($mystring.split("Compiling lib2 (testa): src/lib2a.cpp").length).to be == 2
    expect($mystring.split("Creating  lib2 (testb): build/testb_main_testPre2/liblib2.a").length).to be == 2
    expect($mystring.split("**** Building 3 of 5: lib2 (testb) ****").length).to be == 2
    expect($mystring.split("Compiling lib2 (testb): src/lib2b.cpp").length).to be == 2
    expect($mystring.split("Creating  lib2 (testa): build/testa_main_testPre2/liblib2.a").length).to be == 2
    expect($mystring.split("**** Building 4 of 5: lib1 (test) ****").length).to be == 2
    expect($mystring.split("Compiling lib1 (test): src/lib1a.cpp").length).to be == 2
    expect($mystring.split("Creating  lib1 (test): build/test_main_testPre2/liblib1.a").length).to be == 2
    expect($mystring.split("**** Building 5 of 5: main (test) ****").length).to be == 3
    expect($mystring.split("echo PRESTEP").length).to be == 3
    expect($mystring.split("Compiling main (test): src/main.cpp").length).to be == 2
    expect($mystring.split("Linking   main (test): build/test_main_testPre2/main"+Bake::Toolchain.outputEnding).length).to be == 2

    expect($mystring.split("**** Using 1 of 5: main (testa) ****").length).to be == 1
    expect($mystring.split("**** Using 2 of 5: lib2 (testa) ****").length).to be == 2
    expect($mystring.split("**** Using 3 of 5: lib2 (testb) ****").length).to be == 2
    expect($mystring.split("**** Using 4 of 5: lib1 (test) ****").length).to be == 2
    expect($mystring.split("**** Using 5 of 5: main (test) ****").length).to be == 1

    expect($mystring.split("Building done.").length).to be == 2

    expect(ExitHelper.exit_code).to be == 0
  end

  it 'Except lib2' do
    Bake.startBake("prebuild/main", ["testPre3", "--rebuild"])
    expect($mystring.split("**** Building 1 of 5: main (testa) ****").length).to be == 2
    expect($mystring.split("Compiling main (testa): src/maina.cpp").length).to be == 2
    expect($mystring.split("Creating  main (testa): build/testa_main_testPre3/libmain.a").length).to be == 2
    expect($mystring.split("**** Building 2 of 5: lib2 (testa) ****").length).to be == 2
    expect($mystring.split("Compiling lib2 (testa): src/lib2a.cpp").length).to be == 2
    expect($mystring.split("Creating  lib2 (testb): build/testb_main_testPre3/liblib2.a").length).to be == 2
    expect($mystring.split("**** Building 3 of 5: lib2 (testb) ****").length).to be == 2
    expect($mystring.split("Compiling lib2 (testb): src/lib2b.cpp").length).to be == 2
    expect($mystring.split("Creating  lib2 (testa): build/testa_main_testPre3/liblib2.a").length).to be == 2
    expect($mystring.split("**** Building 4 of 5: lib1 (test) ****").length).to be == 2
    expect($mystring.split("Compiling lib1 (test): src/lib1a.cpp").length).to be == 2
    expect($mystring.split("Creating  lib1 (test): build/test_main_testPre3/liblib1.a").length).to be == 2
    expect($mystring.split("**** Building 5 of 5: main (test) ****").length).to be == 2
    expect($mystring.split("echo PRESTEP").length).to be == 2
    expect($mystring.split("Compiling main (test): src/main.cpp").length).to be == 2
    expect($mystring.split("Linking   main (test): build/test_main_testPre3/main"+Bake::Toolchain.outputEnding).length).to be == 2

    expect($mystring.split("**** Using 1 of 5: main (testa) ****").length).to be == 1
    expect($mystring.split("**** Using 2 of 5: lib2 (testa) ****").length).to be == 1
    expect($mystring.split("**** Using 3 of 5: lib2 (testb) ****").length).to be == 1
    expect($mystring.split("**** Using 4 of 5: lib1 (test) ****").length).to be == 1
    expect($mystring.split("**** Using 5 of 5: main (test) ****").length).to be == 1

    expect($mystring.split("Rebuilding done.").length).to be == 2

    expect(ExitHelper.exit_code).to be == 0

    Bake.startBake("prebuild/main", ["testPre3", "--prebuild"])
    expect($mystring.split("**** Building 1 of 5: main (testa) ****").length).to be == 2
    expect($mystring.split("Compiling main (testa): src/maina.cpp").length).to be == 2
    expect($mystring.split("Creating  main (testa): build/testa_main_testPre3/libmain.a").length).to be == 2
    expect($mystring.split("**** Building 2 of 5: lib2 (testa) ****").length).to be == 3
    expect($mystring.split("Compiling lib2 (testa): src/lib2a.cpp").length).to be == 2
    expect($mystring.split("Creating  lib2 (testb): build/testb_main_testPre3/liblib2.a").length).to be == 2
    expect($mystring.split("**** Building 3 of 5: lib2 (testb) ****").length).to be == 3
    expect($mystring.split("Compiling lib2 (testb): src/lib2b.cpp").length).to be == 2
    expect($mystring.split("Creating  lib2 (testa): build/testa_main_testPre3/liblib2.a").length).to be == 2
    expect($mystring.split("**** Building 4 of 5: lib1 (test) ****").length).to be == 2
    expect($mystring.split("Compiling lib1 (test): src/lib1a.cpp").length).to be == 2
    expect($mystring.split("Creating  lib1 (test): build/test_main_testPre3/liblib1.a").length).to be == 2
    expect($mystring.split("**** Building 5 of 5: main (test) ****").length).to be == 2
    expect($mystring.split("echo PRESTEP").length).to be == 2
    expect($mystring.split("Compiling main (test): src/main.cpp").length).to be == 2
    expect($mystring.split("Linking   main (test): build/test_main_testPre3/main"+Bake::Toolchain.outputEnding).length).to be == 2

    expect($mystring.split("**** Using 1 of 5: main (testa) ****").length).to be == 2
    expect($mystring.split("**** Using 2 of 5: lib2 (testa) ****").length).to be == 1
    expect($mystring.split("**** Using 3 of 5: lib2 (testb) ****").length).to be == 1
    expect($mystring.split("**** Using 4 of 5: lib1 (test) ****").length).to be == 2
    expect($mystring.split("**** Using 5 of 5: main (test) ****").length).to be == 2

    expect($mystring.split("Building done.").length).to be == 2

    expect(ExitHelper.exit_code).to be == 0
  end

  it 'Except lib2;testa and main;test' do
    Bake.startBake("prebuild/main", ["testPre4", "--rebuild"])
    expect($mystring.split("**** Building 1 of 5: main (testa) ****").length).to be == 2
    expect($mystring.split("Compiling main (testa): src/maina.cpp").length).to be == 2
    expect($mystring.split("Creating  main (testa): build/testa_main_testPre4/libmain.a").length).to be == 2
    expect($mystring.split("**** Building 2 of 5: lib2 (testa) ****").length).to be == 2
    expect($mystring.split("Compiling lib2 (testa): src/lib2a.cpp").length).to be == 2
    expect($mystring.split("Creating  lib2 (testb): build/testb_main_testPre4/liblib2.a").length).to be == 2
    expect($mystring.split("**** Building 3 of 5: lib2 (testb) ****").length).to be == 2
    expect($mystring.split("Compiling lib2 (testb): src/lib2b.cpp").length).to be == 2
    expect($mystring.split("Creating  lib2 (testa): build/testa_main_testPre4/liblib2.a").length).to be == 2
    expect($mystring.split("**** Building 4 of 5: lib1 (test) ****").length).to be == 2
    expect($mystring.split("Compiling lib1 (test): src/lib1a.cpp").length).to be == 2
    expect($mystring.split("Creating  lib1 (test): build/test_main_testPre4/liblib1.a").length).to be == 2
    expect($mystring.split("**** Building 5 of 5: main (test) ****").length).to be == 2
    expect($mystring.split("echo PRESTEP").length).to be == 2
    expect($mystring.split("Compiling main (test): src/main.cpp").length).to be == 2
    expect($mystring.split("Linking   main (test): build/test_main_testPre4/main"+Bake::Toolchain.outputEnding).length).to be == 2

    expect($mystring.split("**** Using 1 of 5: main (testa) ****").length).to be == 1
    expect($mystring.split("**** Using 2 of 5: lib2 (testa) ****").length).to be == 1
    expect($mystring.split("**** Using 3 of 5: lib2 (testb) ****").length).to be == 1
    expect($mystring.split("**** Using 4 of 5: lib1 (test) ****").length).to be == 1
    expect($mystring.split("**** Using 5 of 5: main (test) ****").length).to be == 1

    expect($mystring.split("Rebuilding done.").length).to be == 2

    expect(ExitHelper.exit_code).to be == 0

    Bake.startBake("prebuild/main", ["testPre4", "--prebuild"])
    expect($mystring.split("**** Building 1 of 5: main (testa) ****").length).to be == 2
    expect($mystring.split("Compiling main (testa): src/maina.cpp").length).to be == 2
    expect($mystring.split("Creating  main (testa): build/testa_main_testPre4/libmain.a").length).to be == 2
    expect($mystring.split("**** Building 2 of 5: lib2 (testa) ****").length).to be == 3
    expect($mystring.split("Compiling lib2 (testa): src/lib2a.cpp").length).to be == 2
    expect($mystring.split("Creating  lib2 (testb): build/testb_main_testPre4/liblib2.a").length).to be == 2
    expect($mystring.split("**** Building 3 of 5: lib2 (testb) ****").length).to be == 2
    expect($mystring.split("Compiling lib2 (testb): src/lib2b.cpp").length).to be == 2
    expect($mystring.split("Creating  lib2 (testa): build/testa_main_testPre4/liblib2.a").length).to be == 2
    expect($mystring.split("**** Building 4 of 5: lib1 (test) ****").length).to be == 2
    expect($mystring.split("Compiling lib1 (test): src/lib1a.cpp").length).to be == 2
    expect($mystring.split("Creating  lib1 (test): build/test_main_testPre4/liblib1.a").length).to be == 2
    expect($mystring.split("**** Building 5 of 5: main (test) ****").length).to be == 3
    expect($mystring.split("echo PRESTEP").length).to be == 3
    expect($mystring.split("Compiling main (test): src/main.cpp").length).to be == 2
    expect($mystring.split("Linking   main (test): build/test_main_testPre4/main"+Bake::Toolchain.outputEnding).length).to be == 2

    expect($mystring.split("**** Using 1 of 5: main (testa) ****").length).to be == 2
    expect($mystring.split("**** Using 2 of 5: lib2 (testa) ****").length).to be == 1
    expect($mystring.split("**** Using 3 of 5: lib2 (testb) ****").length).to be == 2
    expect($mystring.split("**** Using 4 of 5: lib1 (test) ****").length).to be == 2
    expect($mystring.split("**** Using 5 of 5: main (test) ****").length).to be == 1

    expect($mystring.split("Building done.").length).to be == 2

    expect(ExitHelper.exit_code).to be == 0
  end

  it 'Collect prebuild stuff' do
    Bake.startBake("prebuild/main", ["testPre5", "--rebuild", "--prebuild"])

    expect($mystring.split("**** Using 1 of 5: main (testa) ****").length).to be == 2
    expect($mystring.split("**** Building 2 of 5: lib2 (testa) ****").length).to be == 2
    expect($mystring.split("Compiling lib2 (testa): src/lib2a.cpp").length).to be == 2
    expect($mystring.split("Creating  lib2 (testa): build/testa_main_testPre5/liblib2.a").length).to be == 2
    expect($mystring.split("**** Using 3 of 5: lib2 (testb) ****").length).to be == 2
    expect($mystring.split("**** Using 4 of 5: lib1 (test) ****").length).to be == 2
    expect($mystring.split("**** Building 5 of 5: main (test) ****").length).to be == 2
    expect($mystring.split("echo PRESTEP").length).to be == 2
    expect($mystring.split("Compiling main (test): src/main.cpp").length).to be == 2
    expect($mystring.split("Linking   main (test): build/test_main_testPre5/main"+Bake::Toolchain.outputEnding).length).to be == 2
    expect($mystring.split("Rebuilding failed.").length).to be == 2

    expect(ExitHelper.exit_code).to be > 0
  end


  it 'Warnings' do
    Bake.startBake("prebuild/main", ["testPre6", "--prebuild"])

    expect($mystring.split("Warning: prebuild project testWrong not found").length).to be == 2
    expect($mystring.split("Warning: prebuild config testWrong of project main not found").length).to be == 2
    expect($mystring.split("****").length).to be == 1

    expect(ExitHelper.exit_code).to be == 0
  end

  it 'RemovedSources' do
    srcDir = "spec/testdata/prebuild/lib1/src"
    FileUtils.mv(srcDir+".tmp", srcDir) if File.exist?(srcDir+".tmp")

    Bake.startBake("prebuild/main", ["testRemove"])
    expect(ExitHelper.exit_code).to be == 0
    expect($mystring.include?("**** Building 4 of 5: lib1 (test) ****")).to be == true

    FileUtils.mv(srcDir, srcDir+".tmp")

    Bake.startBake("prebuild/main", ["testRemove", "--prebuild"])
    expect(ExitHelper.exit_code).to be == 0
    expect($mystring.include?("**** Using 4 of 5: lib1 (test) ****")).to be == true

    FileUtils.mv(srcDir+".tmp", srcDir)
  end

  it 'No objects no lib' do
    Bake.startBake("prebuild/main", ["testPre5", "-v2", "--prebuild", "-p", "lib2,testb"])
    expect($mystring.include?("**** Using 1 of 1: lib2 (testb) ****")).to be == true
    expect($mystring.include?("No object files, library won't be created")).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'Objects and Libs' do
    Bake.startBake("prebuild/main", ["testPre5"])
    expect($mystring.split("Compiling lib2 (testb): src/lib2b.cpp").length).to be == 2
    expect($mystring.split("Creating  lib2 (testb): build/testb_main_testPre5/liblib2.a").length).to be == 2

    Bake.startBake("prebuild/main", ["testPre5", "-p", "lib2,testb", "--prebuild", "-v2"])
    expect($mystring.include?("**** Using 1 of 1: lib2 (testb) ****")).to be == true
    expect($mystring.include?("No object files, library won't be created")).to be == false
    expect($mystring.split("Compiling lib2 (testb): src/lib2b.cpp").length).to be == 2
    expect($mystring.split("Creating  lib2 (testb): build/testb_main_testPre5/liblib2.a").length).to be == 2

    Bake.startBake("prebuild/main", ["testPre5", "--prebuild"])
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'Objects and no lib' do
    Bake.startBake("prebuild/main", ["testPre5"])
    expect($mystring.split("Compiling lib2 (testb): src/lib2b.cpp").length).to be == 2
    expect($mystring.split("Creating  lib2 (testb): build/testb_main_testPre5/liblib2.a").length).to be == 2

    FileUtils.rm_rf("spec/testdata/prebuild/lib2/build/testb_main_testPre5/liblib2.a")

    Bake.startBake("prebuild/main", ["testPre5", "-p", "lib2,testb", "--prebuild"])
    expect($mystring.include?("**** Using 1 of 1: lib2 (testb) ****")).to be == true
    expect($mystring.include?("No object files, library won't be created")).to be == false
    expect($mystring.split("Compiling lib2 (testb): src/lib2b.cpp").length).to be == 2
    expect($mystring.split("Creating  lib2 (testb): build/testb_main_testPre5/liblib2.a").length).to be == 3

    Bake.startBake("prebuild/main", ["testPre5", "--prebuild"])
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'No objects and lib' do
    Bake.startBake("prebuild/main", ["testPre5"])
    expect($mystring.split("Compiling lib2 (testb): src/lib2b.cpp").length).to be == 2
    expect($mystring.split("Creating  lib2 (testb): build/testb_main_testPre5/liblib2.a").length).to be == 2

    Dir.glob("spec/testdata/prebuild/lib2/build/testb_main_testPre5/**/*.o").each do |o|
      FileUtils.rm_rf(o)
    end

    Bake.startBake("prebuild/main", ["testPre5", "-p", "lib2,testb", "--prebuild"])
    expect($mystring.include?("**** Using 1 of 1: lib2 (testb) ****")).to be == true
    expect($mystring.include?("No object files, library won't be created")).to be == false
    expect($mystring.split("Compiling lib2 (testb): src/lib2b.cpp").length).to be == 2
    expect($mystring.split("Creating  lib2 (testb): build/testb_main_testPre5/liblib2.a").length).to be == 2

    Bake.startBake("prebuild/main", ["testPre5", "--prebuild"])
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'Clean with objects' do
    Bake.startBake("prebuild/main", ["testPre5"])
    expect($mystring.split("Compiling lib2 (testb): src/lib2b.cpp").length).to be == 2
    expect($mystring.split("Creating  lib2 (testb): build/testb_main_testPre5/liblib2.a").length).to be == 2

    Bake.startBake("prebuild/main", ["testPre5", "-p", "lib2,testb", "--prebuild", "-c", "-v2"])
    expect($mystring.include?("**** Checking 1 of 1: lib2 (testb) ****")).to be == true
    expect($mystring.include?("Deleting file build/testb_main_testPre5/liblib2.a")).to be == true
  end

  it 'Clean without objects' do
    Bake.startBake("prebuild/main", ["testPre5"])
    expect($mystring.split("Compiling lib2 (testb): src/lib2b.cpp").length).to be == 2
    expect($mystring.split("Creating  lib2 (testb): build/testb_main_testPre5/liblib2.a").length).to be == 2

    Dir.glob("spec/testdata/prebuild/lib2/build/testb_main_testPre5/**/*.o").each do |o|
      FileUtils.rm_rf(o)
    end

    Bake.startBake("prebuild/main", ["testPre5", "-p", "lib2,testb", "--prebuild", "-c", "-v2"])
    expect($mystring.include?("**** Checking 1 of 1: lib2 (testb) ****")).to be == true
    expect($mystring.include?("Deleting file build/testb_main_testPre5/liblib2.a")).to be == false
  end

end

end
