#!/usr/bin/env ruby

require 'common/version'

require 'tocxx'
require 'bake/options/options'
require 'imported/utils/exit_helper'
require 'socket'
require 'fileutils'
require 'helper'

module Bake

describe "VarSubst" do
  
  it 'vars should be substed' do
    Bake.startBake("cache/main", ["test", "--include_filter", "var"])

    expect(($mystring.include?"MainConfigName_lib1 test")).to be == true
    expect(($mystring.include?"MainConfigName_main test")).to be == true
    
    expect(($mystring.include?"MainProjectName_lib1 main")).to be == true
    expect(($mystring.include?"MainProjectName_main main")).to be == true

    expect(($mystring.include?"ProjectName_lib1 lib1")).to be == true
    expect(($mystring.include?"ProjectName_main main")).to be == true

    expect(($mystring.include?"ConfigName_lib1 testsub")).to be == true
    expect(($mystring.include?"ConfigName_main test")).to be == true

    expect(($mystring.include?"OutputDir_lib1 test_main")).to be == true
    expect(($mystring.include?"OutputDir_main test")).to be == true

    expect(($mystring.include?"ArtifactName_lib1 \n")).to be == true
    expect(($mystring.include?"ArtifactName_main main.exe")).to be == true

    expect(($mystring.include?"ArtifactNameBase_lib1 \n")).to be == true
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
  end

  it 'artifactname' do
    Bake.startBake("cache/main", ["test2", "--include_filter", "var"])
  
    expect(($mystring.include?"ArtifactName_main abc.def")).to be == true
    expect(($mystring.include?"ArtifactNameBase_main abc")).to be == true
  end  

  
end

end
