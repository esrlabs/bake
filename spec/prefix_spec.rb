#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'

module Bake

describe "Prefix" do

  it 'build' do
    Bake.startBake("prefix/main", ["test_main", "--dry", "-v2", "--adapt", "prefix"])
    expect($mystring.split("echo CPPPREFIX g++").length).to be == 2
    expect($mystring.split("echo ARCHIVERPREFIX ar").length).to be == 2
    expect($mystring.split("echo LINKERPREFIX g++").length).to be == 2
    expect(ExitHelper.exit_code).to be == 0
  end

end

end
