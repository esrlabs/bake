#!/usr/bin/env ruby

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'
require 'helper'

module Bake

describe "Post" do
  
  it 'do not execute on error' do
    Bake.startBake("post/main", [])

    expect($mystring.include?("DO_PRINT")).to be == true
    expect($mystring.include?("DO_NOT_PRINT")).to be == false
  end

end

end
