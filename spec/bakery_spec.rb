#!/usr/bin/env ruby



require 'bake/version'

require 'tocxx'
require 'bake/options'
require 'imported/utils/exit_helper'
require 'imported/utils/cleanup'
require 'fileutils'
require 'helper'

module Bake

ExitHelper.enable_exit_test

describe "bake" do

  before(:all) do
  end

  after(:all) do
  end

  before(:each) do
    Utils.cleanup_rake
    SpecHelper.clean_testdata_build("root1","main","test")
    SpecHelper.clean_testdata_build("root1","lib1","test_main")
    SpecHelper.clean_testdata_build("root2","lib2","test_main")

    $mystring=""
    $sstring=StringIO.open($mystring,"w+")
    $stdoutbackup=$stdout
    $stdout=$sstring
  end
  
  after(:each) do
    $stdout=$stdoutbackup

    ExitHelper.reset_exit_code
  end

  it 'collection double' do
    str = `ruby bin/bakery -m spec/testdata/root1/main -b double`
    expect(str.include?("found more than once")).to be == true
  end  

  it 'collection empty' do
    str = `ruby bin/bakery -m spec/testdata/root1/main -b gugu`
    expect(str.include?("0 of 0 builds ok")).to be == true
  end  

  it 'collection onlyExclude' do
    str = `ruby bin/bakery -m spec/testdata/root1/main -b gigi`
    expect(str.include?("0 of 0 builds ok")).to be == true
    
  end  

  it 'collection working' do
    str = `ruby bin/bakery -m spec/testdata/root1/main -b gaga -w spec/testdata/root1 -w spec/testdata/root2`
    expect(str.include?("1 of 3 builds failed")).to be == true
  end  

  it 'collection parse params' do
    str = `ruby bin/bakery -m spec/testdata/root1/main -b gaga -w spec/testdata/root1 -w spec/testdata/root2 -v2 -a black --ignore_cache -r -c`
    expect(str.include?(" -r")).to be == true
    expect(str.include?(" -a black")).to be == true
    expect(str.include?(" -v2")).to be == true
    expect(str.include?(" --ignore_cache")).to be == true
    expect(str.include?(" -r")).to be == true
    expect(str.include?(" -c")).to be == true
  end
  
  it 'collection wrong' do
    str = `ruby bin/bakery -m spec/testdata/root1/main -b wrong -w spec/testdata/root1 -w spec/testdata/root2 -r`
    expect(str.include?("bakery aborted")).to be == true
    expect(str.include?("must contain DefaultToolchain")).to be == true
    str = `ruby bin/bakery -m spec/testdata/root1/main -b wrong -w spec/testdata/root1 -w spec/testdata/root2`
    expect(str.include?("1 of 1 builds failed")).to be == true
  end  

  it 'collection error' do
    str = `ruby bin/bakery -m spec/testdata/root1/main -b error -w spec/testdata/root1 -w spec/testdata/root2 -r`
    expect(str.include?("bakery aborted")).to be == true
    expect(str.include?("Error: system command failed")).to be == false
    str = `ruby bin/bakery -m spec/testdata/root1/main -b error -w spec/testdata/root1 -w spec/testdata/root2`
    expect(str.include?("1 of 1 builds failed")).to be == true
  end

  it 'collection ref' do
    str = `ruby bin/bakery -m spec/testdata/root1/main -b Combined -w spec/testdata/root1 -w spec/testdata/root2 -r`
    expect(str.include?("3 of 3 builds ok")).to be == true
    expect(str.include?("root1/lib1 -b test")).to be == true
    expect(str.include?("root2/lib2 -b test")).to be == true
    expect(str.include?("root1/main -b test")).to be == true
  end    

  it 'collection only ref to itself' do
    str = `ruby bin/bakery -m spec/testdata/root1/main -b Nothing -w spec/testdata/root1 -w spec/testdata/root2 -r`
    expect(str.include?("0 of 0 builds ok")).to be == true
  end    
  
  it 'collection invalid ref' do
    str = `ruby bin/bakery -m spec/testdata/root1/main -b InvalidRef -w spec/testdata/root1 -w spec/testdata/root2 -r`
    expect(str.include?("Collection Wrong not found")).to be == true
  end    

end

end
