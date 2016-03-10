#!/usr/bin/env ruby

require 'simplecov'
require 'coveralls'
SimpleCov.start do
  add_filter 'spec'
end
Coveralls.wear_merged!

require 'helper'

require 'socket'
require 'fileutils'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'

module Bake

describe "autodir" do
  
  it 'without no_autodir' do
    Bake.startBake("abort/main", ["test", "--rebuild"])
    expect($mystring.include?("hallo")).to be == false
  end

end


end
