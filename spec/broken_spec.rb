#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'

module Bake

describe "Broken IncludeDir" do

  it 'no name' do
    Bake.startBake("broken/main", ["test_1"])
    expect(ExitHelper.exit_code).to be > 0
    expect($mystring.include?("Error: IncludeDir must not be empty or start with a space")).to be == true
  end

  it 'empty' do
    Bake.startBake("broken/main", ["test_2"])
    expect(ExitHelper.exit_code).to be > 0
    expect($mystring.include?("Error: IncludeDir must not be empty or start with a space")).to be == true
  end

  it 'space' do
    Bake.startBake("broken/main", ["test_3"])
    expect(ExitHelper.exit_code).to be > 0
    expect($mystring.include?("Error: IncludeDir must not be empty or start with a space")).to be == true
  end

  it 'space plus text' do
    Bake.startBake("broken/main", ["test_4"])
    expect(ExitHelper.exit_code).to be > 0
    expect($mystring.include?("Error: IncludeDir must not be empty or start with a space")).to be == true
  end

end

end
