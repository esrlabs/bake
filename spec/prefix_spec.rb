#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'

module Bake

describe "Prefix" do

  it 'build' do
    Bake.startBake("prefix/main", ["test_main", "--dry", "-v2", "--adapt", "prefix"])
    expect($mystring.split("echo CPPPREFIX g++").length).to be == 2
    expect($mystring.split("echo ARCHIVERPREFIX ar").length).to be == 2
    expect($mystring.split("echo LINKERPREFIX g++").length).to be == 2
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'prio1' do
    Bake.startBake("prefix/main", ["test_main_prio1", "--dry", "-v2"])
    expect($mystring.include?("CPPCOMPILERPREFIX1")).to be == true
    expect($mystring.include?("CCOMPILERPREFIX1")).to be == true
    expect($mystring.include?("ASMCOMPILERPREFIX1")).to be == true
    expect($mystring.include?("ARCHIVERPREFIX1")).to be == true
    expect($mystring.include?("LINKERPREFIX1")).to be == true
    
    expect($mystring.include?("CPPCOMPILERPREFIX2")).to be == false
    expect($mystring.include?("CCOMPILERPREFIX2")).to be == false
    expect($mystring.include?("ASMCOMPILERPREFIX2")).to be == false
    expect($mystring.include?("ARCHIVERPREFIX2")).to be == false
    expect($mystring.include?("LINKERPREFIX2")).to be == false

    expect($mystring.include?("COMPILERPREFIX3")).to be == false
    
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'prio2' do
    Bake.startBake("prefix/main", ["test_main_prio2", "--dry", "-v2"])
    expect($mystring.include?("CPPCOMPILERPREFIX1")).to be == false
    expect($mystring.include?("CCOMPILERPREFIX1")).to be == false
    expect($mystring.include?("ASMCOMPILERPREFIX1")).to be == false
    expect($mystring.include?("ARCHIVERPREFIX1")).to be == false
    expect($mystring.include?("LINKERPREFIX1")).to be == false
    
    expect($mystring.include?("CPPCOMPILERPREFIX2")).to be == true
    expect($mystring.include?("CCOMPILERPREFIX2")).to be == true
    expect($mystring.include?("ASMCOMPILERPREFIX2")).to be == true
    expect($mystring.include?("ARCHIVERPREFIX2")).to be == true
    expect($mystring.include?("LINKERPREFIX2")).to be == true

    expect($mystring.include?("COMPILERPREFIX3")).to be == false
    
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'prio3' do
    Bake.startBake("prefix/main", ["test_main_prio3", "--dry", "-v2"])
    expect($mystring.include?("CPPCOMPILERPREFIX1")).to be == false
    expect($mystring.include?("CCOMPILERPREFIX1")).to be == false
    expect($mystring.include?("ASMCOMPILERPREFIX1")).to be == false
    expect($mystring.include?("ARCHIVERPREFIX1")).to be == false
    expect($mystring.include?("LINKERPREFIX1")).to be == false
    
    expect($mystring.include?("CPPCOMPILERPREFIX2")).to be == false
    expect($mystring.include?("CCOMPILERPREFIX2")).to be == false
    expect($mystring.include?("ASMCOMPILERPREFIX2")).to be == false
    expect($mystring.include?("ARCHIVERPREFIX2")).to be == false
    expect($mystring.include?("LINKERPREFIX2")).to be == false

    expect($mystring.include?("COMPILERPREFIX3")).to be == true
    
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'prio1_env' do
    ENV["CPPCompilerPrefix"] = "CPPCOMPILERPREFIX2"
    ENV["CCompilerPrefix"] = "CCOMPILERPREFIX2"
    ENV["ASMCompilerPrefix"] = "ASMCOMPILERPREFIX2"
    ENV["ArchiverPrefix"] = "ARCHIVERPREFIX2"
    ENV["LinkerPrefix"] = "LINKERPREFIX2"
    ENV["CompilerPrefix"] = "COMPILERPREFIX3"
    Bake.startBake("prefix/main", ["test_main_prio1_env", "--dry", "-v2"])
    ENV["CPPCompilerPrefix"] = nil
    ENV["CCompilerPrefix"] = nil
    ENV["ASMCompilerPrefix"] = nil
    ENV["ArchiverPrefix"] = nil
    ENV["LinkerPrefix"] = nil
    ENV["CompilerPrefix"] = nil

    expect($mystring.include?("CPPCOMPILERPREFIX1")).to be == true
    expect($mystring.include?("CCOMPILERPREFIX1")).to be == true
    expect($mystring.include?("ASMCOMPILERPREFIX1")).to be == true
    expect($mystring.include?("ARCHIVERPREFIX1")).to be == true
    expect($mystring.include?("LINKERPREFIX1")).to be == true
    
    expect($mystring.include?("CPPCOMPILERPREFIX2")).to be == false
    expect($mystring.include?("CCOMPILERPREFIX2")).to be == false
    expect($mystring.include?("ASMCOMPILERPREFIX2")).to be == false
    expect($mystring.include?("ARCHIVERPREFIX2")).to be == false
    expect($mystring.include?("LINKERPREFIX2")).to be == false

    expect($mystring.include?("COMPILERPREFIX3")).to be == false
    
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'prio2_env' do
    ENV["CPPCompilerPrefix"] = "CPPCOMPILERPREFIX2"
    ENV["CCompilerPrefix"] = "CCOMPILERPREFIX2"
    ENV["ASMCompilerPrefix"] = "ASMCOMPILERPREFIX2"
    ENV["ArchiverPrefix"] = "ARCHIVERPREFIX2"
    ENV["LinkerPrefix"] = "LINKERPREFIX2"
    ENV["CompilerPrefix"] = "COMPILERPREFIX3"
    Bake.startBake("prefix/main", ["test_main_prio2_env", "--dry", "-v2"])
    ENV["CPPCompilerPrefix"] = nil
    ENV["CCompilerPrefix"] = nil
    ENV["ASMCompilerPrefix"] = nil
    ENV["ArchiverPrefix"] = nil
    ENV["LinkerPrefix"] = nil
    ENV["CompilerPrefix"] = nil
    
    expect($mystring.include?("CPPCOMPILERPREFIX1")).to be == false
    expect($mystring.include?("CCOMPILERPREFIX1")).to be == false
    expect($mystring.include?("ASMCOMPILERPREFIX1")).to be == false
    expect($mystring.include?("ARCHIVERPREFIX1")).to be == false
    expect($mystring.include?("LINKERPREFIX1")).to be == false
    
    expect($mystring.include?("CPPCOMPILERPREFIX2")).to be == true
    expect($mystring.include?("CCOMPILERPREFIX2")).to be == true
    expect($mystring.include?("ASMCOMPILERPREFIX2")).to be == true
    expect($mystring.include?("ARCHIVERPREFIX2")).to be == true
    expect($mystring.include?("LINKERPREFIX2")).to be == true

    expect($mystring.include?("COMPILERPREFIX3")).to be == false
    
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'prio3_env' do
    ENV["CompilerPrefix"] = "COMPILERPREFIX3"
    Bake.startBake("prefix/main", ["test_main_prio3_env", "--dry", "-v2"])
    ENV["CompilerPrefix"] = nil

    expect($mystring.include?("CPPCOMPILERPREFIX1")).to be == false
    expect($mystring.include?("CCOMPILERPREFIX1")).to be == false
    expect($mystring.include?("ASMCOMPILERPREFIX1")).to be == false
    expect($mystring.include?("ARCHIVERPREFIX1")).to be == false
    expect($mystring.include?("LINKERPREFIX1")).to be == false
    
    expect($mystring.include?("CPPCOMPILERPREFIX2")).to be == false
    expect($mystring.include?("CCOMPILERPREFIX2")).to be == false
    expect($mystring.include?("ASMCOMPILERPREFIX2")).to be == false
    expect($mystring.include?("ARCHIVERPREFIX2")).to be == false
    expect($mystring.include?("LINKERPREFIX2")).to be == false

    expect($mystring.include?("COMPILERPREFIX3")).to be == true
    
    expect(ExitHelper.exit_code).to be == 0
  end

end

end
