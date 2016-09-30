#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'socket'
require 'fileutils'

module Bake

describe "Caching" do

  it 'meta files should be cached' do
    # no cache files
    Bake.startBake("cache/main", ["-b", "test", "-v3"])

    expect($mystring.split("Loading and caching").length).to be == 3
    expect($mystring.split("Loading cached").length).to be == 1

    # project meta cache file exists
    File.delete("spec/testdata/cache/main/.bake/Project.meta.test.cache")
    Bake.startBake("cache/main", ["-b", "test", "-v3"])
    expect($mystring.split("Loading and caching").length).to be == 3
    expect($mystring.split("Loading cached").length).to be == 3

    # build meta cache file exists
    File.delete("spec/testdata/cache/main/.bake/Project.meta.cache")
    Bake.startBake("cache/main", ["-b", "test", "-v3"])
    expect($mystring.split("Loading and caching").length).to be == 3
    expect($mystring.split("Loading cached").length).to be == 3

    # force re read meta files
    Bake.startBake("cache/main", ["-b", "test", "-v3", "--ignore_cache"])
    expect($mystring.split("Loading and caching").length).to be == 5
    expect($mystring.split("Loading cached").length).to be == 3
    expect($mystring.split("Info: cache is up-to-date, loading cached meta information").length).to be == 2

    # force re read meta files creates all files if necessary
    FileUtils.rm_rf("spec/testdata/cache/main/.bake")
    Bake.startBake("cache/main", ["-b", "test", "-v3", "--ignore-cache"])
    expect($mystring.split("Loading and caching").length).to be == 7
    expect($mystring.split("Loading cached").length).to be == 3
    expect($mystring.split("Info: cache is up-to-date, loading cached meta information").length).to be == 2
    expect(File.exists?("spec/testdata/cache/main/.bake/Project.meta.cache")).to be == true
    expect(File.exists?("spec/testdata/cache/main/.bake/Project.meta.test.cache")).to be == true
  end

end

end
