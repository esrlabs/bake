#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'bake/util'
require 'common/exit_helper'
require 'socket'
require 'fileutils'

module Bake

describe "Adapt" do

  it 'Dep extend 0' do

    absAdapt = File.expand_path("spec/testdata/adapt/adapt/dep/dep_extend")

    Bake.startBake("adapt/main", ["test_dep0", "--rebuild", "--adapt", absAdapt])
    expect($mystring.include?("Building 1 of 4: lib1 (test_other)")).to be == true
    expect($mystring.include?("Building 2 of 4: lib1 (test_ok)")).to be == true
    expect($mystring.include?("Building 3 of 4: lib3 (test_ok)")).to be == true
    expect($mystring.include?("Building 4 of 4: main (test_dep0)")).to be == true
    expect($mystring.include?("Rebuilding done.")).to be == true
  end

  it 'Dep extend 2' do
    Bake.startBake("adapt/main", ["test_dep2", "--rebuild", "--adapt", "dep_extend"])
    expect($mystring.include?("Building 1 of 5: lib1 (test_ok)")).to be == true
    expect($mystring.include?("Building 2 of 5: lib2 (test_ok)")).to be == true
    expect($mystring.include?("Building 3 of 5: lib1 (test_other)")).to be == true
    expect($mystring.include?("Building 4 of 5: lib3 (test_ok)")).to be == true
    expect($mystring.include?("Building 5 of 5: main (test_dep2)")).to be == true
    expect($mystring.include?("Rebuilding done.")).to be == true
  end

  it 'Dep remove 0' do
    Bake.startBake("adapt/main", ["test_dep0", "--rebuild", "--adapt", "dep_remove"])
    expect($mystring.include?("Building 1 of 1: main (test_dep0)")).to be == true
    expect($mystring.include?("Rebuilding done.")).to be == true
  end

  it 'Dep remove 2' do
    Bake.startBake("adapt/main", ["test_dep2", "--rebuild", "--adapt", "dep_remove"])
    expect($mystring.include?("Building 1 of 2: lib2 (test_ok)")).to be == true
    expect($mystring.include?("Building 2 of 2: main (test_dep2)")).to be == true
    expect($mystring.include?("Rebuilding done.")).to be == true
  end

  it 'Dep replace 0' do
    Bake.startBake("adapt/main", ["test_dep0", "--rebuild", "--adapt", "dep_replace"])
    expect($mystring.include?("Building 1 of 4: lib1 (test_other)")).to be == true
    expect($mystring.include?("Building 2 of 4: lib1 (test_ok)")).to be == true
    expect($mystring.include?("Building 3 of 4: lib3 (test_ok)")).to be == true
    expect($mystring.include?("Building 4 of 4: main (test_dep0)")).to be == true
    expect($mystring.include?("Rebuilding done.")).to be == true
  end

  it 'Dep replace 2' do
    Bake.startBake("adapt/main", ["test_dep2", "--rebuild", "--adapt", "dep_replace"])
    expect($mystring.include?("Building 1 of 4: lib1 (test_other)")).to be == true
    expect($mystring.include?("Building 2 of 4: lib1 (test_ok)")).to be == true
    expect($mystring.include?("Building 3 of 4: lib3 (test_ok)")).to be == true
    expect($mystring.include?("Building 4 of 4: main (test_dep2)")).to be == true
    expect($mystring.include?("Rebuilding done.")).to be == true
  end

  it 'Set extend 0' do
    Bake.startBake("adapt/main", ["test_set0", "--rebuild", "--adapt", "set_extend"])
    expect($mystring.include?("vars: VARNEW1VARNEW3-")).to be == true
    expect($mystring.include?("Rebuilding done.")).to be == true
  end

  it 'Set extend 2' do
    Bake.startBake("adapt/main", ["test_set2", "--rebuild", "--adapt", "set_extend"])
    expect($mystring.include?("vars: VARNEW1VAR2VARNEW3-")).to be == true
    expect($mystring.include?("Rebuilding done.")).to be == true
  end

  it 'Set remove 0' do
    Bake.startBake("adapt/main", ["test_set0", "--rebuild", "--adapt", "set_remove"])
    expect($mystring.include?("vars: -")).to be == true
    expect($mystring.include?("Rebuilding done.")).to be == true
  end

  it 'Set remove 2' do
    Bake.startBake("adapt/main", ["test_set2", "--rebuild", "--adapt", "set_remove"])
    expect($mystring.include?("vars: VAR2-")).to be == true
    expect($mystring.include?("Rebuilding done.")).to be == true
  end

  it 'Set replace 0' do
    Bake.startBake("adapt/main", ["test_set0", "--rebuild", "--adapt", "set_replace"])
    expect($mystring.include?("vars: VARNEW1VARNEW3-")).to be == true
    expect($mystring.include?("Rebuilding done.")).to be == true
  end

  it 'Set replace 2' do
    Bake.startBake("adapt/main", ["test_set2", "--rebuild", "--adapt", "set_replace"])
    expect($mystring.include?("vars: VARNEW1VARNEW3-")).to be == true
    expect($mystring.include?("Rebuilding done.")).to be == true
  end


  it 'ArtifactName extend 0' do
    Bake.startBake("adapt/main", ["test_art0", "--rebuild", "-v2", "--adapt", "art_extend"])
    expect($mystring.include?("new.exe")).to be == true
    expect($mystring.include?("Rebuilding done.")).to be == true
  end

  it 'ArtifactName extend 1' do
    Bake.startBake("adapt/main", ["test_art1", "--rebuild", "-v2", "--adapt", "art_extend"])
    expect($mystring.include?("new.exe")).to be == true
    expect($mystring.include?("Rebuilding done.")).to be == true
  end

  it 'ArtifactName remove 0' do
    Bake.startBake("adapt/main", ["test_art0", "--rebuild", "-v2", "--adapt", "art_remove_ok"])
    expect($mystring.include?("main"+Bake::Toolchain.outputEnding)).to be == true
    expect($mystring.include?("Rebuilding done.")).to be == true
  end

  it 'ArtifactName remove 1 ok' do
    Bake.startBake("adapt/main", ["test_art1", "--rebuild", "-v2", "--adapt", "art_remove_ok"])
    expect($mystring.include?("main"+Bake::Toolchain.outputEnding)).to be == true
    expect($mystring.include?("Rebuilding done.")).to be == true
  end

  it 'ArtifactName remove 1 nok' do
    Bake.startBake("adapt/main", ["test_art1", "--rebuild", "-v2", "--adapt", "art_remove_nok"])
    expect($mystring.include?("org.exe")).to be == true
    expect($mystring.include?("Rebuilding done.")).to be == true
  end

  it 'ArtifactName replace 0' do
    Bake.startBake("adapt/main", ["test_art0", "--rebuild", "-v2", "--adapt", "art_replace"])
    expect($mystring.include?("new.exe")).to be == true
    expect($mystring.include?("Rebuilding done.")).to be == true
  end

  it 'ArtifactName replace 1' do
    Bake.startBake("adapt/main", ["test_art1", "--rebuild", "-v2", "--adapt", "art_replace"])
    expect($mystring.include?("new.exe")).to be == true
    expect($mystring.include?("Rebuilding done.")).to be == true
  end

  it 'MapFile extend 0' do
    Bake.startBake("adapt/main", ["test_map0", "--rebuild", "-v2", "--adapt", "map_extend"])
    expect($mystring.include?("new.map")).to be == true
    expect($mystring.include?("Rebuilding done.")).to be == true
  end

  it 'MapFile extend 1' do
    Bake.startBake("adapt/main", ["test_map1", "--rebuild", "-v2", "--adapt", "map_extend"])
    expect($mystring.include?("new.map")).to be == true
    expect($mystring.include?("Rebuilding done.")).to be == true
  end

  it 'MapFile remove 0' do
    Bake.startBake("adapt/main", ["test_map0", "--rebuild", "-v2", "--adapt", "map_remove_ok"])
    expect($mystring.include?(".map")).to be == false
    expect($mystring.include?("Rebuilding done.")).to be == true
  end

  it 'MapFile remove 1 ok' do
    Bake.startBake("adapt/main", ["test_map1", "--rebuild", "-v2", "--adapt", "map_remove_ok"])
    expect($mystring.include?(".map")).to be == false
    expect($mystring.include?("Rebuilding done.")).to be == true
  end

  it 'MapFile remove 1 nok' do
    Bake.startBake("adapt/main", ["test_map1", "--rebuild", "-v2", "--adapt", "map_remove_nok"])
    expect($mystring.include?("org.map")).to be == true
    expect($mystring.include?("Rebuilding done.")).to be == true
  end

  it 'MapFile replace 0' do
    Bake.startBake("adapt/main", ["test_map0", "--rebuild", "-v2", "--adapt", "map_replace"])
    expect($mystring.include?("new.map")).to be == true
    expect($mystring.include?("Rebuilding done.")).to be == true
  end

  it 'MapFile replace 1' do
    Bake.startBake("adapt/main", ["test_map1", "--rebuild", "-v2", "--adapt", "map_replace"])
    expect($mystring.include?("new.map")).to be == true
    expect($mystring.include?("Rebuilding done.")).to be == true
  end

  it 'LinkerScript extend 0' do
    if not RUBY_PLATFORM =~ /darwin/
      Bake.startBake("adapt/main", ["test_lin0", "--rebuild", "-v2", "--adapt", "lin_extend"])
      expect($mystring.include?("linkerscript2.dld")).to be == true
      expect($mystring.include?("Rebuilding done.")).to be == true
    end
  end

  it 'LinkerScript extend 1' do
    if not RUBY_PLATFORM =~ /darwin/
      Bake.startBake("adapt/main", ["test_lin1", "--rebuild", "-v2", "--adapt", "lin_extend"])
      expect($mystring.include?("linkerscript2.dld")).to be == true
      expect($mystring.include?("Rebuilding done.")).to be == true
    end
  end

  it 'LinkerScript remove 0' do
    if not RUBY_PLATFORM =~ /darwin/
      Bake.startBake("adapt/main", ["test_lin0", "--rebuild", "-v2", "--adapt", "lin_remove_ok"])
      expect($mystring.include?(".dld")).to be == false
      expect(File.exists?("spec/testdata/adapt/main/build/test_lin0/main"+Bake::Toolchain.outputEnding)).to be == true
    end
  end

  it 'LinkerScript remove 1 ok' do
    if not RUBY_PLATFORM =~ /darwin/
      Bake.startBake("adapt/main", ["test_lin1", "--rebuild", "-v2", "--adapt", "lin_remove_ok"])
       expect($mystring.include?(".dld")).to be == false
       expect(File.exists?("spec/testdata/adapt/main/build/test_lin1/main"+Bake::Toolchain.outputEnding)).to be == true
    end
  end

  it 'LinkerScript remove 1 nok' do
    if not RUBY_PLATFORM =~ /darwin/
      Bake.startBake("adapt/main", ["test_lin1", "--rebuild", "-v2", "--adapt", "lin_remove_nok"])
      expect($mystring.include?("linkerscript1.dld")).to be == true
      expect($mystring.include?("Rebuilding done.")).to be == true
    end
  end

  it 'LinkerScript replace 0' do
    if not RUBY_PLATFORM =~ /darwin/
      Bake.startBake("adapt/main", ["test_lin0", "--rebuild", "-v2", "--adapt", "lin_replace"])
      expect($mystring.include?("linkerscript2.dld")).to be == true
      expect($mystring.include?("Rebuilding done.")).to be == true
    end
  end

  it 'LinkerScript replace 1' do
    if not RUBY_PLATFORM =~ /darwin/
      Bake.startBake("adapt/main", ["test_lin1", "--rebuild", "-v2", "--adapt", "lin_replace"])
      expect($mystring.include?("linkerscript2.dld")).to be == true
      expect($mystring.include?("Rebuilding done.")).to be == true
    end
  end

  it 'Files extend 0' do
    Bake.startBake("adapt/main", ["test_files0", "--rebuild", "--adapt", "files_extend", "-j", "1"])
    expect($mystring.include?("add1.cpp")).to be == true
    expect($mystring.include?("nix.cpp")).to be == true
    expect($mystring.include?("main.cpp")).to be == false
    expect($mystring.index("add1.cpp")).to be < $mystring.index("nix.cpp")
  end

  it 'Files extend 2' do
    Bake.startBake("adapt/main", ["test_files2", "--rebuild", "--adapt", "files_extend", "--threads", "1"])
    expect($mystring.include?("main.cpp")).to be == true
    expect($mystring.include?("nix.cpp")).to be == true
    expect($mystring.include?("add1.cpp")).to be == true
    expect($mystring.index("main.cpp")).to be < $mystring.index("nix.cpp")
    expect($mystring.index("nix.cpp")).to be < $mystring.index("add1.cpp")
  end

  it 'Files remove 0' do
    Bake.startBake("adapt/main", ["test_files0", "--rebuild", "--adapt", "files_remove", "--threads", "1"])
    expect($mystring.include?("add1.cpp")).to be == false
    expect($mystring.include?("nix.cpp")).to be == false
    expect($mystring.include?("main.cpp")).to be == false
  end

  it 'Files remove 2' do
    Bake.startBake("adapt/main", ["test_files2", "--rebuild", "--adapt", "files_remove", "--threads", "1"])
    expect($mystring.include?("add1.cpp")).to be == false
    expect($mystring.include?("nix.cpp")).to be == false
    expect($mystring.include?("main.cpp")).to be == true
  end

  it 'Files replace 0' do
    Bake.startBake("adapt/main", ["test_files0", "--rebuild", "--adapt", "files_replace", "-j", "1"])
    expect($mystring.include?("add1.cpp")).to be == true
    expect($mystring.include?("nix.cpp")).to be == true
    expect($mystring.include?("main.cpp")).to be == false
    expect($mystring.index("add1.cpp")).to be < $mystring.index("nix.cpp")
  end

  it 'Files replace 2' do
    Bake.startBake("adapt/main", ["test_files2", "--rebuild", "--adapt", "files_replace", "-j", "1"])
    expect($mystring.include?("add1.cpp")).to be == true
    expect($mystring.include?("nix.cpp")).to be == true
    expect($mystring.include?("main.cpp")).to be == false
    expect($mystring.index("add1.cpp")).to be < $mystring.index("nix.cpp")
  end

  it 'ExcludeFiles extend 0' do
    Bake.startBake("adapt/main", ["test_exfiles0", "--rebuild", "--adapt", "exfiles_extend", "--threads", "1"])
    expect($mystring.include?("nix.cpp")).to be == false
    expect($mystring.include?("main.cpp")).to be == true
    expect($mystring.include?("add1.cpp")).to be == true
    expect($mystring.include?("add2.cpp")).to be == false
  end

  it 'ExcludeFiles extend 2' do
    Bake.startBake("adapt/main", ["test_exfiles2", "--rebuild", "--adapt", "exfiles_extend", "--threads", "1"])
    expect($mystring.include?("nix.cpp")).to be == false
    expect($mystring.include?("main.cpp")).to be == true
    expect($mystring.include?("add1.cpp")).to be == false
    expect($mystring.include?("add2.cpp")).to be == false
  end

  it 'ExcludeFiles remove 0' do
    Bake.startBake("adapt/main", ["test_exfiles0", "--rebuild", "--adapt", "exfiles_remove", "--threads", "1"])
    expect($mystring.include?("nix.cpp")).to be == true
    expect($mystring.include?("main.cpp")).to be == true
    expect($mystring.include?("add1.cpp")).to be == true
    expect($mystring.include?("add2.cpp")).to be == true
  end

  it 'ExcludeFiles remove 2' do
    Bake.startBake("adapt/main", ["test_exfiles2", "--rebuild", "--adapt", "exfiles_remove", "--threads", "1"])
    expect($mystring.include?("nix.cpp")).to be == true
    expect($mystring.include?("main.cpp")).to be == true
    expect($mystring.include?("add1.cpp")).to be == false
    expect($mystring.include?("add2.cpp")).to be == true
  end

  it 'ExcludeFiles replace 0' do
    Bake.startBake("adapt/main", ["test_exfiles0", "--rebuild", "--adapt", "exfiles_replace", "--threads", "1"])
    expect($mystring.include?("nix.cpp")).to be == false
    expect($mystring.include?("main.cpp")).to be == true
    expect($mystring.include?("add1.cpp")).to be == true
    expect($mystring.include?("add2.cpp")).to be == false
  end

  it 'ExcludeFiles replace 2' do
    Bake.startBake("adapt/main", ["test_exfiles2", "--rebuild", "--adapt", "exfiles_replace", "--threads", "1"])
    expect($mystring.include?("nix.cpp")).to be == false
    expect($mystring.include?("main.cpp")).to be == true
    expect($mystring.include?("add1.cpp")).to be == true
    expect($mystring.include?("add2.cpp")).to be == false
  end

  it 'IncludeDir extend 0' do
    Bake.startBake("adapt/main", ["test_inc0", "--rebuild", "--adapt", "inc_extend", "-v2"])
    expect($mystring.include?("-Iinclude/a")).to be == false
    expect($mystring.include?("-Iinclude/b -Iinclude/c")).to be == true
  end

  it 'IncludeDir extend 2' do
    Bake.startBake("adapt/main", ["test_inc2", "--rebuild", "--adapt",  "inc_extend", "-v2"])
    expect($mystring.include?("-Iinclude/a -Iinclude/b -Iinclude/c")).to be == true
  end

  it 'IncludeDir remove 0' do
    Bake.startBake("adapt/main", ["test_inc0", "--rebuild", "--adapt",  "inc_remove", "-v2"])
    expect($mystring.include?("-Iinclude/a")).to be == false
    expect($mystring.include?("-Iinclude/b")).to be == false
    expect($mystring.include?("-Iinclude/c")).to be == false
  end

  it 'IncludeDir remove 2' do
    Bake.startBake("adapt/main", ["test_inc2", "--rebuild", "--adapt",  "inc_remove", "-v2"])
    expect($mystring.include?("-Iinclude/a")).to be == true
    expect($mystring.include?("-Iinclude/b")).to be == false
    expect($mystring.include?("-Iinclude/c")).to be == false
  end

  it 'IncludeDir replace 0' do
    Bake.startBake("adapt/main", ["test_inc0", "--rebuild", "--adapt",  "inc_replace", "-v2"])
    expect($mystring.include?("-Iinclude/a")).to be == false
    expect($mystring.include?("-Iinclude/b -Iinclude/c")).to be == true
  end

  it 'IncludeDir replace 2' do
    Bake.startBake("adapt/main", ["test_inc2", "--rebuild", "--adapt",  "inc_replace", "-v2"])
    expect($mystring.include?("-Iinclude/a")).to be == false
    expect($mystring.include?("-Iinclude/b -Iinclude/c")).to be == true
  end

  it 'Libs extend 0' do
    Bake.startBake("adapt/main", ["test_libs0", "--rebuild", "--adapt", "libs_extend", "-v2"])
    expect($mystring.include?("-lexlibA")).to be == false
    expect($mystring.include?("-LsearchPathX")).to be == false
    expect($mystring.include?("-l:userlibM")).to be == false
    expect($mystring.include?("-lexlibB -lexlibC -LsearchPathY -LsearchPathZ -l:userlibN -l:userlibO")).to be == true
  end

  it 'Libs extend 2' do
    Bake.startBake("adapt/main", ["test_libs2", "--rebuild", "--adapt",  "libs_extend", "-v2"])
    expect($mystring.include?("-lexlibA -lexlibB -LsearchPathX -LsearchPathY -l:userlibM -l:userlibN -lexlibB -lexlibC -LsearchPathZ -l:userlibN -l:userlibO")).to be == true
  end

  it 'Libs remove 0' do
    Bake.startBake("adapt/main", ["test_libs0", "--rebuild", "--adapt",  "libs_remove", "-v2"])
    expect($mystring.include?("-lexlib")).to be == false
    expect($mystring.include?("-LsearchPath")).to be == false
    expect($mystring.include?("-l:userlib")).to be == false
  end

  it 'Libs remove 2' do
    Bake.startBake("adapt/main", ["test_libs2", "--rebuild", "--adapt",  "libs_remove", "-v2"])
    expect($mystring.include?("-lexlibA -LsearchPathX -l:userlibM")).to be == true
    expect($mystring.include?("-lexlibB")).to be == false
    expect($mystring.include?("-lexlibC")).to be == false
    expect($mystring.include?("-LsearchPathY")).to be == false
    expect($mystring.include?("-LsearchPathZ")).to be == false
    expect($mystring.include?("-l:userlibN")).to be == false
    expect($mystring.include?("-l:userlibO")).to be == false
  end

  it 'Libs replace 0' do
    Bake.startBake("adapt/main", ["test_libs0", "--rebuild", "--adapt",  "libs_replace", "-v2"])
    expect($mystring.include?("-lexlibB -lexlibC -LsearchPathY -LsearchPathZ -l:userlibN -l:userlibO")).to be == true
    expect($mystring.include?("-lexlibA")).to be == false
    expect($mystring.include?("-LsearchPathX")).to be == false
    expect($mystring.include?("-l:userlibM")).to be == false
  end

  it 'Libs replace 2' do
    Bake.startBake("adapt/main", ["test_libs2", "--rebuild", "--adapt",  "libs_replace", "-v2"])
    expect($mystring.include?("-lexlibB -lexlibC -LsearchPathY -LsearchPathZ -l:userlibN -l:userlibO")).to be == true
    expect($mystring.include?("-lexlibA")).to be == false
    expect($mystring.include?("-LsearchPathX")).to be == false
    expect($mystring.include?("-l:userlibM")).to be == false
  end

  it 'Steps extend 0' do
    Bake.startBake("adapt/main", ["test_steps0", "--rebuild", "--adapt", "steps_extend", "-v2"])
    expect($mystring.include?("STARTUP1")).to be == false
    expect($mystring.include?("STARTUP2")).to be == true
    expect($mystring.include?("STARTUP3")).to be == true
    expect($mystring.include?("PRE1")).to be == false
    expect($mystring.include?("PRE2")).to be == true
    expect($mystring.include?("PRE3")).to be == true
    expect($mystring.include?("STEP1")).to be == false
    expect($mystring.include?("STEP2")).to be == true
    expect($mystring.include?("POST1")).to be == false
    expect($mystring.include?("POST2")).to be == true
    expect($mystring.include?("POST3")).to be == true
    expect($mystring.include?("EXIT1")).to be == false
    expect($mystring.include?("EXIT2")).to be == true
    expect($mystring.include?("EXIT3")).to be == true
  end

  it 'Steps extend 2' do
    Bake.startBake("adapt/main", ["test_steps2", "--rebuild", "--adapt",  "steps_extend", "-v2"])
    expect($mystring.include?("STARTUP1")).to be == true
    expect($mystring.include?("STARTUP2")).to be == true
    expect($mystring.include?("STARTUP3")).to be == true
    expect($mystring.include?("PRE1")).to be == true
    expect($mystring.include?("PRE2")).to be == true
    expect($mystring.include?("PRE3")).to be == true
    expect($mystring.include?("STEP1")).to be == false
    expect($mystring.include?("STEP2")).to be == true
    expect($mystring.include?("POST1")).to be == true
    expect($mystring.include?("POST2")).to be == true
    expect($mystring.include?("POST3")).to be == true
    expect($mystring.include?("EXIT1")).to be == true
    expect($mystring.include?("EXIT2")).to be == true
    expect($mystring.include?("EXIT3")).to be == true
  end

  it 'Steps remove 0' do
    Bake.startBake("adapt/main", ["test_steps0", "--rebuild", "--adapt",  "steps_remove", "-v2"])
    expect($mystring.include?("STARTUP1")).to be == false
    expect($mystring.include?("STARTUP2")).to be == false
    expect($mystring.include?("STARTUP3")).to be == false
    expect($mystring.include?("PRE1")).to be == false
    expect($mystring.include?("PRE2")).to be == false
    expect($mystring.include?("PRE3")).to be == false
    expect($mystring.include?("STEP1")).to be == false
    expect($mystring.include?("STEP2")).to be == false
    expect($mystring.include?("POST1")).to be == false
    expect($mystring.include?("POST2")).to be == false
    expect($mystring.include?("POST3")).to be == false
    expect($mystring.include?("EXIT1")).to be == false
    expect($mystring.include?("EXIT2")).to be == false
    expect($mystring.include?("EXIT3")).to be == false
  end

  it 'Steps remove 2' do
    Bake.startBake("adapt/main", ["test_steps2", "--rebuild", "--adapt",  "steps_remove", "-v2"])
    expect($mystring.include?("STARTUP1")).to be == true
    expect($mystring.include?("STARTUP2")).to be == false
    expect($mystring.include?("STARTUP3")).to be == false
    expect($mystring.include?("PRE1")).to be == true
    expect($mystring.include?("PRE2")).to be == false
    expect($mystring.include?("PRE3")).to be == false
    expect($mystring.include?("STEP1")).to be == true
    expect($mystring.include?("STEP2")).to be == false
    expect($mystring.include?("POST1")).to be == true
    expect($mystring.include?("POST2")).to be == false
    expect($mystring.include?("POST3")).to be == false
    expect($mystring.include?("EXIT1")).to be == true
    expect($mystring.include?("EXIT2")).to be == false
    expect($mystring.include?("EXIT3")).to be == false
  end

  it 'Steps remove 2 ok' do
    Bake.startBake("adapt/main", ["test_steps2", "--rebuild", "--adapt",  "steps_remove_ok", "-v2"])
    expect($mystring.include?("STEP1")).to be == false
    expect($mystring.include?("STEP2")).to be == false
  end

  it 'Steps replace 0' do
    Bake.startBake("adapt/main", ["test_steps0", "--rebuild", "--adapt",  "steps_replace", "-v2"])
    expect($mystring.include?("STARTUP1")).to be == false
    expect($mystring.include?("STARTUP2")).to be == true
    expect($mystring.include?("STARTUP3")).to be == true
    expect($mystring.include?("PRE1")).to be == false
    expect($mystring.include?("PRE2")).to be == true
    expect($mystring.include?("PRE3")).to be == true
    expect($mystring.include?("STEP1")).to be == false
    expect($mystring.include?("STEP2")).to be == true
    expect($mystring.include?("POST1")).to be == false
    expect($mystring.include?("POST2")).to be == true
    expect($mystring.include?("POST3")).to be == true
    expect($mystring.include?("EXIT1")).to be == false
    expect($mystring.include?("EXIT2")).to be == true
    expect($mystring.include?("EXIT3")).to be == true
  end

  it 'Steps replace 2' do
    Bake.startBake("adapt/main", ["test_steps2", "--rebuild", "--adapt",  "steps_replace", "-v2"])
    expect($mystring.include?("STARTUP1")).to be == false
    expect($mystring.include?("STARTUP2")).to be == true
    expect($mystring.include?("STARTUP3")).to be == true
    expect($mystring.include?("PRE1")).to be == false
    expect($mystring.include?("PRE2")).to be == true
    expect($mystring.include?("PRE3")).to be == true
    expect($mystring.include?("STEP1")).to be == false
    expect($mystring.include?("STEP2")).to be == true
    expect($mystring.include?("POST1")).to be == false
    expect($mystring.include?("POST2")).to be == true
    expect($mystring.include?("POST3")).to be == true
    expect($mystring.include?("EXIT1")).to be == false
    expect($mystring.include?("EXIT2")).to be == true
    expect($mystring.include?("EXIT3")).to be == true
  end

  it 'Toolchain extend empty 0' do
    Bake.startBake("adapt/main", ["test_tool0", "--rebuild", "--adapt",  "tool_extend_empty", "-v2"])
    expect($mystring.include?("-D")).to be == false
    expect($mystring.include?("-L")).to be == false
  end

  it 'Toolchain extend empty 1' do
    Bake.startBake("adapt/main", ["test_tool1", "--rebuild", "--adapt",  "tool_extend_empty", "-v2"])
    expect($mystring.include?("-D")).to be == false
    expect($mystring.include?("-L")).to be == false
  end

  it 'Toolchain extend empty 2' do
    Bake.startBake("adapt/main", ["test_tool2", "--rebuild", "--adapt",  "tool_extend_empty", "-v2"])
    expect($mystring.include?("-DASMC=3 -DASMD=4 -DASMA=1 -DASMB=2")).to be == true
    expect($mystring.include?("-DCCCC=3 -DCCCD=4 -DCCCA=1 -DCCCB=2")).to be == true
    expect($mystring.include?("-DCPPC=3 -DCPPD=4 -DCPPA=1 -DCPPB=2")).to be == true
    expect($mystring.include?("-LPATHA -LPATHB")).to be == true
    expect($mystring.include?("-LPATHC -LPATHD -LPATHE -LPATHF")).to be == true
  end

  it 'Toolchain extend full 0' do
    Bake.startBake("adapt/main", ["test_tool0", "--rebuild", "--adapt",  "tool_extend_full", "-v2"])
    expect($mystring.include?("-DASMC=30 -DASMD=4 -DASMA=10 -DASMB=2")).to be == true
    expect($mystring.include?("-DCCCC=30 -DCCCD=4 -DCCCA=10 -DCCCB=2")).to be == true
    expect($mystring.include?("-DCPPC=30 -DCPPD=4 -DCPPA=10 -DCPPB=2")).to be == true
    expect($mystring.include?("-LPATHA0 -LPATHB")).to be == true
    expect($mystring.include?("-LPATHC0 -LPATHD -LPATHE0 -LPATHF")).to be == true
  end

  it 'Toolchain extend full 1' do
    Bake.startBake("adapt/main", ["test_tool1", "--rebuild", "--adapt",  "tool_extend_full", "-v2"])
    expect($mystring.include?("-DASMC=30 -DASMD=4 -DASMA=10 -DASMB=2")).to be == true
    expect($mystring.include?("-DCCCC=30 -DCCCD=4 -DCCCA=10 -DCCCB=2")).to be == true
    expect($mystring.include?("-DCPPC=30 -DCPPD=4 -DCPPA=10 -DCPPB=2")).to be == true
    expect($mystring.include?("-LPATHA0 -LPATHB")).to be == true
    expect($mystring.include?("-LPATHC0 -LPATHD -LPATHE0 -LPATHF")).to be == true
  end

  it 'Toolchain extend full 2' do
    Bake.startBake("adapt/main", ["test_tool2", "--rebuild", "--adapt",  "tool_extend_full", "-v2"])
    expect($mystring.include?("-DASMC=3 -DASMD=4 -DASMC=30 -DASMA=1 -DASMB=2 -DASMA=10")).to be == true
    expect($mystring.include?("-DCCCC=3 -DCCCD=4 -DCCCC=30 -DCCCA=1 -DCCCB=2 -DCCCA=10")).to be == true
    expect($mystring.include?("-DCPPC=3 -DCPPD=4 -DCPPC=30 -DCPPA=1 -DCPPB=2 -DCPPA=10")).to be == true
    expect($mystring.include?("-LPATHA -LPATHB -LPATHA0")).to be == true
    expect($mystring.include?("-LPATHC -LPATHD -LPATHC0 -LPATHE -LPATHF -LPATHE0")).to be == true
  end

  it 'Toolchain remove 0' do
    Bake.startBake("adapt/main", ["test_tool0", "--rebuild", "--adapt",  "tool_remove", "-v2"])
    expect($mystring.include?("-D")).to be == false
    expect($mystring.include?("-L")).to be == false
  end

  it 'Toolchain remove 2' do
    Bake.startBake("adapt/main", ["test_tool2", "--rebuild", "--adapt",  "tool_remove", "-v2"])
    expect($mystring.include?("-DCPP")).to be == false
    expect($mystring.include?("-DCCC")).to be == true
    expect($mystring.include?("-DASM")).to be == true
    expect($mystring.include?("-L")).to be == false
  end

  it 'Toolchain replace 0' do
    Bake.startBake("adapt/main", ["test_tool0", "--rebuild", "--adapt",  "tool_replace", "-v2"])
    expect($mystring.include?("-DAAA=100")).to be == true
    expect($mystring.include?("-L")).to be == false
  end

  it 'Toolchain replace 2' do
    Bake.startBake("adapt/main", ["test_tool2", "--rebuild", "--adapt",  "tool_replace", "-v2"])
    expect($mystring.include?("-DAAA=100")).to be == true
    expect($mystring.include?("-L")).to be == false
  end

  it 'DefaultToolchain extend 0' do
    Bake.startBake("adapt/main", ["test_dtool0", "--rebuild", "--adapt",  "dtool_extend", "-v2"])
    expect($mystring.include?("-FLAG10 -FLAG2")).to be == true
    expect($mystring.include?("test_out_new")).to be == true
  end

  it 'DefaultToolchain extend 1' do
    Bake.startBake("adapt/main", ["test_dtool1", "--rebuild", "--adapt",  "dtool_extend", "-v2"])
    expect($mystring.include?("-FLAG10 -FLAG2")).to be == true
    expect($mystring.include?("test_out_new")).to be == true
  end

  it 'DefaultToolchain extend 2' do
    Bake.startBake("adapt/main", ["test_dtool2", "--rebuild", "--adapt",  "dtool_extend", "-v2"])
    expect($mystring.include?("-FLAG1 -FLAG2 -FLAG10")).to be == true
    expect($mystring.include?("test_out_new")).to be == true
  end

  it 'DefaultToolchain remove 0' do
    Bake.startBake("adapt/main", ["test_dtool0", "--rebuild", "--adapt",  "dtool_remove", "-v2"])
    expect($mystring.include?("must contain DefaultToolchain")).to be == true
  end

  it 'DefaultToolchain remove 2' do
    Bake.startBake("adapt/main", ["test_dtool2", "--rebuild", "--adapt",  "dtool_remove", "-v2"])
    expect($mystring.include?("must contain DefaultToolchain")).to be == true
  end

  it 'DefaultToolchain replace 0' do
    Bake.startBake("adapt/main", ["test_dtool0", "--rebuild", "--adapt",  "dtool_replace", "-v2"])
    expect($mystring.include?("-FLAG")).to be == false
    expect($mystring.include?("build/test_dtool0")).to be == true
  end

  it 'DefaultToolchain replace 2' do
    Bake.startBake("adapt/main", ["test_dtool2", "--rebuild", "--adapt",  "dtool_replace", "-v2"])
    expect($mystring.include?("-FLAG")).to be == false
    expect($mystring.include?("build/test_dtool2")).to be == true
  end


  it 'Docu extend 0' do
    Bake.startBake("adapt/main", ["test_dtool0", "--rebuild", "--adapt",  "dtool_extend", "-v2", "--docu"])
    expect($mystring.include?("DOCUCMD_new")).to be == true
  end

  it 'Docu extend 2' do
    Bake.startBake("adapt/main", ["test_dtool2", "--rebuild", "--adapt",  "dtool_extend", "-v2", "--docu"])
    expect($mystring.include?("DOCUCMD_new")).to be == true
  end

  it 'EclipseOrder none-none' do
    Bake.startBake("adapt/main", ["test_eclNone", "--rebuild", "--adapt",  "ecl_none", "-v2", "--threads", "1"])
    expect($mystring.index("add1.cpp")).to be > $mystring.index("main.cpp")
  end
  it 'EclipseOrder none-false' do
    Bake.startBake("adapt/main", ["test_eclNone", "--rebuild", "--adapt",  "ecl_false", "-v2", "--threads", "1"])
    expect($mystring.index("add1.cpp")).to be > $mystring.index("main.cpp")
  end
  it 'EclipseOrder none-true' do
    Bake.startBake("adapt/main", ["test_eclNone", "--rebuild", "--adapt",  "ecl_true", "-v2", "--threads", "1"])
    expect($mystring.index("add1.cpp")).to be < $mystring.index("main.cpp")
  end
  it 'EclipseOrder false-none' do
    Bake.startBake("adapt/main", ["test_eclFalse", "--rebuild", "--adapt",  "ecl_none", "-v2", "--threads", "1"])
    expect($mystring.index("add1.cpp")).to be > $mystring.index("main.cpp")
  end
  it 'EclipseOrder false-false' do
    Bake.startBake("adapt/main", ["test_eclFalse", "--rebuild", "--adapt",  "ecl_false", "-v2", "--threads", "1"])
    expect($mystring.index("add1.cpp")).to be > $mystring.index("main.cpp")
  end
  it 'EclipseOrder false-true' do
    Bake.startBake("adapt/main", ["test_eclFalse", "--rebuild", "--adapt",  "ecl_true", "-v2", "--threads", "1"])
    expect($mystring.index("add1.cpp")).to be < $mystring.index("main.cpp")
  end
  it 'EclipseOrder true-none' do
    Bake.startBake("adapt/main", ["test_eclTrue", "--rebuild", "--adapt",  "ecl_none", "-v2", "--threads", "1"])
    expect($mystring.index("add1.cpp")).to be < $mystring.index("main.cpp")
  end
  it 'EclipseOrder true-false' do
    Bake.startBake("adapt/main", ["test_eclTrue", "--rebuild", "--adapt",  "ecl_false", "-v2", "--threads", "1"])
    expect($mystring.index("add1.cpp")).to be > $mystring.index("main.cpp")
  end
  it 'EclipseOrder true-true' do
    Bake.startBake("adapt/main", ["test_eclTrue", "--rebuild", "--adapt",  "ecl_true", "-v2", "--threads", "1"])
    expect($mystring.index("add1.cpp")).to be < $mystring.index("main.cpp")
  end

  it 'Lint extend 1' do
    Bake.startBake("adapt/main", ["test_dtool1", "--rebuild", "--adapt",  "dtool_extend", "-v2", "--lint"])
    expect($mystring.include?("LINT_POL10 LINT_POL2")).to be == true
    expect($mystring.include?("LINT_POL1 ")).to be == false
  end

  it 'Lint extend 2' do
    Bake.startBake("adapt/main", ["test_dtool2", "--rebuild", "--adapt",  "dtool_extend", "-v2", "--lint"])
    expect($mystring.include?("LINT_POL1 LINT_POL2 LINT_POL10 LINT_POL2")).to be == true
  end

  it 'Lint replace 2' do
    Bake.startBake("adapt/main", ["test_dtool2", "--rebuild", "--adapt",  "dtool_replace", "-v2", "--lint"])
    expect($mystring.include?("LINT_POL3")).to be == true
    expect($mystring.include?("LINT_POL2")).to be == false
  end

  it 'BasedOn new' do
    Bake.startBake("adapt/main", ["test_dtool1", "--rebuild", "--adapt",  "based_new", "-v2"])
    expect($mystring.include?("dcc")).to be == true
  end

  it 'BasedOn none' do
    Bake.startBake("adapt/main", ["test_dtool1", "--rebuild", "--adapt",  "based_none", "-v2"])
    expect($mystring.include?("g++")).to be == true
    expect($mystring.include?("XX=YY")).to be == true
  end

  it 'Scope main_main main,test_scope_main' do
    Bake.startBake("adapt/main", ["test_scope_main", "--rebuild", "--adapt",  "scope_main_main", "-v2", "-p", "main,test_scope_main"])
    expect($mystring.include?("A=1")).to be == true
  end
  it 'Scope main_main main,test_scope_lib' do
    Bake.startBake("adapt/main", ["test_scope_main", "--rebuild", "--adapt",  "scope_main_main", "-v2", "-p", "main,test_scope_lib"])
    expect($mystring.include?("A=1")).to be == false
  end
  it 'Scope main_main lib1,test_ok' do
    Bake.startBake("adapt/main", ["test_scope_main", "--rebuild", "--adapt",  "scope_main_main", "-v2", "-p", "lib1,test_ok"])
    expect($mystring.include?("A=1")).to be == false
  end
  it 'Scope main_main lib1,test_other' do
    Bake.startBake("adapt/main", ["test_scope_main", "--rebuild", "--adapt",  "scope_main_main", "-v2", "-p", "lib1,test_other"])
    expect($mystring.include?("A=1")).to be == false
  end
  it 'Scope main_main lib2' do
    Bake.startBake("adapt/main", ["test_scope_main", "--rebuild", "--adapt",  "scope_main_main", "-v2", "-p", "lib2"])
    expect($mystring.include?("A=1")).to be == false
  end

  it 'Scope all_all main,test_scope_main' do
    Bake.startBake("adapt/main", ["test_scope_main", "--rebuild", "--adapt",  "scope_all_all", "-v2", "-p", "main,test_scope_main"])
    expect($mystring.include?("A=1")).to be == true
  end

  it 'Scope all_all main,test_scope_lib' do
    Bake.startBake("adapt/main", ["test_scope_main", "--rebuild", "--adapt",  "scope_all_all", "-v2", "-p", "main,test_scope_lib"])
    expect($mystring.include?("A=1")).to be == true
  end

  it 'Scope all_all lib1,test_ok' do
    Bake.startBake("adapt/main", ["test_scope_main", "--rebuild", "--adapt",  "scope_all_all", "-v2", "-p", "lib1,test_ok"])
    expect($mystring.include?("A=1")).to be == true
  end
  it 'Scope all_all lib1,test_other' do
    Bake.startBake("adapt/main", ["test_scope_main", "--rebuild", "--adapt",  "scope_all_all", "-v2", "-p", "lib1,test_other"])
    expect($mystring.include?("A=1")).to be == true
  end
  it 'Scope all_all lib2' do
    Bake.startBake("adapt/main", ["test_scope_main", "--rebuild", "--adapt",  "scope_all_all", "-v2", "-p", "lib2"])
    expect($mystring.include?("A=1")).to be == true
  end

  it 'Scope all_lib1 main,test_scope_main' do
    Bake.startBake("adapt/main", ["test_scope_main", "--rebuild", "--adapt",  "scope_all_lib1", "-v2", "-p", "main,test_scope_main"])
    expect($mystring.include?("A=1")).to be == false
  end
  it 'Scope all_lib1 main,test_scope_lib' do
    Bake.startBake("adapt/main", ["test_scope_main", "--rebuild", "--adapt",  "scope_all_lib1", "-v2", "-p", "main,test_scope_lib"])
    expect($mystring.include?("A=1")).to be == false
  end
  it 'Scope all_lib1 lib1,test_ok' do
    Bake.startBake("adapt/main", ["test_scope_main", "--rebuild", "--adapt",  "scope_all_lib1", "-v2", "-p", "lib1,test_ok"])
    expect($mystring.include?("A=1")).to be == true
  end
  it 'Scope all_lib1 lib1,test_other' do
    Bake.startBake("adapt/main", ["test_scope_main", "--rebuild", "--adapt",  "scope_all_lib1", "-v2", "-p", "lib1,test_other"])
    expect($mystring.include?("A=1")).to be == true
  end
  it 'Scope all_lib1 lib2' do
    Bake.startBake("adapt/main", ["test_scope_main", "--rebuild", "--adapt",  "scope_all_lib1", "-v2", "-p", "lib2"])
    expect($mystring.include?("A=1")).to be == false
  end

  it 'Scope testok_lib1 main,test_scope_main' do
    Bake.startBake("adapt/main", ["test_scope_main", "--rebuild", "--adapt",  "scope_testok_lib1", "-v2", "-p", "main,test_scope_main"])
    expect($mystring.include?("A=1")).to be == false
  end
  it 'Scope testok_lib1 main,test_scope_lib' do
    Bake.startBake("adapt/main", ["test_scope_main", "--rebuild", "--adapt",  "scope_testok_lib1", "-v2", "-p", "main,test_scope_lib"])
    expect($mystring.include?("A=1")).to be == false
  end
  it 'Scope testok_lib1 lib1,test_ok' do
    Bake.startBake("adapt/main", ["test_scope_main", "--rebuild", "--adapt",  "scope_testok_lib1", "-v2", "-p", "lib1,test_ok"])
    expect($mystring.include?("A=1")).to be == true
  end
  it 'Scope testok_lib1 lib1,test_other' do
    Bake.startBake("adapt/main", ["test_scope_main", "--rebuild", "--adapt",  "scope_testok_lib1", "-v2", "-p", "lib1,test_other"])
    expect($mystring.include?("A=1")).to be == false
  end
  it 'Scope testok_lib1 lib2' do
    Bake.startBake("adapt/main", ["test_scope_main", "--rebuild", "--adapt",  "scope_testok_lib1", "-v2", "-p", "lib2"])
    expect($mystring.include?("A=1")).to be == false
  end

  it 'Scope testok_all main,test_scope_main' do
    Bake.startBake("adapt/main", ["test_scope_main", "--rebuild", "--adapt",  "scope_testok_all", "-v2", "-p", "main,test_scope_main"])
    expect($mystring.include?("A=1")).to be == false
  end
  it 'Scope testok_all main,test_scope_lib' do
    Bake.startBake("adapt/main", ["test_scope_main", "--rebuild", "--adapt",  "scope_testok_all", "-v2", "-p", "main,test_scope_lib"])
    expect($mystring.include?("A=1")).to be == false
  end
  it 'Scope testok_all lib1,test_ok' do
    Bake.startBake("adapt/main", ["test_scope_main", "--rebuild", "--adapt",  "scope_testok_all", "-v2", "-p", "lib1,test_ok"])
    expect($mystring.include?("A=1")).to be == true
  end
  it 'Scope testok_all lib1,test_other' do
    Bake.startBake("adapt/main", ["test_scope_main", "--rebuild", "--adapt",  "scope_testok_all", "-v2", "-p", "lib1,test_other"])
    expect($mystring.include?("A=1")).to be == false
  end
  it 'Scope testok_all lib2' do
    Bake.startBake("adapt/main", ["test_scope_main", "--rebuild", "--adapt",  "scope_testok_all", "-v2", "-p", "lib2"])
    expect($mystring.include?("A=1")).to be == true
  end

  it 'Scope testscopemain_realmain main,test_scope_main' do
    Bake.startBake("adapt/main", ["test_scope_main", "--rebuild", "--adapt",  "scope_testscopemain_realmain", "-v2", "-p", "main,test_scope_main"])
    expect($mystring.include?("A=1")).to be == true
  end
  it 'Scope testscopemain_realmain main,test_scope_lib' do
    Bake.startBake("adapt/main", ["test_scope_main", "--rebuild", "--adapt",  "scope_testscopemain_realmain", "-v2", "-p", "main,test_scope_lib"])
    expect($mystring.include?("A=1")).to be == false
  end
  it 'Scope testscopemain_realmain lib1,test_ok' do
    Bake.startBake("adapt/main", ["test_scope_main", "--rebuild", "--adapt",  "scope_testscopemain_realmain", "-v2", "-p", "lib1,test_ok"])
    expect($mystring.include?("A=1")).to be == false
  end
  it 'Scope testscopemain_realmain lib1,test_other' do
    Bake.startBake("adapt/main", ["test_scope_main", "--rebuild", "--adapt",  "scope_testscopemain_realmain", "-v2", "-p", "lib1,test_other"])
    expect($mystring.include?("A=1")).to be == false
  end
  it 'Scope testscopemain_realmain lib2' do
    Bake.startBake("adapt/main", ["test_scope_main", "--rebuild", "--adapt",  "scope_testscopemain_realmain", "-v2", "-p", "lib2"])
    expect($mystring.include?("A=1")).to be == false
  end



  it 'Cascade configs testscopemain_realmain lib2' do
    Bake.startBake("adapt/main", ["test_casca", "--rebuild", "--adapt",  "cascade", "-v2"])
    expect($mystring.include?("Building 1 of 2: lib2 (test_ok)")).to be == true
    expect($mystring.include?("Building 2 of 2: main (test_casca)")).to be == true
    expect($mystring.include?("nix.cpp")).to be == false
    expect($mystring.include?("add1.cpp")).to be == true
    expect($mystring.include?("add2.cpp")).to be == true
    expect($mystring.include?("main.cpp")).to be == true
    expect($mystring.include?("A=1")).to be == true
    expect($mystring.include?("Rebuilding done")).to be == true
  end


  it 'Find adapt file multiple times' do
    Bake.startBake("adapt/main", ["test_multi", "--adapt",  "multi", "-v2"])
    expect($mystring.include?("Adaption project multi exists more than once")).to be == true
    expect($mystring.include?("Building done")).to be == true
    expect($mystring.include?("adapt/multiple/1/multi (chosen)")).to be == true
    expect($mystring.include?("adapt/adapt/multiple/2/multi")).to be == true
  end

  it 'Find adapt file no times' do
    Bake.startBake("adapt/main", ["test_multi", "--adapt",  "doesNotExist", "-v2"])
    expect($mystring.include?("Adaption project doesNotExist not found")).to be == true
    expect($mystring.include?("Building failed")).to be == true
  end

  it 'Touch adapt' do
    Bake.startBake("adapt/main", ["test_dep0", "--adapt", "dep_extend", "-v3"])
    $mystring.clear
    Bake.startBake("adapt/main", ["test_dep0", "--adapt", "dep_extend", "-v3"])
    expect($mystring.include?("dep_extend/Adapt.meta has been changed, reloading meta information")).to be == false
    $mystring.clear
    sleep 2.1
    FileUtils.touch("spec/testdata/adapt/adapt/dep/dep_extend/Adapt.meta")
    Bake.startBake("adapt/main", ["test_dep0", "--adapt", "dep_extend", "-v3"])
    expect($mystring.include?("dep_extend/Adapt.meta has been changed, reloading meta information")).to be == true
  end

  it 'adapt filename changed' do
    Bake.startBake("adapt/main", ["test_dep0", "-v3"])
    $mystring.clear
    Bake.startBake("adapt/main", ["test_dep0", "--adapt", "dep_extend", "-v3"])
    expect($mystring.include?("adapt config filenames have been changed, reloading meta information")).to be == true
    $mystring.clear
    Bake.startBake("adapt/main", ["test_dep0", "--adapt", "dep_extend", "-v3"])
    expect($mystring.include?("adapt config filenames have been changed, reloading meta information")).to be == false
    $mystring.clear
    Bake.startBake("adapt/main", ["test_dep0", "--adapt", "dep_remove", "-v3"])
    expect($mystring.include?("adapt config filenames have been changed, reloading meta information")).to be == true
    $mystring.clear
    Bake.startBake("adapt/main", ["test_dep0", "--adapt", "dep_remove", "-v3"])
    expect($mystring.include?("adapt config filenames have been changed, reloading meta information")).to be == false
    $mystring.clear
    Bake.startBake("adapt/main", ["test_dep0", "-v3"])
    expect($mystring.include?("adapt config filenames have been changed, reloading meta information")).to be == true
    $mystring.clear
    Bake.startBake("adapt/main", ["test_dep0", "-v3"])
    expect($mystring.include?("adapt config filename has been changed, reloading meta information")).to be == false
  end

  it 'adapt filename changed' do
    Bake.startBake("adaptPath/a", ["test", "--adapt", "b"])
    pos1 = $mystring.index("part1")
    pos2 = $mystring.index("adaptPath/a",pos1)
    pos3 = $mystring.index("part2",pos2)
    expect(0   <pos1).to be == true
    expect(pos1<pos2).to be == true
    expect(pos2<pos3).to be == true
  end

end

end
