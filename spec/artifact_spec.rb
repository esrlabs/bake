#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'socket'
require 'fileutils'

module Bake

describe "Artifact" do

  it 'default exe' do
    Bake.startBake("artifact/main", ["test_Default_exe"])
    expect(($mystring.include?"build/test_Default_lib_main_test_Default_exe/libmain.a")).to be == true
    expect(($mystring.include?" build/test_Default_exe/main#{Bake::Toolchain.outputEnding}")).to be == true
    expect(($mystring.include?" LExtL")).to be == false
    expect(($mystring.include?" EExtE")).to be == false

    Bake.startBake("artifact/main", ["test_Default_exe"])
    expect(($mystring.split("Linking").length)).to be == 2
  end

  it 'artifactName exe' do
    Bake.startBake("artifact/main", ["test_ArtifactName_exe"])
    expect(($mystring.include?"build/test_ArtifactName_lib_main_test_ArtifactName_exe/LNameL")).to be == true
    expect(($mystring.include?" build/test_ArtifactName_exe/ENameE#{Bake::Toolchain.outputEnding}")).to be == true
    expect(($mystring.include?" LExtL")).to be == false
    expect(($mystring.include?" EExtE")).to be == false

    Bake.startBake("artifact/main", ["test_ArtifactName_exe"])
    expect(($mystring.split("Linking").length)).to be == 2    
  end

  it 'ArtifactExtension exe' do
    Bake.startBake("artifact/main", ["test_ArtifactExtension_exe"])
    expect(($mystring.include?"build/test_ArtifactExtension_lib_main_test_ArtifactExtension_exe/libmain.LExtL")).to be == true
    expect(($mystring.include?" build/test_ArtifactExtension_exe/main.EExtE")).to be == true
    expect(($mystring.include?" main.EExtE.exe")).to be == false

    Bake.startBake("artifact/main", ["test_ArtifactExtension_exe"])
    expect(($mystring.split("Linking").length)).to be == 2
  end

  it 'ArtifactNameExtension exe' do
    Bake.startBake("artifact/main", ["test_ArtifactNameExtension_exe"])
    expect(($mystring.include?"build/test_ArtifactNameExtension_lib_main_test_ArtifactNameExtension_exe/LNameL")).to be == true
    expect(($mystring.include?" build/test_ArtifactNameExtension_exe/ENameE#{Bake::Toolchain.outputEnding}")).to be == true
    expect(($mystring.include?" LExtL")).to be == false
    expect(($mystring.include?" EExtE")).to be == false

    Bake.startBake("artifact/main", ["test_ArtifactNameExtension_exe"])
    expect(($mystring.split("Linking").length)).to be == 2
  end

end

end
