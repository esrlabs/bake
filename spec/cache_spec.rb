#!/usr/bin/env ruby



require 'bake/version'

require 'tocxx'
require 'bake/options'
require 'imported/utils/exit_helper'
require 'socket'
require 'imported/utils/cleanup'
require 'fileutils'
require 'helper'

module Bake

ExitHelper.enable_exit_test

describe "Caching" do
  
  before(:all) do
    Utils.cleanup_rake
  end

  after(:all) do
    ExitHelper.reset_exit_code
  end

  before(:each) do
    $mystring=""
    $sstring=StringIO.open($mystring,"w+")
    $stdoutbackup=$stdout
    $stdout=$sstring
  end
  after(:each) do
    $stdout=$stdoutbackup
  end

  it 'meta files should be cached' do
    # no cache files  
    SpecHelper.clean_testdata_build("cache","main","test")
    Utils.cleanup_rake
    options = Options.new(["-m", "spec/testdata/cache/main", "-b", "test", "-v2"])
    options.parse_options()
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    expect($mystring.split("Loading and caching").length).to be == 3
    expect($mystring.split("Loading cached").length).to be == 1

    # project meta cache file exists    
    File.delete("spec/testdata/cache/main/.bake/Project.meta.test.cache")
    Utils.cleanup_rake
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    expect($mystring.split("Loading and caching").length).to be == 3
    expect($mystring.split("Loading cached").length).to be == 3
    
    # build meta cache file exists
    File.delete("spec/testdata/cache/main/.bake/Project.meta.cache")
    Utils.cleanup_rake
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    expect($mystring.split("Loading and caching").length).to be == 3
    expect($mystring.split("Loading cached").length).to be == 3
    
    # force re read meta files
    options = Options.new(["-m", "spec/testdata/cache/main", "-b", "test", "--ignore_cache", "-v2"])
    options.parse_options()
    Utils.cleanup_rake
    tocxx = Bake::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    expect($mystring.split("Loading and caching").length).to be == 5
    expect($mystring.split("Loading cached").length).to be == 3
    expect($mystring.split("Info: cache is up-to-date, loading cached meta information").length).to be == 2
    
    # force re read meta files creates all files if necessary
    SpecHelper.clean_testdata_build("cache","main","test")
    Utils.cleanup_rake
    tocxx.doit()
    tocxx.start()
    expect($mystring.split("Loading and caching").length).to be == 7
    expect($mystring.split("Loading cached").length).to be == 3
    expect($mystring.split("Info: cache is up-to-date, loading cached meta information").length).to be == 2
    expect(File.exists?("spec/testdata/cache/main/.bake/Project.meta.cache")).to be == true
    expect(File.exists?("spec/testdata/cache/main/.bake/Project.meta.test.cache")).to be == true
  end
  
end

end
