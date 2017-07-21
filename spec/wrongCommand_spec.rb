#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'socket'
require 'fileutils'

module Bake

describe "WrongCommand" do

  it 'wrong' do
    Bake.startBake("wrongCommand/main", ["test"])
    expect(($mystring.include?"GAGA -c")).to be == true
    expect(($mystring.include?"Building failed")).to be == true
  end

  it 'space' do
    Bake.startBake("wrongCommand/main", ["testSpace1"])
    expect(($mystring.include?"Building done")).to be == true
    Bake.startBake("wrongCommand/main", ["testSpace2a"])
    expect(($mystring.include?"TEST COMMAND")).to be == false
    expect(($mystring.include?"Building failed")).to be == true
  end

  it 'space quote' do
    Bake.startBake("wrongCommand/main", ["testSpace1"])
    expect(($mystring.include?"Building done")).to be == true
    Bake.startBake("wrongCommand/main", ["testSpace2b"])
    expect(($mystring.include?"TEST COMMAND")).to be == true
    expect(($mystring.include?"Building failed")).to be == false
  end

  it 'space double quote' do
    Bake.startBake("wrongCommand/main", ["testSpace1"])
    expect(($mystring.include?"Building done")).to be == true
    Bake.startBake("wrongCommand/main", ["testSpace2c"])
    expect(($mystring.include?"TEST COMMAND")).to be == true
    expect(($mystring.include?"Building failed")).to be == false
  end

end

end