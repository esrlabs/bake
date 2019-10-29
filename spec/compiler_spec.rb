#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'

module Bake

$dccInstalled = false

describe "compiler" do

  before(:all) do
    $noCleanTestData = true
  end

  after(:all) do
    $noCleanTestData = false
  end

  it 'dcc installed' do
    begin
      `dcc`
      $dccInstalled = true
    rescue Exception
      if not Bake.ciRunning?
        fail "dcc not installed" # fail only once on non dcc systems
      end
    end
  end

  it 'dcc rebuild' do
    if $dccInstalled
      Bake.startBake("compiler/dcc", ["test", "--rebuild"])
      expect($mystring.include?("lib.cpp")).to be == true
      expect($mystring.include?("main.cpp")).to be == true
      expect($mystring.include?("libdcc.a")).to be == true
      expect($mystring.include?("dcc.elf")).to be == true
      expect(ExitHelper.exit_code).to be == 0
    end
  end

  it 'dcc link-only' do
    Bake.startBake("compiler/dcc", ["test", "--link-only"])
    expect($mystring.include?("dcc.elf")).to be == true
  end

  it 'dcc build' do
    if $dccInstalled
      Bake.startBake("compiler/dcc", ["test"])
      expect($mystring.include?("lib.cpp")).to be == false
      expect($mystring.include?("main.cpp")).to be == false
      expect($mystring.include?("libdcc.a")).to be == false
      expect($mystring.include?("dcc.elf")).to be == false
      expect(ExitHelper.exit_code).to be == 0
    end
  end

  it 'dcc touch' do
    if $dccInstalled
      sleep 1.1
      FileUtils.touch("spec/testdata/compiler/dcc/include/inc1.h")

      Bake.startBake("compiler/dcc", ["test"])
      expect($mystring.include?("lib.cpp")).to be == false
      expect($mystring.include?("main.cpp")).to be == true
      expect($mystring.include?("libdcc.a")).to be == false
      expect($mystring.include?("dcc.elf")).to be == true
      expect(ExitHelper.exit_code).to be == 0
    end
  end

  it 'dcc move' do
    if $dccInstalled
      path = "spec/testdata/compiler/dcc/include/"
      FileUtils.cp(path + "inc1.h", path + "inc1.h.bak")
      FileUtils.rm_f(path + "inc1.h");

      Bake.startBake("compiler/dcc", ["test"])
      expect($mystring.include?("lib.cpp")).to be == false
      expect($mystring.include?("main.cpp")).to be == true
      expect($mystring.include?("libdcc.a")).to be == false
      expect($mystring.include?("dcc.elf")).to be == false
      expect(ExitHelper.exit_code).to be > 0

      FileUtils.mv(path + "inc1.h.bak", path + "inc1.h")
    end
  end

  it 'dcc dep' do
    if $dccInstalled
      `dcc`
      depStr = File.read("spec/testdata/compiler/dcc/build/test/src/main.d.bake")
      expect(depStr.include?("inc1.h")).to be == true
      expect(depStr.include?("inc 2.h")).to be == true
    end
  end

  it 'file-cmd with dcc' do
    if $dccInstalled
      Bake.startBake("compiler/dcc", ["test", "-v2", "--file-cmd"])

      expect($mystring.include?("dcc @build/test/src/main.o.file")).to be == true
      expect($mystring.include?("dar @build/testLib_dcc_test/libdcc.a.file")).to be == true
      expect($mystring.include?("dcc @build/test/dcc.elf.file")).to be == true

      expect(File.exist?("spec/testdata/compiler/dcc/build/test/src/main.o.file")).to be == true
      expect(File.exist?("spec/testdata/compiler/dcc/build/testLib_dcc_test/libdcc.a.file")).to be == true
      expect(File.exist?("spec/testdata/compiler/dcc/build/test/dcc.elf.file")).to be == true

      expect(ExitHelper.exit_code).to be == 0
    end
  end

  it 'dcc deps - regular' do
    path = "spec/testdata/compiler/dcc"
    incList = Blocks::Compile.read_depfile("#{path}/dep.d", "DIR", false)
    Blocks::Compile.write_depfile("src", incList, "#{path}/test.d.bake", "DIR")
    FileUtils.identical?("#{path}/test.d.bake","#{path}/dep.ref")
  end

  it 'dcc deps - oneline' do
    path = "spec/testdata/compiler/dcc"
    incList = Blocks::Compile.read_depfile("#{path}/dep_oneline.d", "DIR", false)
    Blocks::Compile.write_depfile("src", incList, "#{path}/test.d.bake", "DIR")
    FileUtils.identical?("#{path}/test.d.bake","#{path}/dep_oneline.ref")
  end

  it 'dcc deps - noline' do
    path = "spec/testdata/compiler/dcc"
    incList = Blocks::Compile.read_depfile("#{path}/dep_noline.d", "DIR", false)
    Blocks::Compile.write_depfile("src", incList, "#{path}/test.d.bake", "DIR")
    FileUtils.identical?("#{path}/test.d.bake","#{path}/dep_noline.ref")
  end

  it 'keil deps - regular' do
    path = "spec/testdata/compiler/keil"
    incList = Blocks::Compile.read_depfile("#{path}/dep.d", "DIR", true)
    Blocks::Compile.write_depfile("src", incList, "#{path}/test.d.bake", "DIR")
    FileUtils.identical?("#{path}/test.d.bake","#{path}/dep.ref")
  end

  it 'keil deps - oneline' do
    path = "spec/testdata/compiler/keil"
    incList = Blocks::Compile.read_depfile("#{path}/dep_oneline.d", "DIR", true)
    Blocks::Compile.write_depfile("src", incList, "#{path}/test.d.bake", "DIR")
    FileUtils.identical?("#{path}/test.d.bake","#{path}/dep_oneline.ref")
  end

  it 'keil deps - noline' do
    path = "spec/testdata/compiler/keil"
    incList = Blocks::Compile.read_depfile("#{path}/dep_noline.d", "DIR", true)
    Blocks::Compile.write_depfile("src", incList, "#{path}/test.d.bake", "DIR")
    FileUtils.identical?("#{path}/test.d.bake","#{path}/dep_noline.ref")
  end

  it 'keil libs - list mode' do
    Bake.startBake("compiler/keil", ["test", "-p", "keil,test"])

    expect($mystring.include?("libkeil.a a.lib b.lib c.lib lib3/d.lib")).to be == true
    expect($mystring.include?("--userlibpath=lib1,lib2")).to be == true
    expect(ExitHelper.exit_code).to be > 0
  end

  it 'msvc include parsing' do
    ep = MSVCCompilerErrorParser.new

    x = [
    "Note: including file: C:\\ESRLabs\\x.h\n"+
    "Note: including file:  C:\\ESRLabs/y.h\n"+
    "C:\\ESRLabs\\repos\\tmp\\gmock\\fused-src\\gtest/gtest.h(9478) : warning C4661: 'esrlabs::estd::array<T>::array(void)' : no suitable definition provided for explicit template instantiation request\n"+
    "        with\n"+
    "        [\n"+
    "            T=int\n"+
    "        ]\n"+
    "        C:\\ESRLabs\\repos\\tmp\\estl\\include\\estd/array.h(276) : see declaration of 'esrlabs::estd::array<T>::array'\n"+
    "        with\n"+
    "        [\n"+
    "            T=int\n"+
    "        ]"]

    res, fullnames, includeList = ep.scan_lines(x,nil)
  end

  it 'tasking compiler parsing' do
    tp = TaskingCompilerErrorParser.new

    x = ["bla bla\n"+
      "Tasking ptc F1719: cannot open preprocessing output file “build/Lib_core_1_Ccp22_A0/src/ethernet/MACAddress.d”\n"+
      "hey WXXX: [\"here.cpp\" 123] so funny"]

    res, fullnames, includeList = tp.scan_lines(x,nil)

    expect(res[0].severity).to be == 255

    expect(res[1].severity).to be == 2
    expect(res[1].file_name.end_with?("build/Lib_core_1_Ccp22_A0/src/ethernet/MACAddress.d")).to be == true
    expect(res[1].line_number).to be == 0
    expect(res[1].message).to be == "cannot open preprocessing output file"

    expect(res[2].severity).to be == 1
    expect(res[1].file_name.end_with?("here.cpp")).to be == true
    expect(res[2].line_number).to be == 123
    expect(res[2].message).to be == "so funny"

  end

end

end

