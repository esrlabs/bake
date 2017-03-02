#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'bake/util'
require 'common/exit_helper'
require 'socket'
require 'fileutils'

require 'common/ext/stdout'

module Bake

describe "Dry" do

  it 'dry cache' do
    Bake.startBake("make/main", ["test", "--dry"])
    expect(File.exists?("spec/testdata/make/main/.bake/Project.meta.test.cache")).to be == false
    expect(File.exists?("spec/testdata/make/main/.bake/Project.meta.cache")).to be == false
    expect(File.exists?("spec/testdata/make/main/.bake")).to be == false
    Bake.startBake("make/main", ["test"])
    expect(File.exists?("spec/testdata/make/main/.bake/Project.meta.test.cache")).to be == true
    expect(File.exists?("spec/testdata/make/main/.bake/Project.meta.cache")).to be == true
    expect(File.exists?("spec/testdata/make/main/.bake")).to be == true
  end

  #######################################################################

  it 'dry make when cleaned' do
    Bake.startBake("make/main", ["test", "--dry"])

    expect(File.exists?("spec/testdata/make/main/obj/main.o")).to be == false
    expect(File.exists?("spec/testdata/make/main/obj/main2.o")).to be == false
    expect(File.exists?("spec/testdata/make/main/obj")).to be == false
    expect(File.exists?("spec/testdata/make/main/project.exe")).to be == false

    expect($mystring.include?("make all")).to be == true
    expect($mystring.include?("gcc -c")).to be == false
    expect($mystring.include?("Building done.")).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'dry make when built' do
    Bake.startBake("make/main", ["test"])
    $mystring.clear
    Bake.startBake("make/main", ["test", "--dry"])

    expect(File.exists?("spec/testdata/make/main/obj/main.o")).to be == true
    expect(File.exists?("spec/testdata/make/main/obj/main2.o")).to be == true
    expect(File.exists?("spec/testdata/make/main/obj")).to be == true
    expect(File.exists?("spec/testdata/make/main/project.exe")).to be == true

    expect($mystring.split("make all").length).to be == 2
    expect($mystring.split("main2.c").length).to be == 1
    expect($mystring.split("Building done.").length).to be == 2
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'dry make clean when cleaned' do
    Bake.startBake("make/main", ["test", "-c", "--dry"])

    expect(File.exists?("spec/testdata/make/main/obj/main.o")).to be == false
    expect(File.exists?("spec/testdata/make/main/obj/main2.o")).to be == false
    expect(File.exists?("spec/testdata/make/main/obj")).to be == false
    expect(File.exists?("spec/testdata/make/main/project.exe")).to be == false

    expect($mystring.split("make clean").length).to be == 2
    expect($mystring.split("Cleaning done.").length).to be == 2
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'dry make clean when built' do
    Bake.startBake("make/main", ["test"])
    $mystring.clear
    Bake.startBake("make/main", ["test", "-c", "--dry", "-v2"])

    expect(File.exists?("spec/testdata/make/main/obj/main.o")).to be == true
    expect(File.exists?("spec/testdata/make/main/obj/main2.o")).to be == true
    expect(File.exists?("spec/testdata/make/main/obj")).to be == true
    expect(File.exists?("spec/testdata/make/main/project.exe")).to be == true

    expect($mystring.split("make clean").length).to be == 2
    expect($mystring.split("Cleaning done.").length).to be == 2
    expect(ExitHelper.exit_code).to be == 0
  end

  #######################################################################

  it 'dry compiler lib exe cmd when cleaned' do
    Bake.startBake("simple/main", ["test_ok", "--dry"])

    expect(File.exists?("spec/testdata/simple/main/build/test_ok/main"+Bake::Toolchain.outputEnding)).to be == false
    expect(File.exists?("spec/testdata/simple/main/build/test_ok/main"+Bake::Toolchain.outputEnding+".cmdline")).to be == false
    expect(File.exists?("spec/testdata/simple/main/build/test_ok/src/x.cmdline")).to be == false
    expect(File.exists?("spec/testdata/simple/main/build/test_ok/src/x.d")).to be == false
    expect(File.exists?("spec/testdata/simple/main/build/test_ok/src/x.d.bake")).to be == false
    expect(File.exists?("spec/testdata/simple/main/build/test_ok/src/x.o")).to be == false
    expect(File.exists?("spec/testdata/simple/main/build")).to be == false
    expect(File.exists?("spec/testdata/simple/lib/build/test_ok_main_test_ok/liblib.a")).to be == false
    expect(File.exists?("spec/testdata/simple/lib/build/test_ok_main_test_ok/liblib.a.cmdline")).to be == false
    expect(File.exists?("spec/testdata/simple/lib/build")).to be == false

    expect($mystring.include?("Compiling lib (test_ok): src/y.cpp")).to be == true
    expect($mystring.include?("Creating  lib (test_ok): build/test_ok_main_test_ok/liblib.a")).to be == true
    expect($mystring.include?("Compiling main (test_ok): src/x.cpp")).to be == true
    expect($mystring.include?("Linking   main (test_ok): build/test_ok/main"+Bake::Toolchain.outputEnding)).to be == true

    expect($mystring.split("abc").length).to be == 2

    expect($mystring.include?("Building done.")).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'dry compiler lib exe cmd when built' do
    Bake.startBake("simple/main", ["test_ok"])
    $mystring.clear
    Bake.startBake("simple/main", ["test_ok", "--dry"])

    expect(File.exists?("spec/testdata/simple/main/build/test_ok/main"+Bake::Toolchain.outputEnding)).to be == true
    expect(File.exists?("spec/testdata/simple/main/build/test_ok/main"+Bake::Toolchain.outputEnding+".cmdline")).to be == true
    expect(File.exists?("spec/testdata/simple/main/build/test_ok/src/x.cmdline")).to be == true
    expect(File.exists?("spec/testdata/simple/main/build/test_ok/src/x.d")).to be == true
    expect(File.exists?("spec/testdata/simple/main/build/test_ok/src/x.d.bake")).to be == true
    expect(File.exists?("spec/testdata/simple/main/build/test_ok/src/x.o")).to be == true
    expect(File.exists?("spec/testdata/simple/main/build")).to be == true
    expect(File.exists?("spec/testdata/simple/lib/build/test_ok_main_test_ok/liblib.a")).to be == true
    expect(File.exists?("spec/testdata/simple/lib/build/test_ok_main_test_ok/liblib.a.cmdline")).to be == true
    expect(File.exists?("spec/testdata/simple/lib/build")).to be == true

    expect($mystring.include?("Compiling src/y.cpp")).to be == false
    expect($mystring.include?("Creating build/test_ok_main_test_ok/liblib.a")).to be == false
    expect($mystring.include?("Compiling src/x.cpp")).to be == false
    expect($mystring.include?("Linking build/test_ok/main"+Bake::Toolchain.outputEnding)).to be == false

    expect($mystring.split("abc").length).to be == 2

    expect($mystring.include?("Building done.")).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'dry compiler exe lib cmd clean when cleaned' do
    Bake.startBake("simple/main", ["test_ok", "-c", "--dry", "-v2"])

    expect(File.exists?("spec/testdata/simple/main/build/test_ok/main"+Bake::Toolchain.outputEnding)).to be == false
    expect(File.exists?("spec/testdata/simple/main/build/test_ok/main"+Bake::Toolchain.outputEnding+".cmdline")).to be == false
    expect(File.exists?("spec/testdata/simple/main/build/test_ok/src/x.cmdline")).to be == false
    expect(File.exists?("spec/testdata/simple/main/build/test_ok/src/x.d")).to be == false
    expect(File.exists?("spec/testdata/simple/main/build/test_ok/src/x.d.bake")).to be == false
    expect(File.exists?("spec/testdata/simple/main/build/test_ok/src/x.o")).to be == false
    expect(File.exists?("spec/testdata/simple/main/build")).to be == false
    expect(File.exists?("spec/testdata/simple/lib/build/test_ok_main_test_ok/liblib.a")).to be == false
    expect(File.exists?("spec/testdata/simple/lib/build/test_ok_main_test_ok/liblib.a.cmdline")).to be == false
    expect(File.exists?("spec/testdata/simple/lib/build")).to be == false

    expect($mystring.split("Deleting folder build/test_ok_main_test_ok").length).to be == 1
    expect($mystring.split("Deleting folder build").length).to be == 1
    expect($mystring.split("Deleting folder build/test_ok").length).to be == 1

    expect($mystring.split("abc").length).to be == 1

    expect($mystring.include?("Cleaning done.")).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'dry compiler exe lib cmd clean when built' do
    Bake.startBake("simple/main", ["test_ok"])
    $mystring.clear
    Bake.startBake("simple/main", ["test_ok", "-c", "--dry", "-v2"])

    expect(File.exists?("spec/testdata/simple/main/build/test_ok/main"+Bake::Toolchain.outputEnding)).to be == true
    expect(File.exists?("spec/testdata/simple/main/build/test_ok/main"+Bake::Toolchain.outputEnding+".cmdline")).to be == true
    expect(File.exists?("spec/testdata/simple/main/build/test_ok/src/x.cmdline")).to be == true
    expect(File.exists?("spec/testdata/simple/main/build/test_ok/src/x.d")).to be == true
    expect(File.exists?("spec/testdata/simple/main/build/test_ok/src/x.d.bake")).to be == true
    expect(File.exists?("spec/testdata/simple/main/build/test_ok/src/x.o")).to be == true
    expect(File.exists?("spec/testdata/simple/main/build")).to be == true
    expect(File.exists?("spec/testdata/simple/lib/build/test_ok_main_test_ok/liblib.a")).to be == true
    expect(File.exists?("spec/testdata/simple/lib/build/test_ok_main_test_ok/liblib.a.cmdline")).to be == true
    expect(File.exists?("spec/testdata/simple/lib/build")).to be == true

    expect($mystring.split("Deleting folder build/test_ok_main_test_ok").length).to be == 2
    expect($mystring.split("Deleting folder build").length).to be == 3
    expect($mystring.split("Deleting folder build/test_ok").length).to be == 3

    expect($mystring.split("abc").length).to be == 1

    expect($mystring.include?("Cleaning done.")).to be == true
    expect(ExitHelper.exit_code).to be == 0

  end

  #######################################################################
end

end
