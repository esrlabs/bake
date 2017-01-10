#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'

module Bake

  def self.testGlobalFileList(x, main=true, sub=true)
    x.expect(ExitHelper.exit_code).to x.be == 0 if sub&&!main
    content = File.read("spec/testdata/fileList/main/build/test_main/global-file-list.txt")
    x.expect(content.include?("fileList/main/src/sub/sub1.cpp")).to x.be == (sub == true)
    x.expect(content.include?("fileList/main/src/sub/sub2.cpp")).to x.be == (sub == true)
    x.expect(content.include?("fileList/main/include/sub/sub1.h")).to x.be == true
    x.expect(content.include?("fileList/main/include/sub/sub2.h")).to x.be == (sub == true)
    x.expect(content.include?("fileList/main/src/main/main1.cpp")).to x.be == (main == true)
    x.expect(content.include?("fileList/main/src/main/main2.cpp")).to x.be == (main == true)
    x.expect(content.include?("fileList/main/include/main/main1.h")).to x.be == (main == true)
    x.expect(content.include?("fileList/main/include/main/main2.h")).to x.be == (main == true)
    x.expect(content.split("fileList").length).to x.be == (main&&sub ? 9 : (main ? 6 : 5))
  end

  def self.testMainFileList(x, success = true)
    x.expect(ExitHelper.exit_code).to x.be == 0 if success
    content = File.read("spec/testdata/fileList/main/build/test_main/file-list.txt")
    x.expect(content.include?("fileList/main/src/sub/sub1.cpp")).to x.be == false
    x.expect(content.include?("fileList/main/src/sub/sub2.cpp")).to x.be == false
    x.expect(content.include?("fileList/main/include/sub/sub1.h")).to x.be == true
    x.expect(content.include?("fileList/main/include/sub/sub2.h")).to x.be == false
    x.expect(content.include?("fileList/main/src/main/main1.cpp")).to x.be == true
    x.expect(content.include?("fileList/main/src/main/main2.cpp")).to x.be == true
    x.expect(content.include?("fileList/main/include/main/main1.h")).to x.be == true
    x.expect(content.include?("fileList/main/include/main/main2.h")).to x.be == true
    x.expect(content.split("fileList").length).to x.be == 6
  end

  def self.testSubFileList(x)
    x.expect(ExitHelper.exit_code).to x.be == 0
    content = File.read("spec/testdata/fileList/main/build/test_sub_main_test_main/file-list.txt")
    x.expect(content.include?("fileList/main/src/sub/sub1.cpp")).to x.be == true
    x.expect(content.include?("fileList/main/src/sub/sub2.cpp")).to x.be == true
    x.expect(content.include?("fileList/main/include/sub/sub1.h")).to x.be == true
    x.expect(content.include?("fileList/main/include/sub/sub2.h")).to x.be == true
    x.expect(content.include?("fileList/main/src/main/main1.cpp")).to x.be == false
    x.expect(content.include?("fileList/main/src/main/main2.cpp")).to x.be == false
    x.expect(content.include?("fileList/main/include/main/main1.h")).to x.be == false
    x.expect(content.include?("fileList/main/include/main/main2.h")).to x.be == false
    x.expect(content.split("fileList").length).to x.be == 5
  end


describe "FileList" do

  it 'compile all' do
    Bake.startBake("fileList/main",  ["test_main", "--file-list"])
    Bake.testGlobalFileList(self)
    Bake.testMainFileList(self)
    Bake.testSubFileList(self)
  end

  it 'compile sub' do
    Bake.startBake("fileList/main",  ["test_main", "--file-list", "-p",  "main,test_sub"])
    expect(ExitHelper.exit_code).to be == 0
    Bake.testGlobalFileList(self, false, true)
    expect(File.exist?("spec/testdata/fileList/main/build/test_main/file-list.txt")).to be == false
    Bake.testSubFileList(self)
  end

  it 'compile main' do
    Bake.startBake("fileList/main",  ["test_main", "--file-list", "-p",  "main,test_main"])
    expect(ExitHelper.exit_code).to be > 0 # does not link
    Bake.testGlobalFileList(self, true, false)
    Bake.testMainFileList(self, false)
    expect(File.exist?("spec/testdata/fileList/main/build/test_sub_main_test_main/file-list.txt")).to be == false
  end

  it 'asm' do
    Bake.startBake("fileList/main",  ["test_asm", "--file-list"])
    expect(ExitHelper.exit_code).to be == 0

    content = File.read("spec/testdata/fileList/main/build/test_asm/file-list.txt")
    expect(content.include?("fileList/main/src/main/main.s")).to be == true
    expect(content.split("fileList").length).to be == 2

    content = File.read("spec/testdata/fileList/main/build/test_asm/global-file-list.txt")
    expect(content.include?("fileList/main/src/main/main.s")).to be == true
    expect(content.split("fileList").length).to be == 2
  end

  it 'compile partly then fully' do
    Bake.startBake("fileList/main",  ["test_main", "--file-list", "-p",  "main,test_sub"])
    expect(ExitHelper.exit_code).to be == 0

    Bake.startBake("fileList/main",  ["test_main", "--file-list"])
    Bake.testGlobalFileList(self)
    Bake.testMainFileList(self)
    Bake.testSubFileList(self)
  end

end

end
