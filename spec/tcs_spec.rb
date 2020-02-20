#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'bake/util'
require 'common/exit_helper'
require 'socket'
require 'fileutils'

module Bake

describe "tcs" do

  it 'files without tcs must not be overwritten by pattern with tcs' do
    Bake.startBake("tcs/main", ["test", "-v2", "--dry"])
    expect(ExitHelper.exit_code).to be == 0
    expect($mystring.include?("a.d -DX -o")).to be == true
    expect($mystring.include?("b.d -o")).to be == true
    expect($mystring.include?("c.d -DY -o")).to be == true
    expect($mystring.include?("d.d -DY -o")).to be == true
  end

end

end
