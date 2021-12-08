#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'socket'
require 'fileutils'

module Bake

describe "VarSubst" do

  it 'mandatory userVar' do
    Bake.startBake("var/main", ["Failure_EmptyUserVar"])
    expect(($mystring.include?"Info: Substitute variable '$(Nothing)' with empty string, because it's not set")).to be == false
    expect(($mystring.include?"Error: Variable '$(Nothing)' cannot be substituted, because it's not set")).to be == true
    expect(ExitHelper.exit_code).to be > 0
  end

  it 'mandatory userVar verbose2' do
    Bake.startBake("var/main", ["Failure_EmptyUserVar", "-v2"])
    expect(($mystring.include?"Info: Substitute variable '$(Nothing)' with empty string, because it's not set")).to be == true
    expect(($mystring.include?"Error: Variable '$(Nothing)' cannot be substituted, because it's not set")).to be == true
    expect(ExitHelper.exit_code).to be > 0
  end

  it 'mandatory projVar1' do
    Bake.startBake("var/main", ["Failure_EmptyProjVar1"])
    expect(($mystring.include?"Info: Substitute variable '$(ProjectDir, foo)' with empty string, because project foo not found")).to be == true
    expect(($mystring.include?"Error: Variable '$(ProjectDir, bla)' cannot be substituted, because project bla not found")).to be == true
    expect(ExitHelper.exit_code).to be > 0
  end

  it 'mandatory projVar2' do
    Bake.startBake("var/main", ["Failure_EmptyProjVar2"])
    expect(($mystring.include?"Info: Substitute variable '$(ProjectDir, foo)' with empty string, because project foo not found")).to be == true
    expect(($mystring.include?"Error: Variable '$(ProjectDir, bla)' cannot be substituted, because project bla not found")).to be == true
    expect(ExitHelper.exit_code).to be > 0
  end

  it 'mandatory projVar2 verbose 0' do
    Bake.startBake("var/main", ["Failure_EmptyProjVar2", "-v0"])
    expect(($mystring.include?"Info: Substitute variable '$(ProjectDir, foo)' with empty string, because project foo not found")).to be == false
    expect(($mystring.include?"Error: Variable '$(ProjectDir, bla)' cannot be substituted, because project bla not found")).to be == true
    expect(ExitHelper.exit_code).to be > 0
  end

  it 'mandatory outVar1' do
    Bake.startBake("var/main", ["Failure_EmptyOutVar1"])
    expect(($mystring.include?"Info: Substitute variable '$(OutputDir, foo)' with empty string, because syntax of complex variable OutputDir is not $(OutputDir,<project name>,<config name>)")).to be == true
    expect(($mystring.include?"Error: Variable '$(OutputDir, bla)' cannot be substituted, because syntax of complex variable OutputDir is not $(OutputDir,<project name>,<config name>)")).to be == true
    expect(ExitHelper.exit_code).to be > 0
  end

  it 'mandatory outVar2' do
    Bake.startBake("var/main", ["Failure_EmptyOutVar2"])
    expect(($mystring.include?"Info: Substitute variable '$(OutputDir, foo)' with empty string, because syntax of complex variable OutputDir is not $(OutputDir,<project name>,<config name>)")).to be == true
    expect(($mystring.include?"Error: Variable '$(OutputDir, bla)' cannot be substituted, because syntax of complex variable OutputDir is not $(OutputDir,<project name>,<config name>)")).to be == true
    expect(ExitHelper.exit_code).to be > 0
  end

  it 'mandatory outVar3' do
    Bake.startBake("var/main", ["Failure_EmptyOutVar3"])
    expect(($mystring.include?"Info: Substitute variable '$(OutputDir, foo, Failure_EmptyOutVar3)' with empty string, because project foo not found")).to be == true
    expect(($mystring.include?"Error: Variable '$(OutputDir, bla, Failure_EmptyOutVar3)' cannot be substituted, because project bla not found")).to be == true
    expect(ExitHelper.exit_code).to be > 0
  end

  it 'mandatory outVar4' do
    Bake.startBake("var/main", ["Failure_EmptyOutVar4"])
    expect(($mystring.include?"Info: Substitute variable '$(OutputDir, foo, Failure_EmptyOutVar4)' with empty string, because project foo not found")).to be == true
    expect(($mystring.include?"Error: Variable '$(OutputDir, bla, Failure_EmptyOutVar4)' cannot be substituted, because project bla not found")).to be == true
    expect(ExitHelper.exit_code).to be > 0
  end

  it 'mandatory outVar5' do
    Bake.startBake("var/main", ["Failure_EmptyOutVar5"])
    expect(($mystring.include?"Info: Substitute variable '$(OutputDir, foo, Failure_EmptyOutVar5)' with empty string, because project foo not found")).to be == true
    expect(($mystring.include?"Error: Variable '$(OutputDir, bla, Failure_EmptyOutVar5)' cannot be substituted, because project bla not found")).to be == true
    expect(ExitHelper.exit_code).to be > 0
  end

  it 'mandatory outVar6' do
    Bake.startBake("var/main", ["Failure_EmptyOutVar6"])
    expect(($mystring.include?"Info: Substitute variable '$(OutputDir, main, foo)' with empty string, because config foo not found for project main")).to be == true
    expect(($mystring.include?"Error: Variable '$(OutputDir, main, bla)' cannot be substituted, because config bla not found for project main")).to be == true
    expect(ExitHelper.exit_code).to be > 0
  end

  it 'mandatory outVar7' do
    Bake.startBake("var/main", ["Failure_EmptyOutVar7"])
    expect(($mystring.include?"Info: Substitute variable '$(OutputDir, main, foo)' with empty string, because config foo not found for project main")).to be == true
    expect(($mystring.include?"Error: Variable '$(OutputDir, main, bla)' cannot be substituted, because config bla not found for project main")).to be == true
    expect(ExitHelper.exit_code).to be > 0
  end

  it 'mandatory outVar8' do
    Bake.startBake("var/main", ["Failure_EmptyOutVar8"])
    expect(($mystring.include?"Info: Substitute variable '$(OutputDir, main, foo)' with empty string, because config foo not found for project main")).to be == true
    expect(($mystring.include?"Error: Variable '$(OutputDir, main, bla)' cannot be substituted, because config bla not found for project main")).to be == true
    expect(ExitHelper.exit_code).to be > 0
  end

  it 'vars should be substed' do
    Bake.startBake("cache/main", ["test", "--do", "var"])

    expect(($mystring.include?"ToolchainName_lib1 GCC")).to be == true
    expect(($mystring.include?"ToolchainName_main GCC")).to be == true

    expect(($mystring.include?"MainConfigName_lib1 test")).to be == true
    expect(($mystring.include?"MainConfigName_main test")).to be == true

    expect(($mystring.include?"MainProjectName_lib1 main")).to be == true
    expect(($mystring.include?"MainProjectName_main main")).to be == true

    expect(($mystring.include?"ProjectName_lib1 lib1")).to be == true
    expect(($mystring.include?"ProjectName_main main")).to be == true

    expect(($mystring.include?"ConfigName_lib1 testsub")).to be == true
    expect(($mystring.include?"ConfigName_main test")).to be == true

    expect(($mystring.include?"OutputDir_lib1 build/testsub_main_test")).to be == true
    expect(($mystring.include?"OutputDir_main build/test")).to be == true

    expect(($mystring.include?"ArtifactName_lib1 this.name\n")).to be == true
    expect(($mystring.include?"ArtifactName_main main"+Bake::Toolchain.outputEnding)).to be == true

    expect(($mystring.include?"ArtifactNameBase_lib1 this\n")).to be == true
    expect(($mystring.include?"ArtifactNameBase_main main")).to be == true

    expect(($mystring.include?"Hostname_lib1 ")).to be == true
    expect(($mystring.include?"Hostname_main ")).to be == true
    expect(($mystring.include?"Hostname_lib1 \n")).to be == false
    expect(($mystring.include?"Hostname_main \n")).to be == false

    expect(($mystring.include?"Path_lib1 ")).to be == true
    expect(($mystring.include?"Path_main ")).to be == true
    expect(($mystring.include?"Path_lib1 \n")).to be == false
    expect(($mystring.include?"Path_main \n")).to be == false

    expect(($mystring.include?"MAINV1main")).to be == true
    expect(($mystring.include?"MAINV2main")).to be == true

    expect(($mystring.include?"LIBV1lib")).to be == true
    expect(($mystring.include?"LIBV2main")).to be == true
    expect(($mystring.include?"LIBV3lib")).to be == true

    expect(($mystring.include?"LIBV1main")).to be == false
    expect(($mystring.include?"LIBV3main")).to be == false

    expect(($mystring.include?"Building done")).to be == true
  end

  it 'artifactname' do
    Bake.startBake("cache/main", ["test2", "--do", "var"])

    expect(($mystring.include?"ArtifactName_main abc.def")).to be == true
    expect(($mystring.include?"ArtifactNameBase_main abc")).to be == true
    expect(($mystring.include?"SLASH#{File::SEPARATOR}SLASH")).to be == true
    expect(($mystring.include?"COLUMN#{File::PATH_SEPARATOR}COLUMN")).to be == true

  end


  it 'paths' do
    Bake.startBake("cache/main", ["testPaths", "-v", "2"])

    if not Utils::OS.windows?
      expect($mystring.scan("/usr/bin").count + $mystring.scan("uby").count).to be >= 5
    else
      expect($mystring.scan("uby").count).to be == 2 # assuming Ruby/ruby is in a ruby dir
      expect($mystring.scan("bin").count).to be >= 3 # assuming that gcc is in a bin dir
    end
  end

  it 'complex outputdir' do
    Bake.startBake("multiProj/main", ["test1"])
    expect(($mystring.include?"Substitute variable '$(OutputDir, testSub2)' with empty string, because syntax of complex variable OutputDir is not $(OutputDir,<project name>,<config name>)")).to be == true

    expect(($mystring.include?"Substitute variable '$(OutputDir, main, fasel)' with empty string, because config fasel not found for project main")).to be == true
    expect(($mystring.include?"Substitute variable '$(OutputDir, bla, fasel)' with empty string, because project bla not found")).to be == true

    expect(($mystring.include?"from testSub1 1: ../main/build/test1")).to be == true
    expect(($mystring.include?"from testSub1 2: ../main/build/testLib1_main_test1")).to be == true
    expect(($mystring.include?"from testSub1 3: build/testSub1_main_test1")).to be == true
    expect(($mystring.include?"from testSub1 4: build/testSub2_main_test1")).to be == true

    expect(($mystring.include?"from testLib1 1: build/test1")).to be == true
    expect(($mystring.include?"from testLib1 2: build/testLib1_main_test1")).to be == true
    expect(($mystring.include?"from testLib1 3: ../lib/build/testSub1_main_test1")).to be == true
    expect(($mystring.include?"from testLib1 4: ../lib/build/testSub2_main_test1")).to be == true

    expect(($mystring.include?"from test1 1: build/test1")).to be == true
    expect(($mystring.include?"from test1 2: build/testLib1_main_test1")).to be == true
    expect(($mystring.include?"from test1 3: ../lib/build/testSub1_main_test1")).to be == true
    expect(($mystring.include?"from test1 4: ../lib/build/testSub2_main_test1")).to be == true

    expect(($mystring.include?"from test1 b1: XX")).to be == true
    expect(($mystring.include?"from test1 b2: XX")).to be == true
    expect(($mystring.include?"from test1 b3: XX")).to be == true
  end

  it 'complex outputdir with rel' do
    Bake.startBake("outDir/main", ["testTcRel"])
    expect(($mystring.include?"from main 1: testOut1")).to be == true
    expect(($mystring.include?"from main 2: ../testOut2")).to be == true
  end

  it 'complex outputdir with abs' do
    Bake.startBake("outDir/main", ["testDtcAbs"])
    if Utils::OS.windows?
      expect(($mystring.include?"from main 1: C:/temp/testOutDirD")).to be == true
      expect(($mystring.include?"from main 2: C:/temp/testOutDirD")).to be == true
    else
      expect(($mystring.include?"from main 1: /tmp/testOutDirD")).to be == true
      expect(($mystring.include?"from main 2: /tmp/testOutDirD")).to be == true
    end
  end

  it 'complex outputdir with variables' do
    Bake.startBake("var/main", ["UnitTestBase"])
    expect(($mystring.include?"-->main_Lib<--")).to be == true
  end

  it 'cmd failed in subst' do
    Bake.startBake("brokenSubstCmd/main", ["test_1"])

    expect(($mystring.include?"brokenSubstCmd/main/Project.meta:4: Error: Command not successful: gcc soWrong")).to be == true
    expect(($mystring.include?"Building failed.")).to be == true
  end

  it 'cmd does not exist in subst' do
    Bake.startBake("brokenSubstCmd/main", ["test_2"])

    expect(($mystring.include?"brokenSubstCmd/main/Project.meta:10: Error: Command not successful: doesNotExist")).to be == true
    expect(($mystring.include?"Building failed.")).to be == true
  end

  it 'could not resolve' do
    Bake.startBake("brokenSubstCmd/main", ["test_3"])
    expect($mystring.split("Could not resolve").length).to be == 3
    expect(ExitHelper.exit_code).to be > 0
  end

  it 'incomplete' do
    Bake.startBake("brokenSubstCmd/main", ["test_4"])
    expect(($mystring.include?"'$(' found but no ')'")).to be == true
    expect(ExitHelper.exit_code).to be > 0
  end

  it 'empty var' do
    Bake.startBake("var/main", ["EmptyVar"])
    expect(($mystring.include?"EMPTYEMPTY")).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'original dir' do
    Bake.startBake("original/main", ["--adapt", "folder1"])
    expect(($mystring.include?"main to folder1: ../sub/folder1")).to be == true
    expect(($mystring.include?"folder2 to main\: ../../main")).to be == true
    expect(($mystring.match(/main to main:.*spec\/testdata\/original\/main/))).not_to be_nil
    expect(ExitHelper.exit_code).to be == 0
  end

end

end

