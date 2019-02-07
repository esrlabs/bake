#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'socket'
require 'fileutils'

module Bake

describe "FileCmd" do

  it 'gcc without' do
    Bake.startBake("root1/main", ["test", "-w", "spec/testdata/root1", "-w", "spec/testdata/root2", "-v2", "--adapt", "spec/testdata/root1/main/NoLinkerScript.adapt"])

    expect($mystring.include?("g++ -c -MD -MF build/test_main_test/src/lib2.d -Iinclude -o build/test_main_test/src/lib2.o src/lib2.cpp")).to be == true
    expect($mystring.include?("ar -rc build/test_main_test/liblib2.a build/test_main_test/src/lib2.o")).to be == true
    expect($mystring.include?("g++ -nostdlib -o build/test/main#{Bake::Toolchain.outputEnding} build/test/src/main.o ../lib1/build/test_main_test/liblib1.a ../../root2/lib2/build/test_main_test/liblib2.a")).to be == true

    expect(File.exist?("spec/testdata/root2/lib2/build/test_main_test/src/lib2.o.file")).to be == false
    expect(File.exist?("spec/testdata/root2/lib2/build/test_main_test/liblib2.a.file")).to be == false
    expect(File.exist?("spec/testdata/root1/main/build/test/main#{Bake::Toolchain.outputEnding}.file")).to be == false
    
    expect(ExitHelper.exit_code).to be == 0
  end


  it 'gcc with' do
    Bake.startBake("root1/main", ["test", "-w", "spec/testdata/root1", "-w", "spec/testdata/root2", "-v2", "--file-cmd", "--adapt", "spec/testdata/root1/main/NoLinkerScript.adapt"])

    expect($mystring.include?("g++ @build/test_main_test/src/lib2.o.file")).to be == true
    if Bake::Utils::OS.name != "Mac"
      expect($mystring.include?("ar @build/test_main_test/liblib2.a.file")).to be == true
    end
    expect($mystring.include?("g++ @build/test/main#{Bake::Toolchain.outputEnding}.file")).to be == true

    expect(File.exist?("spec/testdata/root2/lib2/build/test_main_test/src/lib2.o.file")).to be == true
    if Bake::Utils::OS.name != "Mac"
      expect(File.exist?("spec/testdata/root2/lib2/build/test_main_test/liblib2.a.file")).to be == true
    end
    expect(File.exist?("spec/testdata/root1/main/build/test/main#{Bake::Toolchain.outputEnding}.file")).to be == true

    expect(ExitHelper.exit_code).to be == 0
  end

  it 'keil not supported' do
    Bake.startBake("compiler/keil", ["test", "-v2", "--file-cmd"])

    expect($mystring.include?("Warning: file command option not yet supported for this toolchain")).to be == true
    expect($mystring.include?("armcc -c")).to be == true
  end

end

end
