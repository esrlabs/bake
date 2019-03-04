#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'

module Bake

describe "Building" do

  it 'search Project.meta' do
    expect(File.exists?("spec/testdata/simple/main/build/test_ok/main"+Bake::Toolchain.outputEnding)).to be == false
    Bake.startBake("simple/main/src", ["test_ok"])
    expect(ExitHelper.exit_code).to be == 0
    expect($mystring.include?("Building done")).to be == true
    expect(File.exists?("spec/testdata/simple/main/build/test_ok/main"+Bake::Toolchain.outputEnding)).to be == true
  end

  it 'sameObj' do
    expect(File.exists?("spec/testdata/sameObj/main/build/test/main"+Bake::Toolchain.outputEnding)).to be == false

    Bake.startBake("sameObj/main", ["test"])

    expect($mystring.include?("Source files 'src/x.c' and 'src/x.cpp' would result in the same object file")).to be == true
    expect(ExitHelper.exit_code).to be > 0
  end

  it 'workspace' do
    expect(File.exists?("spec/testdata/cache/main/build_test/main"+Bake::Toolchain.outputEnding)).to be == false

    Bake.startBake("cache/main", ["-b", "test", "-v2", "--build_"])

    expect(File.exists?("spec/testdata/cache/main/build_test/main"+Bake::Toolchain.outputEnding)).to be == true

    expect($mystring.split("PREMAIN").length).to be == 3
    expect($mystring.split("POSTMAIN").length).to be == 3

    expect($mystring.include?("../lib1/build_testsub_main_test/this.name makefile/dummy.a")).to be == true # makefile lib shall be put to the end of the lib string
  end

  it 'single lib' do
    expect(File.exists?("spec/testdata/cache/main/build_test/main"+Bake::Toolchain.outputEnding)).to be == false

    Bake.startBake("cache/main", ["-p", "lib1", "-b", "test", "--build_"])

    expect(File.exists?("spec/testdata/cache/lib1/build_testsub_main_test/this.name")).to be == true
    expect(File.exists?("spec/testdata/cache/main/build_test/main"+Bake::Toolchain.outputEnding)).to be == false

    expect($mystring.split("PRELIB1").length).to be == 3
    expect($mystring.split("POSTLIB1").length).to be == 3
  end

  it 'single exe should fail' do
    expect(File.exists?("spec/testdata/cache/lib1/testsub_main_test/src/lib1.o")).to be == false
    expect(File.exists?("spec/testdata/cache/lib1/testsub_main_test/this.name")).to be == false

    expect(File.exists?("spec/testdata/cache/main/build/test/src/main.o")).to be == false
    expect(File.exists?("spec/testdata/cache/main/build/test/main"+Bake::Toolchain.outputEnding)).to be == false

    Bake.startBakeWithChangeDir("cache/main", ["-p", ".", "-b", "test"])

    expect(File.exists?("spec/testdata/cache/lib1/build/testsub_main_test/src/lib1.o")).to be == false
    expect(File.exists?("spec/testdata/cache/lib1/build/testsub_main_test/this.name")).to be == false

    expect(File.exists?("spec/testdata/cache/main/build/test/src/main.o")).to be == true
    expect(File.exists?("spec/testdata/cache/main/build/test/main"+Bake::Toolchain.outputEnding)).to be == false

    expect($mystring.split("PREMAIN").length).to be == 3
    expect($mystring.split("POSTMAIN").length).to be == 1 # means not executed cause exe build failed

    expect(ExitHelper.exit_code).to be > 0
  end

  it 'single file' do
    expect(File.exists?("spec/testdata/cache/main/build/test/src/main.o")).to be == false
    expect(File.exists?("spec/testdata/cache/main/build/test/main"+Bake::Toolchain.outputEnding)).to be == false

    Bake.startBake("cache/main", ["-b", "test", "-f", "src/main.cpp"])

    expect(File.exists?("spec/testdata/cache/main/build/test/src/main.o")).to be == true
    expect(File.exists?("spec/testdata/cache/main/build/test/main"+Bake::Toolchain.outputEnding)).to be == false

    expect(ExitHelper.exit_code).to be == 0
  end

  it 'clean single file' do
    Bake.startBake("cache/main", ["-b", "test"])

    expect(File.exists?("spec/testdata/cache/main/build/test/src/main.o")).to be == true
    expect(File.exists?("spec/testdata/cache/main/build/test/src/main.d")).to be == true
    expect(File.exists?("spec/testdata/cache/main/build/test/main"+Bake::Toolchain.outputEnding)).to be == true

    Bake.startBake("cache/main", ["-b", "test", "-f", "src/main.cpp", "-c"])

    expect(File.exists?("spec/testdata/cache/main/build/test/src/main.o")).to be == false
    expect(File.exists?("spec/testdata/cache/main/build/test/src/main.d")).to be == false
    expect(File.exists?("spec/testdata/cache/main/build/test/main"+Bake::Toolchain.outputEnding)).to be == true

    expect(ExitHelper.exit_code).to be == 0
  end

  it 'multiple file 1' do
    expect(File.exists?("spec/testdata/cache/main/build/testMultiFile/src/multi.o")).to be == false
    expect(File.exists?("spec/testdata/cache/main/build/testMultiFile/src/x/multi.o")).to be == false
    expect(File.exists?("spec/testdata/cache/lib1/build/testMultiFile_main_testMultiFile/src/multi.o")).to be == false

    Bake.startBake("cache/main", ["-b", "testMultiFile", "-f", "src/multi.cpp"])

    expect(File.exists?("spec/testdata/cache/main/build/testMultiFile/src/multi.o")).to be == true
    expect(File.exists?("spec/testdata/cache/main/build/testMultiFile/src/x/multi.o")).to be == false
    expect(File.exists?("spec/testdata/cache/lib1/build/testMultiFile_main_testMultiFile/src/multi.o")).to be == true

    Bake.startBake("cache/main", ["-b", "testMultiFile", "-f", "src/multi.cpp", "-c"])

    expect(File.exists?("spec/testdata/cache/main/build/testMultiFile/src/multi.o")).to be == false
    expect(File.exists?("spec/testdata/cache/main/build/testMultiFile/src/x/multi.o")).to be == false
    expect(File.exists?("spec/testdata/cache/lib1/build/testMultiFile_main_testMultiFile/src/multi.o")).to be == false

    expect(ExitHelper.exit_code).to be == 0
  end

  it 'multiple file 2' do
    expect(File.exists?("spec/testdata/cache/main/build/testMultiFile/src/multi.o")).to be == false
    expect(File.exists?("spec/testdata/cache/main/build/testMultiFile/src/x/multi.o")).to be == false
    expect(File.exists?("spec/testdata/cache/lib1/build/testMultiFile_main_testMultiFile/src/multi.o")).to be == false

    Bake.startBake("cache/main", ["-b", "testMultiFile", "-f", "multi.cpp"])

    expect(File.exists?("spec/testdata/cache/main/build/testMultiFile/src/multi.o")).to be == true
    expect(File.exists?("spec/testdata/cache/main/build/testMultiFile/src/x/multi.o")).to be == true
    expect(File.exists?("spec/testdata/cache/lib1/build/testMultiFile_main_testMultiFile/src/multi.o")).to be == true

    Bake.startBake("cache/main", ["-b", "testMultiFile", "-f", "multi.cpp", "-c"])

    expect(File.exists?("spec/testdata/cache/main/build/testMultiFile/src/multi.o")).to be == false
    expect(File.exists?("spec/testdata/cache/main/build/testMultiFile/src/x/multi.o")).to be == false
    expect(File.exists?("spec/testdata/cache/lib1/build/testMultiFile_main_testMultiFile/src/multi.o")).to be == false

    expect(ExitHelper.exit_code).to be == 0
  end

  it 'clean single lib' do
    Bake.startBake("cache/main", ["-b", "test"])

    expect(File.exists?("spec/testdata/cache/main/build/test")).to be == true
    expect(File.exists?("spec/testdata/cache/lib1/build/testsub_main_test")).to be == true
    expect(File.exists?("spec/testdata/cache/lib1/build/testsub_main_test/this.name")).to be == true
    expect(File.exists?("spec/testdata/cache/main/build/test/main"+Bake::Toolchain.outputEnding)).to be == true

    Bake.startBake("cache/main", ["-b", "test", "-p", "lib1", "-c"])

    expect(File.exists?("spec/testdata/cache/main/build/test")).to be == true
    expect(File.exists?("spec/testdata/cache/lib1/build/testsub_main_test")).to be == false
    expect(File.exists?("spec/testdata/cache/lib1/build/testsub_main_test/this.name")).to be == false
    expect(File.exists?("spec/testdata/cache/main/build/test/main"+Bake::Toolchain.outputEnding)).to be == true

    expect(ExitHelper.exit_code).to be == 0
  end

  it 'clean single lib' do
    Bake.startBake("cache/main", ["-b", "test"])

    expect(File.exists?("spec/testdata/cache/main/build/test")).to be == true
    expect(File.exists?("spec/testdata/cache/lib1/build/testsub_main_test")).to be == true
    expect(File.exists?("spec/testdata/cache/lib1/build/testsub_main_test/this.name")).to be == true
    expect(File.exists?("spec/testdata/cache/main/build/test/main"+Bake::Toolchain.outputEnding)).to be == true

    Bake.startBakeWithChangeDir("cache/main", ["-b", "test","-p", ".", "-c"])

    expect(File.exists?("spec/testdata/cache/main/build/test")).to be == false
    expect(File.exists?("spec/testdata/cache/lib1/build/testsub_main_test")).to be == true
    expect(File.exists?("spec/testdata/cache/lib1/build/testsub_main_test/this.name")).to be == true
    expect(File.exists?("spec/testdata/cache/main/build/test/main"+Bake::Toolchain.outputEnding)).to be == false

    expect(ExitHelper.exit_code).to be == 0
  end

  it 'clobber' do
    Bake.startBake("cache/main", ["-b", "test"])

    expect(File.exists?("spec/testdata/cache/main/.bake")).to be == true
    expect(File.exists?("spec/testdata/cache/lib1/.bake")).to be == true

    Bake.startBake("cache/main", ["-b", "test", "--clobber"])

    expect(File.exists?("spec/testdata/cache/main/.bake")).to be == false
    expect(File.exists?("spec/testdata/cache/lib1/.bake")).to be == false
  end

  it 'clobber project only' do
    Bake.startBake("cache/main", ["-b", "test", "-p", "lib1"])

    expect(File.exists?("spec/testdata/cache/main/.bake")).to be == true
    expect(File.exists?("spec/testdata/cache/lib1/.bake")).to be == true

    Bake.startBake("cache/main", ["-b", "test", "-p", "lib1", "--clobber"])

    expect(File.exists?("spec/testdata/cache/main/.bake")).to be == true
    expect(File.exists?("spec/testdata/cache/lib1/.bake")).to be == false
  end


  it 'no src for lib' do
    Bake.startBake("noFiles/main", ["testLib", "--rebuild"])
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'no src for exe' do
    Bake.startBake("noFiles/main", ["testExe", "--rebuild"])
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'no src for pattern*' do
    Bake.startBake("noFiles/main", ["testFilePattern1DoesNotExist", "--rebuild"])
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'no src for pattern?' do
    Bake.startBake("noFiles/main", ["testFilePattern2DoesNotExist", "--rebuild"])
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'no src for src' do
    Bake.startBake("noFiles/main", ["testFileDoesNotExist", "--rebuild"])
    expect(ExitHelper.exit_code).to be > 0
    expect($mystring.include?("Compiling")).to be == false
    expect($mystring.include?("Creating")).to be == false
  end

  it 'three exes' do
    Bake.startBake("threeExe/main", ["test", "-v2"])
    expect(ExitHelper.exit_code).to be == 0

    exe1 = "g++ -o build/test_main_test/exe1"+Bake::Toolchain.outputEnding+" build/test_main_test/src/main.o ../lib1/build/test_main_test/liblib1.a"
    exe2 = "g++ -o build/test_main_test/exe2"+Bake::Toolchain.outputEnding+" build/test_main_test/src/main.o ../lib2/build/test_main_test/liblib2.a"
    exe3 = "g++ -o build/test_main_test/exe3"+Bake::Toolchain.outputEnding+" build/test_main_test/src/main.o ../lib2/build/test_main_test/liblib2.a ../lib3/build/test_main_test/liblib3.a"
    main = "g++ -o build/test/main"+Bake::Toolchain.outputEnding+" build/test/src/main.o ../lib1/build/test_main_test/liblib1.a ../lib2/build/test_main_test/liblib2.a ../lib3/build/test_main_test/liblib3.a"
    expect($mystring.include?(exe1)).to be == true
    expect($mystring.include?(exe2)).to be == true
    expect($mystring.include?(exe3)).to be == true
    expect($mystring.include?(main)).to be == true
  end

  it 'MapFileEmpty' do
    Bake.startBake("cache/main", ["testMapEmpty", "-v2"])
    expect($mystring.include?("build/testMapEmpty/main.map")).to be == true
    expect(File.exist?("spec/testdata/cache/main/build/testMapEmpty/main.map")).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'MapFileDada' do
    Bake.startBake("cache/main", ["testMapDada", "-v2"])
    expect($mystring.include?("build/testMapDada/dada.map")).to be == true
    expect(File.exist?("spec/testdata/cache/main/build/testMapDada/dada.map")).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'LibHasError_noLink' do
    Bake.startBake("errors/main", ["testWrong"])
    expect($mystring.include?("testWrong/main"+Bake::Toolchain.outputEnding)).to be == false
  end

  it 'ExeHasError_noLink' do
    Bake.startBake("errors/main", ["testWrong2"])
    expect($mystring.include?("testWrong2/main"+Bake::Toolchain.outputEnding)).to be == false
  end

  it 'assembler' do
    Bake.startBake("assembler", ["test"])

    expect($mystring.include?("a.S")).to be == true
    expect($mystring.include?("main.cpp")).to be == true
    expect($mystring.include?("test/assembler"+Bake::Toolchain.outputEnding)).to be == true

    Bake.startBake("assembler", ["test"])

    expect(ExitHelper.exit_code).to be == 0
  end

  it 'touch header' do
    Bake.startBake("header/main", ["test"])
    expect($mystring.split("Compiling").length).to be == 2
    Bake.startBake("header/main", ["test"])
    expect($mystring.split("Compiling").length).to be == 2

    sleep 2
    FileUtils.touch("spec/testdata/header/main/include/inc1.h")

    Bake.startBake("header/main", ["test"])
    expect($mystring.split("Compiling").length).to be == 3
  end

  it 'start with all' do
    Bake.startBake("startwith/main", ["test"])
    expect($mystring.include?("echo main")).to be == true
    expect($mystring.include?("echo main2")).to be == true
  end

  it 'start with only proj' do
    Bake.startBake("startwith/main", ["test", "-p", "main"])
    expect($mystring.include?("echo main")).to be == true
    expect($mystring.include?("echo main2")).to be == false
  end

  it 'warning if source compiled more than once' do
    Bake.startBake("simple/main", ["test_doubleSource", "--link_only"])
    expect($mystring.include?("Source compiled more than once")).to be == true
    expect($mystring.include?("spec/testdata/simple/main/src/x.cpp")).to be == true
  end

  it 'warning if source compiled more than once link-only' do
    Bake.startBake("simple/main", ["test_doubleSource", "--link-only"])
    expect($mystring.include?("Source compiled more than once")).to be == true
    expect($mystring.include?("spec/testdata/simple/main/src/x.cpp")).to be == true
  end

  it 'compileOnly' do
    expect(File.exists?("spec/testdata/cache/main/build/testMultiFileExe/src/multi.o")).to be == false
    expect(File.exists?("spec/testdata/cache/main/build/testMultiFileExe/src/x/multi.o")).to be == false
    expect(File.exists?("spec/testdata/cache/lib1/build/testMultiFile_main_testMultiFileExe/src/multi.o")).to be == false
    expect(File.exists?("spec/testdata/cache/lib1/build/testMultiFile_main_testMultiFileExe/src/liblib1.o")).to be == false
    expect(File.exists?("spec/testdata/cache/lib1/build/testMultiFile_main_testMultiFileExe/lib1.a")).to be == false
    expect(File.exists?("spec/testdata/cache/main/build/testMultiFileExe/main"+Bake::Toolchain.outputEnding)).to be == false

    Bake.startBake("cache/main", ["-b", "testMultiFileExe", "--compile-only"])
    expect(File.exists?("spec/testdata/cache/main/build/testMultiFileExe/src/multi.o")).to be == true
    expect(File.exists?("spec/testdata/cache/main/build/testMultiFileExe/src/x/multi.o")).to be == true
    expect(File.exists?("spec/testdata/cache/lib1/build/testMultiFile_main_testMultiFileExe/src/multi.o")).to be == true
    expect(File.exists?("spec/testdata/cache/lib1/build/testMultiFile_main_testMultiFileExe/src/lib1.o")).to be == true
    expect(File.exists?("spec/testdata/cache/lib1/build/testMultiFile_main_testMultiFileExe/liblib1.a")).to be == false
    expect(File.exists?("spec/testdata/cache/main/build/testMultiFileExe/main"+Bake::Toolchain.outputEnding)).to be == false
    expect(ExitHelper.exit_code).to be == 0

    Bake.startBake("cache/main", ["-b", "testMultiFileExe", "-f", "multi.cpp", "-c"])
    expect(File.exists?("spec/testdata/cache/main/build/testMultiFileExe/src/multi.o")).to be == false
    expect(File.exists?("spec/testdata/cache/main/build/testMultiFileExe/src/x/multi.o")).to be == false
    expect(File.exists?("spec/testdata/cache/lib1/build/testMultiFile_main_testMultiFileExe/src/multi.o")).to be == false
    expect(File.exists?("spec/testdata/cache/lib1/build/testMultiFile_main_testMultiFileExe/src/liblib1.o")).to be == false
    expect(File.exists?("spec/testdata/cache/lib1/build/testMultiFile_main_testMultiFileExe/lib1.a")).to be == false
    expect(File.exists?("spec/testdata/cache/main/build/testMultiFileExe/main"+Bake::Toolchain.outputEnding)).to be == false
    expect(ExitHelper.exit_code).to be == 0

    Bake.startBake("cache/main", ["-b", "testMultiFileExe"])
    expect(File.exists?("spec/testdata/cache/main/build/testMultiFileExe/src/multi.o")).to be == true
    expect(File.exists?("spec/testdata/cache/main/build/testMultiFileExe/src/x/multi.o")).to be == true
    expect(File.exists?("spec/testdata/cache/lib1/build/testMultiFile_main_testMultiFileExe/src/multi.o")).to be == true
    expect(File.exists?("spec/testdata/cache/lib1/build/testMultiFile_main_testMultiFileExe/src/lib1.o")).to be == true
    expect(File.exists?("spec/testdata/cache/lib1/build/testMultiFile_main_testMultiFileExe/liblib1.a")).to be == true
    expect(File.exists?("spec/testdata/cache/main/build/testMultiFileExe/main"+Bake::Toolchain.outputEnding)).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'with wparse' do
    Bake.startBake("set", ["value", "--Wparse"])
    expect(ExitHelper.exit_code).to be > 0
  end

  it 'without wparse' do
    Bake.startBake("set", ["value"])
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'clean build dir if only one project was build' do
    Bake.startBake("simple/main", ["test_ok"])
    expect(ExitHelper.exit_code).to be == 0
    expect(File.exists?("spec/testdata/simple/main/build/test_ok")).to be == true
    expect(File.exists?("spec/testdata/simple/main/build/test_ok2")).to be == false

    Bake.startBake("simple/main", ["test_ok2"])
    expect(ExitHelper.exit_code).to be == 0
    expect(File.exists?("spec/testdata/simple/main/build/test_ok")).to be == true
    expect(File.exists?("spec/testdata/simple/main/build/test_ok2")).to be == true

    Bake.startBake("simple/main", ["test_ok", "-c"])
    expect(ExitHelper.exit_code).to be == 0
    expect(File.exists?("spec/testdata/simple/main/build/test_ok")).to be == false
    expect(File.exists?("spec/testdata/simple/main/build/test_ok2")).to be == true

    Bake.startBake("simple/main", ["test_ok2", "-c"])
    expect(ExitHelper.exit_code).to be == 0
    expect(File.exists?("spec/testdata/simple/main/build/test_ok")).to be == false
    expect(File.exists?("spec/testdata/simple/main/build/test_ok2")).to be == false
    expect(File.exists?("spec/testdata/simple/main/build")).to be == false
  end

  it 'ambigious include dir' do
    Bake.startBake("magic/main", ["test", "-w", "spec/testdata/magic/r1", "-w", "spec/testdata/magic/r2", "-v2"])
    expect(ExitHelper.exit_code).to be == 0
    expect($mystring.include?("Info: lib2/include matches several paths")).to be == true
    expect($mystring.include?("  ../r1/lib2/include (chosen)")).to be == true
    expect($mystring.include?("  lib2/include")).to be == true
    expect($mystring.include?("  ../r2/lib2/include")).to be == true
    expect($mystring.include?("-I../r1/lib2/include")).to be == true
  end

  it 'include order' do
    Bake.startBake("includeOrder/main", ["test1", "-v2"])
    expect(ExitHelper.exit_code).to be == 0
    expect($mystring.include?("-IM1 -IB21 -IB22 -IB11 -IB12 -IB31 -IB32 -IM2")).to be == true
# new:                         -IM1 -IB11 -IB21 -IB22 -IB31 -IB32 -IB12 -IM2

  end

  it 'system include' do
    Bake.startBake("systemInclude/main", ["test", "-v2"])
    expect(ExitHelper.exit_code).to be == 0
    expect($mystring.include?("-Wall -Iinclude/a -isysteminclude/b -isysteminclude/c -isysteminclude/d -o")).to be == true
  end

  it 'call a sub main exists' do
    Bake.startBakeWithPath("spec/testdata/brokenMainDir/main", "some/sub", ["test_1"])
    expect($mystring.include?("THIS IS SUB")).to be == true
  end

  it 'call a sub main does not exist' do
    begin
      Bake.startBakeWithPath("spec/testdata/brokenMainDir/main", "some/subDoesNotExist", ["test_1"])
    rescue Exception
    end
    expect($mystring.include?("THIS IS")).to be == false
    expect($mystring.include?("Error: some/subDoesNotExist does not exist")).to be == true
  end

  it 'no def from commandline' do
    Bake.startBake("simple/main", ["test_ok", "-v2"])
    expect($mystring.include?("DEF2")).to be == false
  end

  it 'no def from commandline' do
    Bake.startBake("simple/main", ["test_ok", "-v2", "-D", "DEF2=3"])
    expect($mystring.include?("-DDEF1 -DDEF2=3")).to be == true
  end

end

end
