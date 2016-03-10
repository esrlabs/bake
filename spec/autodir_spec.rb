#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'socket'
require 'fileutils'

module Bake

describe "autodir" do
  
  it 'without no_autodir' do
    Bake.startBake("noAutodir/main", ["-b", "test", "--rebuild"])
    expect($mystring.split("Rebuilding failed.").length).to be == 2
  end

  it 'with no_autodir' do
    Bake.startBake("noAutodir/main", ["-b", "test", "--no-autodir", "--rebuild"])
    expect($mystring.split("Rebuilding done.").length).to be == 2
  end
  
end

end
