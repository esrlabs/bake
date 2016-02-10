#!/usr/bin/env ruby

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'socket'
require 'fileutils'
require 'helper'

module Bake

describe "VarSubst" do
  
  it 'vars should be substed' do
    Bake.startBake("cache/main", ["test", "--do", "var"])

    expect(($mystring.include?"MainConfigName_lib1 test")).to be == true
    expect(($mystring.include?"MainConfigName_main test")).to be == true
    
    expect(($mystring.include?"MainProjectName_lib1 main")).to be == true
    expect(($mystring.include?"MainProjectName_main main")).to be == true

    expect(($mystring.include?"ProjectName_lib1 lib1")).to be == true
    expect(($mystring.include?"ProjectName_main main")).to be == true

    expect(($mystring.include?"ConfigName_lib1 testsub")).to be == true
    expect(($mystring.include?"ConfigName_main test")).to be == true

    expect(($mystring.include?"OutputDir_lib1 build_testsub_main_test")).to be == true
    expect(($mystring.include?"OutputDir_main build_test")).to be == true

    expect(($mystring.include?"ArtifactName_lib1 this.name\n")).to be == true
    expect(($mystring.include?"ArtifactName_main main.exe")).to be == true

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


  it 'pathes' do
    Bake.startBake("cache/main", ["testPathes", "-v2"])

    if not Utils::OS.windows?
      expect($mystring.scan("/usr/bin").count).to be >= 5 
    else
      expect($mystring.scan("ruby").count).to be == 2 # assuming ruby is is a ruby dir
      expect($mystring.scan("bin").count).to be >= 3 # assuming that gcc in in a bin dir
    end
  end  

  it 'complex outputdir' do
    Bake.startBake("multiProj/main", ["test1"])
    expect(($mystring.include?"Substitute variable '$(OutputDir,testSub2)' with empty string, because syntax of complex variable OutputDir is not $(OutputDir,<project name>,<config name>)")).to be == true
    expect(($mystring.include?"Substitute variable '$(OutputDir,main,fasel)' with empty string, because config fasel not found for project main")).to be == true
    expect(($mystring.include?"Substitute variable '$(OutputDir,bla,fasel)' with empty string, because project bla not found")).to be == true
    
    expect(($mystring.include?"from testSub1 1: ../main/build_test1")).to be == true
    expect(($mystring.include?"from testSub1 2: ../main/build_testLib1_main_test1")).to be == true
    expect(($mystring.include?"from testSub1 3: build_testSub1_main_test1")).to be == true
    expect(($mystring.include?"from testSub1 4: build_testSub2_main_test1")).to be == true

    expect(($mystring.include?"from testLib1 1: build_test1")).to be == true
    expect(($mystring.include?"from testLib1 2: build_testLib1_main_test1")).to be == true
    expect(($mystring.include?"from testLib1 3: ../lib/build_testSub1_main_test1")).to be == true
    expect(($mystring.include?"from testLib1 4: ../lib/build_testSub2_main_test1")).to be == true
    
    expect(($mystring.include?"from test1 1: build_test1")).to be == true
    expect(($mystring.include?"from test1 2: build_testLib1_main_test1")).to be == true
    expect(($mystring.include?"from test1 3: ../lib/build_testSub1_main_test1")).to be == true
    expect(($mystring.include?"from test1 4: ../lib/build_testSub2_main_test1")).to be == true
    
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
end

end
