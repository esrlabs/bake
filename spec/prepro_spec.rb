#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'

module Bake

describe "Prepro" do

  it 'build' do
    Bake.startBake("prepro/main", ["test", "--prepro"])

    expect(File.exists?("spec/testdata/prepro/main/build/test/src/main.i")).to be == true
    expect(File.exists?("spec/testdata/prepro/main/build/test/src/assembler.i")).to be == false

    expect(ExitHelper.exit_code).to be == 0
  end

end

end
