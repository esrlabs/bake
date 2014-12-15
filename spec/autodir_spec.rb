#!/usr/bin/env ruby

require 'common/version'

require 'tocxx'
require 'bake/options/options'
require 'imported/utils/exit_helper'
require 'socket'
require 'fileutils'
require 'helper'

module Bake

describe "autodir" do
  
  it 'without no_autodir' do
    Bake.startBake("noAutodir/main", ["-b", "test", "--rebuild"])
    expect($mystring.split("Rebuilding failed.").length).to be == 2
  end

  it 'with no_autodir' do
    Bake.startBake("noAutodir/main", ["-b", "test", "--no_autodir", "--rebuild"])
    expect($mystring.split("Rebuilding done.").length).to be == 2
  end
  
end

end
