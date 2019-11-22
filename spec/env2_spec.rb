#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'bake/util'
require 'common/exit_helper'
require 'socket'
require 'fileutils'

module Bake

describe "env toolchain" do

  it 'without vars, without env' do
    ENV["BAKE_C_COMPILER"] = nil
    ENV["BAKE_CPP_COMPILER"] = nil
    ENV["BAKE_ASM_COMPILER"] = nil
    ENV["BAKE_ARCHIVER"] = nil
    ENV["BAKE_LINKER"] = nil
    ENV["BAKE_C_FLAGS"] = nil
    ENV["BAKE_CPP_FLAGS"] = nil
    ENV["BAKE_ASM_FLAGS"] = nil
    ENV["BAKE_ARCHIVER_FLAGS"] = nil
    ENV["BAKE_LINKER_FLAGS"] = nil

    Bake.startBake("env2/main", ["test_exe_without", "-v2", "--dry", "-O"])
    expect(ExitHelper.exit_code).to be == 0

    expect($mystring.include?("g++ -c -MD -MF build/test_lib_without_main_test_exe_without/src/x.d -o")).to be == true
    expect($mystring.include?("gcc -c -MD -MF build/test_lib_without_main_test_exe_without/src/y.d -o")).to be == true
    expect($mystring.include?("ar -rc")).to be == true
    expect($mystring.include?("gcc -c -o")).to be == true
    expect($mystring.include?("g++ -o")).to be == true
  end

  it 'without vars, with env' do
    ENV["BAKE_C_COMPILER"] = "ccomp"
    ENV["BAKE_CPP_COMPILER"] = "cppcomp"
    ENV["BAKE_ASM_COMPILER"] = "asmcomp"
    ENV["BAKE_ARCHIVER"] = "archi"
    ENV["BAKE_LINKER"] = "linki"
    ENV["BAKE_C_FLAGS"] = "cflags"
    ENV["BAKE_CPP_FLAGS"] = "cppflags"
    ENV["BAKE_ASM_FLAGS"] = "asmflags"
    ENV["BAKE_ARCHIVER_FLAGS"] = "aflags"
    ENV["BAKE_LINKER_FLAGS"] = "lflags"

    Bake.startBake("env2/main", ["test_exe_without", "-v2", "--dry", "-O"])
    expect(ExitHelper.exit_code).to be == 0

    expect($mystring.include?("cppcomp -c -MD -MF build/test_lib_without_main_test_exe_without/src/x.d cppflags -o")).to be == true
    expect($mystring.include?("ccomp -c -MD -MF build/test_lib_without_main_test_exe_without/src/y.d cflags -o")).to be == true
    expect($mystring.include?("archi aflags -rc")).to be == true
    expect($mystring.include?("asmcomp -c asmflags -o")).to be == true
    expect($mystring.include?("linki lflags -o")).to be == true
  end

  it 'with vars, without env' do
    ENV["BAKE_C_COMPILER"] = nil
    ENV["BAKE_CPP_COMPILER"] = nil
    ENV["BAKE_ASM_COMPILER"] = nil
    ENV["BAKE_ARCHIVER"] = nil
    ENV["BAKE_LINKER"] = nil
    ENV["BAKE_C_FLAGS"] = nil
    ENV["BAKE_CPP_FLAGS"] = nil
    ENV["BAKE_ASM_FLAGS"] = nil
    ENV["BAKE_ARCHIVER_FLAGS"] = nil
    ENV["BAKE_LINKER_FLAGS"] = nil

    Bake.startBake("env2/main", ["test_exe_with", "-v2", "--dry", "-O"])
    expect(ExitHelper.exit_code).to be == 0

    expect($mystring.include?("gaga1 -c -MD -MF build/test_lib_with_main_test_exe_with/src/x.d -gugu1 -o")).to be == true
    expect($mystring.include?("gaga2 -c -MD -MF build/test_lib_with_main_test_exe_with/src/y.d -gugu2 -o")).to be == true
    expect($mystring.include?("gaga4 -gugu4 -rc")).to be == true
    expect($mystring.include?("gaga3 -c -gugu3 -o")).to be == true
    expect($mystring.include?("gaga5 -gugu5 -o")).to be == true
  end

  it 'with vars, with env' do
    ENV["BAKE_C_COMPILER"] = "ccomp"
    ENV["BAKE_CPP_COMPILER"] = "cppcomp"
    ENV["BAKE_ASM_COMPILER"] = "asmcomp"
    ENV["BAKE_ARCHIVER"] = "archi"
    ENV["BAKE_LINKER"] = "linki"
    ENV["BAKE_C_FLAGS"] = "cflags"
    ENV["BAKE_CPP_FLAGS"] = "cppflags"
    ENV["BAKE_ASM_FLAGS"] = "asmflags"
    ENV["BAKE_ARCHIVER_FLAGS"] = "aflags"
    ENV["BAKE_LINKER_FLAGS"] = "lflags"

    Bake.startBake("env2/main", ["test_exe_with", "-v2", "--dry", "-O"])
    expect(ExitHelper.exit_code).to be == 0

    expect($mystring.include?("gaga1 -c -MD -MF build/test_lib_with_main_test_exe_with/src/x.d cppflags -gugu1 -o")).to be == true
    expect($mystring.include?("gaga2 -c -MD -MF build/test_lib_with_main_test_exe_with/src/y.d cflags -gugu2 -o")).to be == true
    expect($mystring.include?("gaga4 aflags -gugu4 -rc")).to be == true
    expect($mystring.include?("gaga3 -c asmflags -gugu3 -o")).to be == true
    expect($mystring.include?("gaga5 lflags -gugu5 -o")).to be == true
  end

end

end
