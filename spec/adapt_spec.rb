#!/usr/bin/env ruby

require 'common/version'

require 'bake/options/options'
require 'bake/util'
require 'common/exit_helper'
require 'socket'
require 'fileutils'
require 'helper'

module Bake

  # todo: timestand adapt file
  # scope __MAIN__ etc...
  # mehrere kaskadiert
  # docu fix von syntax popup diag
  # adapt filename in cache -> wenn anders, dann neu einlesen  - achtung test lösche cache immer...
  # adapt filename nicht gefunden, mehrmals...
  # docu order of compileld files
  
describe "Adapt" do

  it 'Dep extend 0' do
    Bake.startBake("adapt/main", ["test_dep0", "--rebuild", "--adapt", "dep_extend"])
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
    expect($mystring.include?("main.exe")).to be == true
    expect($mystring.include?("Rebuilding done.")).to be == true
  end   
  
  it 'ArtifactName remove 1 ok' do
    Bake.startBake("adapt/main", ["test_art1", "--rebuild", "-v2", "--adapt", "art_remove_ok"])
    expect($mystring.include?("main.exe")).to be == true
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
    Bake.startBake("adapt/main", ["test_lin0", "--rebuild", "-v2", "--adapt", "lin_extend"])
    expect($mystring.include?("linkerscript2.dld")).to be == true
    expect($mystring.include?("Rebuilding done.")).to be == true
  end   
  
  it 'LinkerScript extend 1' do
    Bake.startBake("adapt/main", ["test_lin1", "--rebuild", "-v2", "--adapt", "lin_extend"])
    expect($mystring.include?("linkerscript2.dld")).to be == true
    expect($mystring.include?("Rebuilding done.")).to be == true
  end   
  
  it 'LinkerScript remove 0' do
    Bake.startBake("adapt/main", ["test_lin0", "--rebuild", "-v2", "--adapt", "lin_remove_ok"])
    expect($mystring.include?(".dld")).to be == false
    expect($mystring.include?("Rebuilding done.")).to be == true
  end   
  
  it 'LinkerScript remove 1 ok' do
    Bake.startBake("adapt/main", ["test_lin1", "--rebuild", "-v2", "--adapt", "lin_remove_ok"])
    expect($mystring.include?(".dld")).to be == false
    expect($mystring.include?("Rebuilding done.")).to be == true
  end   
  
  it 'LinkerScript remove 1 nok' do
    Bake.startBake("adapt/main", ["test_lin1", "--rebuild", "-v2", "--adapt", "lin_remove_nok"])
    expect($mystring.include?("linkerscript1.dld")).to be == true
    expect($mystring.include?("Rebuilding done.")).to be == true
  end 
   
  it 'LinkerScript replace 0' do
    Bake.startBake("adapt/main", ["test_lin0", "--rebuild", "-v2", "--adapt", "lin_replace"])
    expect($mystring.include?("linkerscript2.dld")).to be == true
    expect($mystring.include?("Rebuilding done.")).to be == true
  end   
  
  it 'LinkerScript replace 1' do
    Bake.startBake("adapt/main", ["test_lin1", "--rebuild", "-v2", "--adapt", "lin_replace"])
    expect($mystring.include?("linkerscript2.dld")).to be == true
    expect($mystring.include?("Rebuilding done.")).to be == true
  end  
  
  it 'Files extend 0' do
    Bake.startBake("adapt/main", ["test_files0", "--rebuild", "--adapt", "files_extend", "--threads", "1"])
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
    Bake.startBake("adapt/main", ["test_files0", "--rebuild", "--adapt", "files_replace", "--threads", "1"])
    expect($mystring.include?("add1.cpp")).to be == true
    expect($mystring.include?("nix.cpp")).to be == true
    expect($mystring.include?("main.cpp")).to be == false
    expect($mystring.index("add1.cpp")).to be < $mystring.index("nix.cpp")
  end  
 
  it 'Files replace 2' do
    Bake.startBake("adapt/main", ["test_files2", "--rebuild", "--adapt", "files_replace", "--threads", "1"])
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

  #toReplace = [ :toolchain, :defaultToolchain]

end

end
