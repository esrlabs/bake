#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'

module Bake

describe "GCC MapFile" do

  it 'build with MapFile' do
    Bake.startBake("map/main", [])

    expect($mystring.include?("Building done.")).to be == true#
    expect(ExitHelper.exit_code).to be == 0

    expect(File.exist?("spec/testdata/map/main/build/test/out.exe")).to be == true
    expect(File.exist?("spec/testdata/map/main/build/test/out.exe.cmdline")).to be == true
    expect(File.exist?("spec/testdata/map/main/build/test/out.map")).to be == true

    size = File.size?("spec/testdata/map/main/build/test/out.map")

    expect(size != nil && size > 0).to be true

  end

end

end
