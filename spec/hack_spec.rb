#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'

module Bake

describe "Hacks" do

  it 'deppath' do
    Bake.startBake("hacks/main", ["testDepHeader"])
    expect($mystring.split("Compiling").length).to be == 2
    expect(ExitHelper.exit_code).to be == 0

    Bake.startBake("hacks/main", ["testDepHeader"])
    expect($mystring.split("Compiling").length).to be == 2
    expect(ExitHelper.exit_code).to be == 0
  end

end

end
