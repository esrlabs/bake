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

describe "Synced" do


  it 'Broken build with -r' do
    Bake.startBake("synced/main", ["test_exe2", "-O", "-r"])

    posError = $mystring.index ("src/lib2/f1.o")
    posLib2A = $mystring.index ("(test_lib2)")
    posLib2B = $mystring.rindex("(test_lib2)")
    posLib1A = $mystring.index ("(test_lib1)")
    posLib1B = $mystring.rindex("(test_lib1)")
    posExeA = $mystring.index  ("(test_exe2)")
    posExeB = $mystring.rindex ("(test_exe2)")

    expect(posLib1A.nil? || (posLib1A < posLib2A && posLib1B < posLib2A)).to be == true
    expect(posExeA.nil? || (posExeA < posLib2A && posExeB < posLib2A)).to be == true
    expect(posLib2A < posLib2B).to be == true
    expect(posLib2B < posError).to be == true
  end

  it 'Broken build with -r 2' do
    Bake.startBake("synced/main", ["test_exe2", "-r"])

  end

  it 'Broken build with -r 3' do
    Bake.startBake("synced/main", ["test_exe2", "-O"])

  end

end

end
