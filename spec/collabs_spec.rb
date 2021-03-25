#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'bake/util'
require 'common/exit_helper'
require 'socket'
require 'fileutils'

module Bake

describe "Collection enhancements" do
  collFile = "spec/testdata/collabs/verifier/Collection.meta"

  before(:each) do
    FileUtils.cp_r("#{collFile}.template", collFile)
    File.write(collFile, File.read(collFile).gsub("ABS", Dir.pwd))
  end

  after(:all) do
    FileUtils.rm_rf("#{collFile}")
  end

  it 'cleanpath (no multiple find)' do
    str = `ruby bin/bakery -m spec/testdata/collabs/verifier -w spec/testdata/collabs/modules -w spec/testdata/collabs/safety --adapt ut -w spec/testdata/collabs/adapt -a black test1`
    puts str
    expect(str.include?("bakery summary: 2 of 2 builds ok")).to be == true
    expect(str.include?("lib2_test1")).to be == true
    expect(str.include?("lib3_test2")).to be == true
    expect(str.include?("bake -m spec/testdata/collabs/modules/lib2")).to be == true
    expect(str.include?("bake -m spec/testdata/collabs/safety/lib3")).to be == true
  end

  it 'absolute path' do
    str = `ruby bin/bakery -m spec/testdata/collabs/verifier -w spec/testdata/collabs/modules -w spec/testdata/collabs/safety --adapt ut -w spec/testdata/collabs/adapt -a black test2`
    puts str
    expect(str.include?("bakery summary: 1 of 1 builds ok")).to be == true
    expect(str.include?("lib1_test1")).to be == true
    expect(str.include?("bake -m spec/testdata/collabs/modules/lib1")).to be == true
  end
  
end

end
