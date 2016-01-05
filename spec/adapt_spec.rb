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
  
describe "Adapt" do
=begin
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
=end   
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
  
end

end
