#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'

module Bake

describe "FileList" do

  it 'compile all' do
    Bake.startBake("fileList/main",  ["test_main", "--file-list=txt"])
    expect(ExitHelper.exit_code).to be == 0

    content = File.read("spec/testdata/fileList/main/build/test_main/global-file-list.txt")
    expect(content.include?("fileList/main/src/sub/sub1.cpp")).to be == true
    expect(content.include?("fileList/main/src/sub/sub2.cpp")).to be == true
    expect(content.include?("fileList/main/include/sub/sub1.h")).to be == true
    expect(content.include?("fileList/main/include/sub/sub2.h")).to be == true
    expect(content.include?("fileList/main/src/main/main1.cpp")).to be == true
    expect(content.include?("fileList/main/src/main/main2.cpp")).to be == true
    expect(content.include?("fileList/main/include/main/main1.h")).to be == true
    expect(content.include?("fileList/main/include/main/main2.h")).to be == true
    expect(content.split("fileList").length).to be == 9

    content = File.read("spec/testdata/fileList/main/build/test_main/file-list.txt")
    expect(content.include?("fileList/main/src/sub/sub1.cpp")).to be == false
    expect(content.include?("fileList/main/src/sub/sub2.cpp")).to be == false
    expect(content.include?("fileList/main/include/sub/sub1.h")).to be == true
    expect(content.include?("fileList/main/include/sub/sub2.h")).to be == false
    expect(content.include?("fileList/main/src/main/main1.cpp")).to be == true
    expect(content.include?("fileList/main/src/main/main2.cpp")).to be == true
    expect(content.include?("fileList/main/include/main/main1.h")).to be == true
    expect(content.include?("fileList/main/include/main/main2.h")).to be == true
    expect(content.split("fileList").length).to be == 6

    content = File.read("spec/testdata/fileList/main/build/test_sub_main_test_main/file-list.txt")
    expect(content.include?("fileList/main/src/sub/sub1.cpp")).to be == true
    expect(content.include?("fileList/main/src/sub/sub2.cpp")).to be == true
    expect(content.include?("fileList/main/include/sub/sub1.h")).to be == true
    expect(content.include?("fileList/main/include/sub/sub2.h")).to be == true
    expect(content.include?("fileList/main/src/main/main1.cpp")).to be == false
    expect(content.include?("fileList/main/src/main/main2.cpp")).to be == false
    expect(content.include?("fileList/main/include/main/main1.h")).to be == false
    expect(content.include?("fileList/main/include/main/main2.h")).to be == false
    expect(content.split("fileList").length).to be == 5
  end

  it 'compile sub' do
    Bake.startBake("fileList/main",  ["test_main", "--file-list=txt", "-p",  "main,test_sub"])
    expect(ExitHelper.exit_code).to be == 0

    content = File.read("spec/testdata/fileList/main/build/test_main/global-file-list.txt")
    expect(content.include?("fileList/main/src/sub/sub1.cpp")).to be == true
    expect(content.include?("fileList/main/src/sub/sub2.cpp")).to be == true
    expect(content.include?("fileList/main/include/sub/sub1.h")).to be == true
    expect(content.include?("fileList/main/include/sub/sub2.h")).to be == true
    expect(content.include?("fileList/main/src/main/main1.cpp")).to be == false
    expect(content.include?("fileList/main/src/main/main2.cpp")).to be == false
    expect(content.include?("fileList/main/include/main/main1.h")).to be == false
    expect(content.include?("fileList/main/include/main/main2.h")).to be == false
    expect(content.split("fileList").length).to be == 5

    expect(File.exist?("spec/testdata/fileList/main/build/test_main/file-list.txt")).to be == false

    content = File.read("spec/testdata/fileList/main/build/test_sub_main_test_main/file-list.txt")
    expect(content.include?("fileList/main/src/sub/sub1.cpp")).to be == true
    expect(content.include?("fileList/main/src/sub/sub2.cpp")).to be == true
    expect(content.include?("fileList/main/include/sub/sub1.h")).to be == true
    expect(content.include?("fileList/main/include/sub/sub2.h")).to be == true
    expect(content.include?("fileList/main/src/main/main1.cpp")).to be == false
    expect(content.include?("fileList/main/src/main/main2.cpp")).to be == false
    expect(content.include?("fileList/main/include/main/main1.h")).to be == false
    expect(content.include?("fileList/main/include/main/main2.h")).to be == false
    expect(content.split("fileList").length).to be == 5
  end

  it 'compile main' do
    Bake.startBake("fileList/main",  ["test_main", "--file-list=txt", "-p",  "main,test_main"])
    expect(ExitHelper.exit_code).to be > 0 # does not link

    content = File.read("spec/testdata/fileList/main/build/test_main/global-file-list.txt")
    expect(content.include?("fileList/main/src/sub/sub1.cpp")).to be == false
    expect(content.include?("fileList/main/src/sub/sub2.cpp")).to be == false
    expect(content.include?("fileList/main/include/sub/sub1.h")).to be == true
    expect(content.include?("fileList/main/include/sub/sub2.h")).to be == false
    expect(content.include?("fileList/main/src/main/main1.cpp")).to be == true
    expect(content.include?("fileList/main/src/main/main2.cpp")).to be == true
    expect(content.include?("fileList/main/include/main/main1.h")).to be == true
    expect(content.include?("fileList/main/include/main/main2.h")).to be == true
    expect(content.split("fileList").length).to be == 6

    content = File.read("spec/testdata/fileList/main/build/test_main/file-list.txt")
    expect(content.include?("fileList/main/src/sub/sub1.cpp")).to be == false
    expect(content.include?("fileList/main/src/sub/sub2.cpp")).to be == false
    expect(content.include?("fileList/main/include/sub/sub1.h")).to be == true
    expect(content.include?("fileList/main/include/sub/sub2.h")).to be == false
    expect(content.include?("fileList/main/src/main/main1.cpp")).to be == true
    expect(content.include?("fileList/main/src/main/main2.cpp")).to be == true
    expect(content.include?("fileList/main/include/main/main1.h")).to be == true
    expect(content.include?("fileList/main/include/main/main2.h")).to be == true
    expect(content.split("fileList").length).to be == 6

    expect(File.exist?("spec/testdata/fileList/main/build/test_sub_main_test_main/file-list.txt")).to be == false
  end

  it 'asm' do
    Bake.startBake("fileList/main",  ["test_asm", "--file-list=txt"])
    expect(ExitHelper.exit_code).to be == 0

    content = File.read("spec/testdata/fileList/main/build/test_asm/global-file-list.txt")
    expect(content.include?("fileList/main/src/main/main.s")).to be == true
    expect(content.split("fileList").length).to be == 2

    content = File.read("spec/testdata/fileList/main/build/test_asm/global-file-list.txt")
    expect(content.include?("fileList/main/src/main/main.s")).to be == true
    expect(content.split("fileList").length).to be == 2
  end

  it 'compile partly then fully' do
    Bake.startBake("fileList/main",  ["test_main", "--file-list=txt", "-p",  "main,test_sub"])
    expect(ExitHelper.exit_code).to be == 0

    Bake.startBake("fileList/main",  ["test_main", "--file-list=txt"])
    content = File.read("spec/testdata/fileList/main/build/test_main/global-file-list.txt")
    expect(content.include?("fileList/main/src/sub/sub1.cpp")).to be == true
    expect(content.include?("fileList/main/src/sub/sub2.cpp")).to be == true
    expect(content.include?("fileList/main/include/sub/sub1.h")).to be == true
    expect(content.include?("fileList/main/include/sub/sub2.h")).to be == true
    expect(content.include?("fileList/main/src/main/main1.cpp")).to be == true
    expect(content.include?("fileList/main/src/main/main2.cpp")).to be == true
    expect(content.include?("fileList/main/include/main/main1.h")).to be == true
    expect(content.include?("fileList/main/include/main/main2.h")).to be == true
    expect(content.split("fileList").length).to be == 9

    content = File.read("spec/testdata/fileList/main/build/test_main/file-list.txt")
    expect(content.include?("fileList/main/src/sub/sub1.cpp")).to be == false
    expect(content.include?("fileList/main/src/sub/sub2.cpp")).to be == false
    expect(content.include?("fileList/main/include/sub/sub1.h")).to be == true
    expect(content.include?("fileList/main/include/sub/sub2.h")).to be == false
    expect(content.include?("fileList/main/src/main/main1.cpp")).to be == true
    expect(content.include?("fileList/main/src/main/main2.cpp")).to be == true
    expect(content.include?("fileList/main/include/main/main1.h")).to be == true
    expect(content.include?("fileList/main/include/main/main2.h")).to be == true
    expect(content.split("fileList").length).to be == 6

    content = File.read("spec/testdata/fileList/main/build/test_sub_main_test_main/file-list.txt")
    expect(content.include?("fileList/main/src/sub/sub1.cpp")).to be == true
    expect(content.include?("fileList/main/src/sub/sub2.cpp")).to be == true
    expect(content.include?("fileList/main/include/sub/sub1.h")).to be == true
    expect(content.include?("fileList/main/include/sub/sub2.h")).to be == true
    expect(content.include?("fileList/main/src/main/main1.cpp")).to be == false
    expect(content.include?("fileList/main/src/main/main2.cpp")).to be == false
    expect(content.include?("fileList/main/include/main/main1.h")).to be == false
    expect(content.include?("fileList/main/include/main/main2.h")).to be == false
    expect(content.split("fileList").length).to be == 5
  end

  it 'json' do
    Bake.startBake("fileList/main",  ["test_main", "--file-list=json"])
    expect(ExitHelper.exit_code).to be == 0

    content = File.read("spec/testdata/fileList/main/build/test_main/global-file-list.json")
    expect(content.include?("fileList/main/src/sub/sub1.cpp")).to be == true
    expect(content.include?("fileList/main/src/sub/sub2.cpp")).to be == true
    expect(content.include?("fileList/main/include/sub/sub1.h")).to be == true
    expect(content.include?("fileList/main/include/sub/sub2.h")).to be == true
    expect(content.include?("fileList/main/src/main/main1.cpp")).to be == true
    expect(content.include?("fileList/main/src/main/main2.cpp")).to be == true
    expect(content.include?("fileList/main/include/main/main1.h")).to be == true
    expect(content.include?("fileList/main/include/main/main2.h")).to be == true
    expect(content.split("fileList").length).to be == 9

    content = File.read("spec/testdata/fileList/main/build/test_main/file-list.json")
    expect(content.include?("fileList/main/src/sub/sub1.cpp")).to be == false
    expect(content.include?("fileList/main/src/sub/sub2.cpp")).to be == false
    expect(content.include?("fileList/main/include/sub/sub1.h")).to be == true
    expect(content.include?("fileList/main/include/sub/sub2.h")).to be == false
    expect(content.include?("fileList/main/src/main/main1.cpp")).to be == true
    expect(content.include?("fileList/main/src/main/main2.cpp")).to be == true
    expect(content.include?("fileList/main/include/main/main1.h")).to be == true
    expect(content.include?("fileList/main/include/main/main2.h")).to be == true
    expect(content.split("fileList").length).to be == 6

    content = File.read("spec/testdata/fileList/main/build/test_sub_main_test_main/file-list.json")
    expect(content.include?("fileList/main/src/sub/sub1.cpp")).to be == true
    expect(content.include?("fileList/main/src/sub/sub2.cpp")).to be == true
    expect(content.include?("fileList/main/include/sub/sub1.h")).to be == true
    expect(content.include?("fileList/main/include/sub/sub2.h")).to be == true
    expect(content.include?("fileList/main/src/main/main1.cpp")).to be == false
    expect(content.include?("fileList/main/src/main/main2.cpp")).to be == false
    expect(content.include?("fileList/main/include/main/main1.h")).to be == false
    expect(content.include?("fileList/main/include/main/main2.h")).to be == false
    expect(content.split("fileList").length).to be == 5

    expect(content.include?("files")).to be == true

  end

end

end
