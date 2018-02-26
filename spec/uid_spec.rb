#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'

module Bake

describe "Uid" do

  it 'default' do
    Bake.startBake("simple/main", ["test_ok_uid"])
    expect($mystring.include?"Uid_lib: ACCA365A").to be == true
    expect($mystring.include?"Uid_main: 0402848C").to be == true
    expect($mystring.include?"Uid_lib: OWN_ID").to be == false
    expect($mystring.include?"Uid_main: OWN_ID").to be == false
  end

  it 'own' do
    Bake.startBake("simple/main", ["test_ok_own_uid"])

    expect($mystring.include?"Uid_lib: ACCA365A").to be == false
    expect($mystring.include?"Uid_main: 0402848C").to be == false
    expect($mystring.include?"Uid_lib: OWN_ID").to be == true
    expect($mystring.include?"Uid_main: OWN_ID").to be == true
  end

  it 'CRC32' do
    Bake.startBake("simple/main", ["--crc32", "../main,test_ok_uid"])

    expect($mystring.include?"ACCA365A").to be == true
  end

end

end
