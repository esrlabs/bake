#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'socket'
require 'fileutils'

module Bake

describe "Int Caching" do

  it 'detect copied cache files' do

    Bake.startBake("intcache/main", ["test1", "--debug"])
    expect($mystring.split("lib1/Project.meta").length).to be == 2
    expect($mystring.include?("lib1__")).to be == true

    FileUtils.rm_rf("spec/testdata/intcache/lib2")
    FileUtils.cp_r("spec/testdata/intcache/lib1", "spec/testdata/intcache/lib2")

    Bake.startBake("intcache/main", ["test2", "--debug"])
    expect($mystring.split("lib2/Project.meta").length).to be == 3 # 3 because of debug output
    expect($mystring.include?("lib2__")).to be == true

    FileUtils.rm_rf("spec/testdata/intcache/lib2")

  end

end

end
