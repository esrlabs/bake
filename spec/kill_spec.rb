#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'

module Bake

  def self.startKillTest(config, test)
    serverSocket = TCPServer.new('localhost', 10000)

    Bake.options = Options.new(["-m", "spec/testdata/kill/main", config, "--socket", "10000", "-j", "2"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.connect()

    clientSocket = serverSocket.accept
    test.expect(clientSocket.nil?).to test.be == false

    t = Thread.new {
      sleep 5
      clientSocket.send("X",0) # triggers abort
    }

    tocxx.doit
    sleep 1

    test.expect(Bake::IDEInterface.instance.get_abort).to test.be == true
    tocxx.disconnect()

    t.join

    serverSocket.close

    test.expect($mystring.include?"lib1 (#{config})").to test.be == true
    test.expect($mystring.include?"lib2 (dummy)").to test.be == false
    test.expect($mystring.include?"main (#{config})").to test.be == false


    test.expect($mystring.include?"STEP1").to test.be == true
    test.expect($mystring.include?"STEP2").to test.be == false

    test.expect($mystring.include?"aborted").to test.be == true
  end

describe "Kill process" do
  it 'preCmd' do
    Bake.startKillTest("testPreCmd", self)

    expect($mystring.include?"FIRST").to be == true
    expect($mystring.include?"first").to be == true
    expect($mystring.include?"SECOND").to be == false
    expect($mystring.include?"second").to be == false
    expect(File.exist?"spec/testdata/kill/timestamp").to be == false
  end

  it 'preMake' do
    Bake.startKillTest("testPreMake", self)

    expect($mystring.include?"MAKE1").to be == true
    expect($mystring.include?"MAKEERROR1").to be == true
    expect($mystring.include?"MAKE2").to be == false
    expect($mystring.include?"MAKEERROR2").to be == false
  end

  it 'Cmd' do
    Bake.startKillTest("testCmd", self)

    expect($mystring.include?"FIRST").to be == true
    expect($mystring.include?"first").to be == true
    expect($mystring.include?"SECOND").to be == false
    expect($mystring.include?"second").to be == false
    expect(File.exist?"spec/testdata/kill/timestamp").to be == false
  end

  it 'Make' do
    Bake.startKillTest("testMake", self)

    expect($mystring.include?"MAKE1").to be == true
    expect($mystring.include?"MAKEERROR1").to be == true
    expect($mystring.include?"MAKE2").to be == false
    expect($mystring.include?"MAKEERROR2").to be == false
  end

  it 'Compile' do
    Bake.startKillTest("testCompile", self)

    expect($mystring.include?"Compiling lib1 (testCompile): src/a.cpp").to be == true
    expect($mystring.include?"Compiling lib1 (testCompile): src/e.cpp").to be == false
  end

  it 'Archive' do
    Bake.startKillTest("testArchive", self)

    expect($mystring.include?"liblib1.a").to be == true
  end

  it 'Link' do
    Bake.startKillTest("testLink", self)

    expect($mystring.include?"lib1"+Bake::Toolchain.outputEnding).to be == true
  end

end

end
