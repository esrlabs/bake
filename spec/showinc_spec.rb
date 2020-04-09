#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'

module Bake


  incsTestStr1 = " includes\n"+
      "  A/include\n"+
      "  ../sub/include\n"+
      "  subst\n"+
      "  incluuude\n"+
      "  C:\\gaga\n"+
      " CPP defines\n"+
      " C defines\n"+
      "  A=1\n"+
      "  UNITTEST\n"+
      "  X=Y\n"+
      "  blah\n"+
      "  toll\n"+
      " ASM defines\n"+
      " done\n"
  incsTestStr2 = " includes\n"+
      "  include\n"+
      "  incluuude\n"+
      "  C:\\gaga\n"+
      " CPP defines\n"+
      "  GAGA\n"+
      " C defines\n"+
      "  A=1\n"+
      "  UNITTEST\n"+
      "  HOSSA\n"+
      "  X=Y\n"+
      "  blah\n"+
      "  toll\n"+
      " ASM defines\n"+
      " done"

describe "ShowInc" do

  it 'Default' do
    Bake.startBake("showinc/main", ["test", "--show_incs_and_defs"])
    expect($mystring.include?(incsTestStr1)).to be == true
    expect($mystring.include?(incsTestStr2)).to be == true
  end

  it 'Bake' do
    Bake.startBake("showinc/main", ["test", "--incs-and-defs=bake"])
    expect($mystring.include?(incsTestStr1)).to be == true
    expect($mystring.include?(incsTestStr2)).to be == true
  end

  it 'Json' do
    Bake.startBake("showinc/main", ["test", "--incs-and-defs=json"])
    hash = JSON.parse($mystring[$mystring.index("{")..-1]) # substring needed because rspec consumes output in higher prio than bake suppressions (which is intended)
    h = hash["main"]
    expect(h["includes"].include?"A/include").to be == true
    expect(h["includes"].include?"../sub/include").to be == true
    expect(h["includes"].include?"A/include").to be == true
    h = hash["sub"]
    expect(h["cpp_defines"].include?"GAGA").to be == true
  end

  it 'Vars' do
    Bake.startBake("showinc/main", ["testVar", "--incs-and-defs"])
    expect($mystring.match(/\/.+\/\.\.\/include1/).nil?).to be == false
    expect($mystring.match(/\/.+\/\.\.\/include2/).nil?).to be == false
    expect($mystring.match(/\/.+\/\.\.\/include3/).nil?).to be == false
    expect($mystring.match(/\/.+\/\.\.\/include4/).nil?).to be == false
    expect($mystring.match(/\/.+\/\.\.\/include5/).nil?).to be == false
  end

  it 'compilation-db without parameter' do
    Bake.startBake("simple/main", ["test_ok", "--compilation-db"])
    f = File.read('compile_commands.json')
    ar = JSON.parse(f)
    expect(ar.length).to be == 3
    ar.each do |a|
      case a['file']
      when 'src/z.cpp'
        expect(a["directory"].include?"spec/testdata/simple/lib").to be == true
        expect(a["command"].include?"-c -MD -MF build/test_ok_main_test_ok/src/z.d -DDEF1 -o build/test_ok_main_test_ok/src/z.o src/z.cpp").to be == true
      when 'src/y.cpp'
        expect(a["directory"].include?"spec/testdata/simple/lib").to be == true
        expect(a["command"].include?"-c -MD -MF build/test_ok_main_test_ok/src/y.d -DDEF1 -o build/test_ok_main_test_ok/src/y.o src/y.cpp").to be == true
      else
        expect(a['file']).to be == 'src/x.cpp'
        expect(a["directory"].include?"spec/testdata/simple/main").to be == true
        expect(a["command"].include?"-c -MD -MF build/test_ok/src/x.d -DDEF1 -o build/test_ok/src/x.o src/x.cpp").to be == true
      end
    end
  end

  it 'compilation-db without parameter, using absolute paths' do
    Bake.startBake("simple/main", ["test_ok", "--compilation-db", "--abs-paths"])
    f = File.read('compile_commands.json')
    ar = JSON.parse(f)
    expect(ar.length).to be == 3
    ar.each do |cmd|
      fileName = File.basename(cmd['file'])
      expect(cmd['file']).to be == "#{cmd['directory']}/src/#{fileName}"
      expect(cmd['command'].include?"#{cmd['directory']}/src/#{fileName}").to be == true
    end
  end

  it 'compilation-db with parameter' do
    Bake.startBake("simple/main", ["test_ok", "--compilation-db", "tmp.json"])
    f = File.read('tmp.json')
    ar = JSON.parse(f)
    expect(ar.length).to be == 3
  end

  it 'compilation-db escaping flags' do
    Bake.startBake("quoteCompileCommandsDb/main", ["--compilation-db"])
    f = File.read('compile_commands.json')
    ar = JSON.parse(f)
    expect(ar.any? { |cmds| cmds["command"].include?("-DIOSTREAM=\\\"iostream\\\"") }).to be == true
  end

  it 'cdb in meta none without cmd arg' do
    expect(Dir.glob('**/*.json').length).to be == 0
    Bake.startBake("cdb/main", ["test_none"])
    expect(Dir.glob('**/*.json').length).to be == 0
  end

  it 'cdb in meta default without cmd arg' do
    expect(Dir.glob('**/*.json').length).to be == 0
    Bake.startBake("cdb/main", ["test_default"])
    expect(File.exist?('compile_commands.json')).to be == true
  end

  it 'cdb in meta working dir without cmd arg' do
    expect(Dir.glob('**/*.json').length).to be == 0
    Bake.startBake("cdb/main", ["test_wd"])
    expect(File.exist?('cdb.json')).to be == true
  end

  it 'cdb in meta output dir without cmd arg' do
    expect(Dir.glob('**/*.json').length).to be == 0
    Bake.startBake("cdb/main", ["test_od"])
    expect(File.exist?('spec/testdata/cdb/main/build/test_od/cdb.json')).to be == true
  end

  it 'cdb in meta project dir without cmd arg' do
    expect(Dir.glob('**/*.json').length).to be == 0
    Bake.startBake("cdb/main", ["test_pd"])
    expect(File.exist?('spec/testdata/cdb/main/cdb.json')).to be == true
  end

  it 'cdb in meta project dir with cmd arg' do
    expect(Dir.glob('**/*.json').length).to be == 0
    Bake.startBake("cdb/main", ["test_pd", "--compilation-db", "test.json"])
    expect(File.exist?('spec/testdata/cdb/main/cdb.json')).to be == false
    expect(File.exist?('test.json')).to be == true
  end

end


end
