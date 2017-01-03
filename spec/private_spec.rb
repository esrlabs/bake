#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'bake/util'
require 'common/exit_helper'
require 'socket'
require 'fileutils'

module Bake

describe "Private" do

  it 'within project' do
    Bake.startBake("private/main", ["test_ok"])
    expect(ExitHelper.exit_code).to be == 0
    expect($mystring.include?("which is private")).to be == false
  end

  it 'outside project' do
    Bake.startBake("private/main", ["test_nok"])
    expect(ExitHelper.exit_code).to be > 0
    expect($mystring.include?("Project.meta:7: Error: main (test_nok) depends on lib (test_private) which is private.")).to be == true
  end

end

end
