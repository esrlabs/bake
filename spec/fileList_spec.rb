#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'

module Bake

describe "FileList" do

  it 'not compiled' do
    Bake.startBake("fileList/main",  ["test_main", "--file-list"])
    expect(ExitHelper.exit_code).to be > 0
    expect($mystring.include?("Error: dependency file doesn't exist")).to be == true
  end

  it 'compiled' do
    Bake.startBake("fileList/main",  ["test_main"])
    expect(ExitHelper.exit_code).to be == 0

    Bake.startBake("fileList/main",  ["test_main", "--file-list"])
    expect(ExitHelper.exit_code).to be == 0
    expect($mystring.include?("Error: dependency file doesn't exist")).to be == false

    expect($mystring.split("FILE:").length).to be == 5
    expect($mystring.split("HEADER:").length).to be == 6

    pos01 = $mystring.index("fileList/main/src/sub/sub1.cpp")
    pos02 = $mystring.index("fileList/main/src/sub/sub2.cpp")
    pos03 = $mystring.index("fileList/main/include/sub/sub1.h")
    pos04 = $mystring.index("fileList/main/include/sub/sub2.h")
    pos05 = $mystring.index("fileList/main/src/main/main1.cpp")
    pos06 = $mystring.index("fileList/main/src/main/main2.cpp")
    pos07 = $mystring.index("fileList/main/include/main/main1.h")
    pos08 = $mystring.index("fileList/main/include/main/main2.h")
    pos09 = $mystring.index("fileList/main/include/sub/sub1.h", pos05)

    expect(pos01).to be > 0
    expect(pos02).to be > 0
    expect(pos03).to be > 0
    expect(pos04).to be > 0
    expect(pos05).to be > 0
    expect(pos06).to be > 0
    expect(pos07).to be > 0
    expect(pos08).to be > 0
    expect(pos09).to be > 0

    expect((pos01 < pos02)).to be == true
    expect((pos02 < pos03)).to be == true
    expect((pos03 < pos04)).to be == true
    expect((pos04 < pos05)).to be == true
    expect((pos05 < pos06)).to be == true
    expect((pos06 < pos07)).to be == true
    expect((pos07 < pos08)).to be == true
    expect((pos08 < pos09)).to be == true

  end

  it 'asm' do
    Bake.startBake("fileList/main",  ["test_asm", "--file-list"])
    expect(ExitHelper.exit_code).to be == 0
    expect($mystring.split("FILE:").length).to be == 2
    expect($mystring.split("HEADER:").length).to be == 1
    expect($mystring.include?("fileList/main/src/main/main.s")).to be == true
  end

end

end
