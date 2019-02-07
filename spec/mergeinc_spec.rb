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
    Bake.startBake("root1/main", ["test", "-w", "spec/testdata/root1", "-w", "spec/testdata/root2", "-v2", "--merge-inc"])

    expect($mystring.include?("g++ -c -MD -MF build/test_main_test/src/lib2.d -Ibuild/test_main_test/mergedIncludes -o build/test_main_test/src/lib2.o src/lib2.cpp")).to be == true
    expect($mystring.include?("ar -rc build/test_main_test/liblib1.a build/test_main_test/src/anotherOne.o build/test_main_test/src/lib1.o")).to be == true
    expect($mystring.include?("g++ -nostdlib -o build/test/main#{Bake::Toolchain.outputEnding} build/test/src/main.o -T ../../root2/lib2/ls/linkerscript.dld ../lib1/build/test_main_test/liblib1.a ../../root2/lib2/build/test_main_test/liblib2.a")).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end

end

end

