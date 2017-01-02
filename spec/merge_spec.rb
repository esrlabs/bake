#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'

module Bake

describe "Merging Configs" do

  it 'build base (all)' do
    expect(File.exists?("spec/testdata/merge/main/build/testL1/libmain.a")).to be == false
    expect(File.exists?("spec/testdata/merge/main/build/testL2/libmain.a")).to be == false
    expect(File.exists?("spec/testdata/merge/main/build/testL3/libmain.a")).to be == false
    Bake.startBake("merge/main", ["testL1", "--rebuild"])
    expect(File.exists?("spec/testdata/merge/main/build/testL1/libmain.a")).to be == true
    expect(File.exists?("spec/testdata/merge/main/build/testL2/libmain.a")).to be == false
    expect(File.exists?("spec/testdata/merge/main/build/testL3/libmain.a")).to be == false
  end

  it 'build child (all)' do
    expect(File.exists?("spec/testdata/merge/main/build/testL1/libmain.a")).to be == false
    expect(File.exists?("spec/testdata/merge/main/build/testL2/libmain.a")).to be == false
    expect(File.exists?("spec/testdata/merge/main/build/testL3/libmain.a")).to be == false
    Bake.startBake("merge/main", ["testL2", "--rebuild"])
    expect(File.exists?("spec/testdata/merge/main/build/testL1/libmain.a")).to be == false
    expect(File.exists?("spec/testdata/merge/main/build/testL2/libmain.a")).to be == true
    expect(File.exists?("spec/testdata/merge/main/build/testL3/libmain.a")).to be == false
  end

  it 'build grandchild (all)' do
    expect(File.exists?("spec/testdata/merge/main/build/testL1/libmain.a")).to be == false
    expect(File.exists?("spec/testdata/merge/main/build/testL2/libmain.a")).to be == false
    expect(File.exists?("spec/testdata/merge/main/build/testL3/libmain.a")).to be == false
    Bake.startBake("merge/main", ["testL3", "--rebuild"])
    expect(File.exists?("spec/testdata/merge/main/build/testL1/libmain.a")).to be == false
    expect(File.exists?("spec/testdata/merge/main/build/testL2/libmain.a")).to be == false
    expect(File.exists?("spec/testdata/merge/main/build/testL3/libmain.a")).to be == true
  end

  it 'file and exclude file (all)' do
    Bake.startBake("merge/main", ["testL3", "--rebuild"])
    expect($mystring.include?("stestL1.cpp")).to be == true
    expect($mystring.include?("stestL2.cpp")).to be == true
    expect($mystring.include?("stestL3.cpp")).to be == true
    expect($mystring.include?("ex.cpp")).to be == false
  end

  it 'file and exclude file (child)' do
    expect(File.exists?("spec/testdata/merge/main/build/testL5/libmain.a")).to be == false
    Bake.startBake("merge/main", ["testL5", "--rebuild"])
    expect($mystring.include?("stestL5.cpp")).to be == true
    expect(File.exists?("spec/testdata/merge/main/build/testL5/libmain.a")).to be == true
  end

  it 'file and exclude file (parent)' do
    expect(File.exists?("spec/testdata/merge/main/build/testL6/libmain.a")).to be == false
    Bake.startBake("merge/main", ["testL6", "--rebuild"])
    expect($mystring.include?("stestL1.cpp")).to be == true
    expect(File.exists?("spec/testdata/merge/main/build/testL6/libmain.a")).to be == true
  end


  it 'deps (all)' do
    Bake.startBake("merge/main", ["testL3", "--rebuild"])

    posdep11 = $mystring.index("depL1_1 (lib)")
    posdep12 = $mystring.index("depL1_2 (lib)")
    posdep21 = $mystring.index("depL2_1 (lib)")
    posdep22 = $mystring.index("depL2_2 (lib)")
    posdep31 = $mystring.index("depL3_1 (lib)")
    posdep22n = $mystring.index("depL2_2 (new)")
    posdep32 = $mystring.index("depL3_2 (lib)")

    expect((posdep11 < posdep12)).to be == true
    expect((posdep12 < posdep21)).to be == true
    expect((posdep21 < posdep22)).to be == true
    expect((posdep22 < posdep31)).to be == true
    expect((posdep31 < posdep22n)).to be == true
    expect((posdep22n < posdep32)).to be == true

    expect($mystring.split("depL1_1 (lib)").length == $mystring.split("depL2_1 (lib)").length).to be == true
  end

  it 'deps (child)' do
    Bake.startBake("merge/main", ["testL5", "--rebuild"])

    posdep51 = $mystring.index("depL5_1")
    posdep52 = $mystring.index("depL5_2")

    expect((posdep51 < posdep52)).to be == true
  end

  it 'deps (parent)' do
    Bake.startBake("merge/main", ["testL6", "--rebuild"])

    posdep11 = $mystring.index("depL1_1")
    posdep12 = $mystring.index("depL1_2")

    expect((posdep11 < posdep12)).to be == true
  end

  it 'libs (all)' do
    Bake.startBake("merge/main", ["testL3E", "--rebuild", "-v2"])

    posExe  = $mystring.index("testL3E/main"+Bake::Toolchain.outputEnding)
    pos1  = $mystring.index("-Llib",posExe)
    pos2  = $mystring.index("L1_1",posExe)
    pos3  = $mystring.index("blah1",posExe)
    pos4  = $mystring.index("L1_2",posExe)
    pos5  = $mystring.index("L2_1",posExe)
    pos6  = $mystring.index("blah2",posExe)
    pos7  = $mystring.index("L2_2",posExe)
    pos8  = $mystring.index("L3_1",posExe)
    pos9  = $mystring.index("blah3",posExe)
    pos10 = $mystring.index("L3_2",posExe)

    expect((pos1 < pos2)).to be == true
    expect((pos2 < pos3)).to be == true
    expect((pos3 < pos4)).to be == true
    expect((pos4 < pos5)).to be == true
    expect((pos5 < pos6)).to be == true
    expect((pos6 < pos7)).to be == true
    expect((pos7 < pos8)).to be == true
    expect((pos8 < pos9)).to be == true
    expect((pos9 < pos10)).to be == true

  end

  it 'libs (child)' do
    Bake.startBake("merge/main", ["testL5E", "--rebuild", "-v2"])

    posExe  = $mystring.index("testL5E/main"+Bake::Toolchain.outputEnding)
    pos1  = $mystring.index("-Llib",posExe)
    pos2  = $mystring.index("L5_1",posExe)
    pos3  = $mystring.index("blah5",posExe)
    pos4  = $mystring.index("L5_2",posExe)

    expect((pos1 < pos2)).to be == true
    expect((pos2 < pos3)).to be == true
    expect((pos3 < pos4)).to be == true
  end

  it 'libs (parent)' do
    Bake.startBake("merge/main", ["testL6E", "--rebuild", "-v2"])

    posExe  = $mystring.index("testL6E/main"+Bake::Toolchain.outputEnding)
    pos1  = $mystring.index("-Llib",posExe)
    pos2  = $mystring.index("L1_1",posExe)
    pos3  = $mystring.index("blah1",posExe)
    pos4  = $mystring.index("L1_2",posExe)

    expect((pos1 < pos2)).to be == true
    expect((pos2 < pos3)).to be == true
    expect((pos3 < pos4)).to be == true
  end


  it 'steps (all)' do
    Bake.startBake("merge/main", ["testL3", "--rebuild"])

    posPre1_1  = $mystring.index( "Pre1_1")
    posPre1_2  = $mystring.index( "Pre1_2")
    posPre2_1  = $mystring.index( "Pre2_1")
    posPre2_2  = $mystring.index( "Pre2_2")
    posPre3_1  = $mystring.index( "Pre3_1")
    posPre3_2  = $mystring.index( "Pre3_2")
    posPst1_1  = $mystring.index("Post1_1")
    posPst1_2  = $mystring.index("Post1_2")
    posPst2_1  = $mystring.index("Post2_1")
    posPst2_2  = $mystring.index("Post2_2")
    posPst3_1  = $mystring.index("Post3_1")
    posPst3_2  = $mystring.index("Post3_2")

    expect((posPre1_1 < posPre1_2)).to be == true
    expect((posPre1_2 < posPre2_1)).to be == true
    expect((posPre2_1 < posPre2_2)).to be == true
    expect((posPre2_2 < posPre3_1)).to be == true
    expect((posPre3_1 < posPre3_2)).to be == true
    expect((posPre3_2 < posPst1_1)).to be == true
    expect((posPst1_1 < posPst1_2)).to be == true
    expect((posPst1_2 < posPst2_1)).to be == true
    expect((posPst2_1 < posPst2_2)).to be == true
    expect((posPst2_2 < posPst3_1)).to be == true
    expect((posPst3_1 < posPst3_2)).to be == true
  end


  it 'steps (child)' do
    Bake.startBake("merge/main", ["testL5", "--rebuild"])

    posPre5_1  = $mystring.index( "Pre5_1")
    posPre5_2  = $mystring.index( "Pre5_2")
    posPst5_1  = $mystring.index("Post5_1")
    posPst5_2  = $mystring.index("Post5_2")

    expect((posPre5_1 < posPre5_2)).to be == true
    expect((posPre5_2 < posPst5_1)).to be == true
    expect((posPst5_1 < posPst5_2)).to be == true
  end

  it 'steps (parent)' do
    Bake.startBake("merge/main", ["testL6", "--rebuild"])

    posPre1_1  = $mystring.index( "Pre1_1")
    posPre1_2  = $mystring.index( "Pre1_2")
    posPst1_1  = $mystring.index("Post1_1")
    posPst1_2  = $mystring.index("Post1_2")

    expect((posPre1_1 < posPre1_2)).to be == true
    expect((posPre1_2 < posPst1_1)).to be == true
    expect((posPst1_1 < posPst1_2)).to be == true
  end


  it 'defaulttoolchain (all)' do
    Bake.startBake("merge/main", ["testL3E", "--rebuild", "-v2"])

    expect($mystring.include?("def1")).to be == true
    expect($mystring.include?("def2")).to be == true
    expect($mystring.include?("-O3")).to be == true
  end

  it 'defaulttoolchain (child)' do
    Bake.startBake("merge/main", ["testL5E", "--rebuild", "-v2"])

    expect($mystring.include?("def1")).to be == false
    expect($mystring.include?("def5")).to be == true
    expect($mystring.include?("-O3")).to be == false
  end

  it 'defaulttoolchain (parent)' do
    Bake.startBake("merge/main", ["testL6E", "--rebuild", "-v2"])

    expect($mystring.include?("def1")).to be == true
    expect($mystring.include?("-O3")).to be == true
  end

  # Valid for custom config

  it 'step (all)' do
    Bake.startBake("merge/main", ["testC3", "--rebuild"])

    expect($mystring.include?("C1")).to be == false
    expect($mystring.include?("C2")).to be == false
    expect($mystring.include?("C3")).to be == true
  end

  it 'step (child)' do
    Bake.startBake("merge/main", ["testC5", "--rebuild"])

    expect($mystring.include?("C5")).to be == true
  end

  it 'step (parent)' do
    Bake.startBake("merge/main", ["testC6", "--rebuild"])

    expect($mystring.include?("C1")).to be == true
  end

  it 'step (exe extends custom)' do
    Bake.startBake("merge/main", ["testC5E", "--rebuild"])

    expect($mystring.include?("C5")).to be == true
  end

  it 'step (custom extends exe)' do
    Bake.startBake("merge/main", ["testC7", "--rebuild"])

    expect($mystring.include?("C7")).to be == true
  end


  # Valid for library and exe config

  it 'includedir (all)' do
    Bake.startBake("merge/main", ["testE3", "--rebuild", "-v2"])

    posinc11 = $mystring.index("Inc1_1")
    posinc12 = $mystring.index("Inc1_2")
    posinc21 = $mystring.index("Inc2_1")
    posinc22 = $mystring.index("Inc2_2")
    posinc31 = $mystring.index("Inc3_1")
    posinc32 = $mystring.index("Inc3_2")

    expect((posinc11 < posinc12)).to be == true
    expect((posinc12 < posinc21)).to be == true
    expect((posinc21 < posinc22)).to be == true
    expect((posinc22 < posinc31)).to be == true
    expect((posinc31 < posinc32)).to be == true
  end

  it 'includedir (child)' do
    Bake.startBake("merge/main", ["testE5", "--rebuild", "-v2"])

    posinc51 = $mystring.index("Inc5_1")
    posinc52 = $mystring.index("Inc5_2")

    expect((posinc51 < posinc52)).to be == true

  end

  it 'includedir (parent)' do
    Bake.startBake("merge/main", ["testE6", "--rebuild", "-v2"])

    posinc11 = $mystring.index("Inc1_1")
    posinc12 = $mystring.index("Inc1_2")

    expect((posinc11 < posinc12)).to be == true
  end

  it 'toolchain (all)' do
    Bake.startBake("merge/main", ["testE3", "--rebuild", "-v2"])

    expect($mystring.include?("def1")).to be == true
    expect($mystring.include?("def2")).to be == true
    expect($mystring.include?("-O3")).to be == true
  end

  it 'toolchain (child)' do
    Bake.startBake("merge/main", ["testE5", "--rebuild", "-v2"])

    expect($mystring.include?("def1")).to be == false
    expect($mystring.include?("def5")).to be == true
    expect($mystring.include?("-O3")).to be == false
  end

  it 'toolchain (parent)' do
    Bake.startBake("merge/main", ["testE6", "--rebuild", "-v2"])

    expect($mystring.include?("def1")).to be == true
    expect($mystring.include?("-O3")).to be == true
  end

  # Valid for exe config
  it 'linkerscript, artifact, map (all)' do
    if not RUBY_PLATFORM =~ /darwin/
      expect(File.exists?("spec/testdata/merge/main/build/testE3/testE3.map")).to be == false
      expect(File.exists?("spec/testdata/merge/main/build/testE3/testE3.exe")).to be == false

      Bake.startBake("merge/main", ["testE3", "--rebuild", "-v2"])

      expect($mystring.include?("linkerscript3")).to be == true
      expect(File.exists?("spec/testdata/merge/main/build/testE3/testE3.exe")).to be == true
      expect(File.exists?("spec/testdata/merge/main/build/testE3/testE3.map")).to be == true
    end
  end

  it 'linkerscript, artifact, map (child)' do
    if not RUBY_PLATFORM =~ /darwin/
      expect(File.exists?("spec/testdata/merge/main/build/testE5/testE5.map")).to be == false
      expect(File.exists?("spec/testdata/merge/main/build/testE5/testE5.exe")).to be == false

      Bake.startBake("merge/main", ["testE5", "--rebuild", "-v2"])

      expect($mystring.include?("linkerscript5")).to be == true
      expect(File.exists?("spec/testdata/merge/main/build/testE5/testE5.exe")).to be == true
      expect(File.exists?("spec/testdata/merge/main/build/testE5/testE5.map")).to be == true
    end
  end

  it 'linkerscript, artifact, map (parent)' do
    if not RUBY_PLATFORM =~ /darwin/
      expect(File.exists?("spec/testdata/merge/main/build/testE6/testE1.exe")).to be == false
      expect(File.exists?("spec/testdata/merge/main/build/testE6/testE1.map")).to be == false

      Bake.startBake("merge/main", ["testE6", "--rebuild", "-v2"])

      expect($mystring.include?("linkerscript1")).to be == true
      expect(File.exists?("spec/testdata/merge/main/build/testE6/testE1.exe")).to be == true
      expect(File.exists?("spec/testdata/merge/main/build/testE6/testE1.map")).to be == true
    end
  end

  it 'parent broken' do
    expect(File.exists?("spec/testdata/merge/main/build/testE6/testE6.exe")).to be == false
    Bake.startBake("merge/main", ["ParentKaputt", "--rebuild"])
    expect($mystring.include?("Error: Config 'dasGibtsDochGarNicht' not found")).to be == true
  end

  it 'var subst' do
    expect(File.exists?("spec/testdata/merge/main/build/testE6/testE1.map")).to be == false

    Bake.startBake("merge/main", ["testE6", "--rebuild"])

    expect($mystring.include?("**testE1.exe**")).to be == true # subst
    expect(File.exists?("spec/testdata/merge/main/build/testE6/testE1.map")).to be == true # subst
  end

  # explicitly test all toolchain merges

  it 'toolchain compiler set' do
    Bake.startBake("merge/main", ["testTC2", "--rebuild", "-v2"])
    expect($mystring.include?("-DX -DY")).to be == true
  end

  it 'toolchain overwrite basedOn' do
    Bake.startBake("merge/main", ["testTC2", "--rebuild", "-v2"])
    expect($mystring.include?("g++")).to be == true
  end

  it 'toolchain compiler flags merge' do
    Bake.startBake("merge/main", ["testTC3", "--rebuild", "-v2"])
    expect($mystring.include?("-DX -DZ ")).to be == true
    expect($mystring.include?("-DGAGA")).to be == true
  end

  it 'toolchain compiler define merge' do
    Bake.startBake("merge/main", ["testTC4", "--rebuild", "-v2"])
    expect($mystring.include?("-DGAGA -DGUGU")).to be == true
  end

  it 'toolchain internal defines merge' do
    Bake.startBake("merge/main", ["testTC4", "--rebuild", "--incs-and-defs"])
    expect($mystring.include?("HARHAR")).to be == true
    expect($mystring.include?("Oooooh")).to be == false
  end

  it 'toolchain internal defines not merge' do
    Bake.startBake("merge/main", ["testTC5", "--rebuild", "--incs-and-defs"])
    expect($mystring.include?("HARHAR")).to be == false
    expect($mystring.include?("Oooooh")).to be == true
  end

  it 'toolchain compiler command merge' do
    Bake.startBake("merge/main", ["testTC6", "--rebuild", "-v2"])
    expect($mystring.include?("com1")).to be == true
  end

  it 'toolchain compiler command not merge' do
    Bake.startBake("merge/main", ["testTC7", "--rebuild", "-v2"])
    expect($mystring.include?("com1")).to be == true
  end

  it 'toolchain archiver set' do
    Bake.startBake("merge/main", ["testTC11", "--rebuild", "-v2"])
    expect($mystring.include?("com1")).to be == true
  end

  it 'toolchain archiver command merge' do
    Bake.startBake("merge/main", ["testTC12", "--rebuild", "-v2"])
    expect($mystring.include?("com1")).to be == true
    expect($mystring.include?("-XXX")).to be == true
  end

  it 'toolchain archiver flags merge' do
    Bake.startBake("merge/main", ["testTC13", "--rebuild", "-v2"])
    expect($mystring.include?("com2")).to be == true
    expect($mystring.include?("-XXX")).to be == true
    expect($mystring.include?("-YYY")).to be == true
  end

  it 'toolchain linker set' do
    Bake.startBake("merge/main", ["testTC21", "--rebuild", "-v2"])
    expect($mystring.include?("com1")).to be == true
  end

  it 'toolchain linker command merge' do
    Bake.startBake("merge/main", ["testTC22", "--rebuild", "-v2"])
    expect($mystring.include?("com1")).to be == true
    expect($mystring.include?("-XXX")).to be == true
  end

  it 'toolchain linker flags merge' do
    Bake.startBake("merge/main", ["testTC23", "--rebuild", "-v2"])
    expect($mystring.include?("com2")).to be == true
    expect($mystring.include?("-XXX")).to be == true
    expect($mystring.include?("-YYY")).to be == true
  end

  it 'toolchain outputdir no merge' do
    Bake.startBake("merge/main", ["testTC31", "--rebuild", "-v2"])
    expect($mystring.include?("-o testEFG/main")).to be == true
  end

  it 'toolchain outputdir merge' do
    Bake.startBake("merge/main", ["testTC32", "--rebuild", "-v2"])
    expect($mystring.include?("-o testABC/main")).to be == true
  end

  it 'toolchain docu no merge' do
    Bake.startBake("merge/main", ["testTC31", "--rebuild", "-v2", "--docu"])
    expect($mystring.include?("blah fasel")).to be == false
    expect($mystring.include?("nix da")).to be == true
  end

  it 'toolchain docu merge' do
    Bake.startBake("merge/main", ["testTC32", "--rebuild", "-v2", "--generate-doc"])
    expect($mystring.include?("blah fasel")).to be == true
    expect($mystring.include?("nix da")).to be == false
  end

  it 'toolchain docu derive' do
    Bake.startBake("merge/main", ["testTC32", "--incs-and-defs=bake"])
    expect($mystring.include?("HARHAR")).to be == true
    expect($mystring.include?("Oooooh")).to be == false
  end

  it 'toolchain internal includes no merge' do
    Bake.startBake("merge/main", ["testTC31", "--rebuild", "-v2", "--incs-and-defs"])
    expect($mystring.include?("HARHAR")).to be == false
    expect($mystring.include?("Oooooh")).to be == true
  end

  it 'toolchain internal includes merge' do
    Bake.startBake("merge/main", ["testTC32", "--rebuild", "-v2", "--incs-and-defs"])
    expect($mystring.include?("HARHAR")).to be == true
    expect($mystring.include?("Oooooh")).to be == false
  end

  it 'inherit correct for merge' do
    Bake.startBake("mergeInc/main", ["test", "--rebuild"])
    expect($mystring.include?("Rebuilding done.")).to be == true
  end

  it 'multi inheritence' do
    Bake.startBake("merge/main", ["testMulti"])

    posXtestMultiBase1Base1X = $mystring.index("XtestMultiBase1Base1X")
    posXtestMultiBase1Base2X = $mystring.index("XtestMultiBase1Base2X")
    posXtestMultiBase1X = $mystring.index("XtestMultiBase1X")
    posXtestMultiBase2X = $mystring.index("XtestMultiBase2X")
    posXtestMultiX = $mystring.index("XtestMultiX")

    expect((0 < posXtestMultiBase1Base1X)).to be == true
    expect((posXtestMultiBase1Base1X < posXtestMultiBase1Base2X)).to be == true
    expect((posXtestMultiBase1Base2X < posXtestMultiBase1X)).to be == true
    expect((posXtestMultiBase1X < posXtestMultiBase2X)).to be == true
    expect((posXtestMultiBase2X < posXtestMultiX)).to be == true
  end


end

end
