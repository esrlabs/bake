#!/usr/bin/env ruby

$:.unshift(File.dirname(__FILE__)+"/../../cxxproject/lib")

require 'bake/version'

require 'tocxx'
require 'bake/options'
require 'cxxproject/utils/exit_helper'
require 'socket'
require 'cxxproject/utils/cleanup'
require 'fileutils'
require 'helper'

module Cxxproject

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
    tocxx = Cxxproject::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    $mystring.split("Loading and caching").length.should == 3
    $mystring.split("Loading cached").length.should == 1

    # project meta cache file exists    
    File.delete("spec/testdata/cache/main/.bake/Project.meta.test.cache")
    Utils.cleanup_rake
    tocxx = Cxxproject::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    $mystring.split("Loading and caching").length.should == 3
    $mystring.split("Loading cached").length.should == 3
    
    # build meta cache file exists
    File.delete("spec/testdata/cache/main/.bake/Project.meta.cache")
    Utils.cleanup_rake
    tocxx = Cxxproject::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    $mystring.split("Loading and caching").length.should == 3
    $mystring.split("Loading cached").length.should == 3
    
    # force re read meta files
    options = Options.new(["-m", "spec/testdata/cache/main", "-b", "test", "--ignore_cache", "-v2"])
    options.parse_options()
    Utils.cleanup_rake
    tocxx = Cxxproject::ToCxx.new(options)
    tocxx.doit()
    tocxx.start()
    $mystring.split("Loading and caching").length.should == 5
    $mystring.split("Loading cached").length.should == 3
    $mystring.split("Info: cache is up-to-date, loading cached meta information").length.should == 2
    
    # force re read meta files creates all files if necessary
    SpecHelper.clean_testdata_build("cache","main","test")
    Utils.cleanup_rake
    tocxx.doit()
    tocxx.start()
    $mystring.split("Loading and caching").length.should == 7
    $mystring.split("Loading cached").length.should == 3
    $mystring.split("Info: cache is up-to-date, loading cached meta information").length.should == 2
    File.exists?("spec/testdata/cache/main/.bake/Project.meta.cache").should == true
    File.exists?("spec/testdata/cache/main/.bake/Project.meta.test.cache").should == true
  end
  
end

end
