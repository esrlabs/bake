#!/usr/bin/env ruby

require 'helper'

require 'socket'
require 'fileutils'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'

module Bake

describe "abort" do

  it 'no hallo' do
    Bake.startBake("abort/main", ["test", "--rebuild"])
    expect($mystring.include?("hallo")).to be == false
  end

end


end
