#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'socket'
require 'fileutils'

module Bake

describe "linklevel" do

  it 'normal' do
    Bake.startBake("linkLevel/main", ["test", "-v2"])
    expect($mystring.include?("a.cpp")).to be == true
    expect($mystring.include?("b.cpp")).to be == true
    expect($mystring.include?("c.cpp")).to be == true
    expect($mystring.include?("x.cpp")).to be == true
    expect($mystring.include?("ar -rc build/test_main_test/liba.a")).to be == true
    expect($mystring.include?("ar -rc build/test_main_test/libb.a")).to be == true
    expect($mystring.include?("ar -rc build/test_main_test/libc.a")).to be == true
    expect($mystring.include?("g++ -o build/test/main"+Bake::Toolchain.outputEnding+" build/test/src/x.o ../a/build/test_main_test/liba.a ../b/build/test_main_test/libb.a -L../b/SP_B_SP -L../a/SP_A_SP -LSP_MAIN_SP ../c/build/test_main_test/libc.a -L../c/SP_C_SP")).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'link level' do
    Bake.startBake("linkLevel/main", ["test_direct", "-v2"])
    expect($mystring.include?("a.cpp")).to be == true
    expect($mystring.include?("b.cpp")).to be == true
    expect($mystring.include?("c.cpp")).to be == true
    expect($mystring.include?("x.cpp")).to be == true
    expect($mystring.include?("ar -rc build/test_main_test_direct/liba.a")).to be == true
    expect($mystring.include?("ar -rc build/test_main_test_direct/libb.a")).to be == true
    expect($mystring.include?("ar -rc build/test_main_test_direct/libc.a")).to be == true
    expect($mystring.include?("g++ -o build/test_direct/main"+Bake::Toolchain.outputEnding+" build/test_direct/src/x.o ../a/build/test_main_test_direct/liba.a -LSP_MAIN_SP ../c/build/test_main_test_direct/libc.a")).to be == true
    expect(ExitHelper.exit_code).to be > 0
  end
end

end
