#!/usr/bin/env ruby

require 'helper'

require 'socket'
require 'fileutils'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'

module Bake

  def self.startKillTest2(config, test)
    serverSocket = TCPServer.new('localhost', 10000)
     
    Bake.options = Options.new(["-m", "spec/testdata/kill/main", config, "--socket", "10000", "-j", "2"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.connect()
     
    clientSocket = serverSocket.accept
    test.expect(clientSocket.nil?).to test.be == false
     
    t = Thread.new {
      sleep 1
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
  
describe "ci" do
  
  it 'lintpipe' do
    if Utils::OS.windows?
      expect(File.exists?("spec/testdata/hacks/main/test_lib_lib_lintout.xml")).to be == false
      expect(File.exists?("spec/testdata/hacks/main/test_main_testLintPipe_lintout.xml")).to be == false
    
      Bake.startBake("hacks/main", ["testLintPipe", "--lint"])
      
      expect(File.exists?("spec/testdata/hacks/main/test_lib_lib_lintout.xml")).to be == true
      expect(File.exists?("spec/testdata/hacks/main/test_main_testLintPipe_lintout.xml")).to be == true
    end
  end
  
  it 'Compile' do
     Bake.startKillTest2("testCompile", self)
     
     expect($mystring.include?"Compiling src/a.cpp").to be == true
     expect($mystring.include?"Compiling src/b.cpp").to be == true
     expect($mystring.include?"Compiling src/c.cpp").to be == true
     expect($mystring.include?"Compiling src/d.cpp").to be == true
     expect($mystring.include?"Compiling src/e.cpp").to be == false
   end  
   
  it 'pathes' do
    Bake.startBake("cache/main", ["testPathes", "-v2"])

    if not Utils::OS.windows?
      expect($mystring.scan("/usr/bin").count + $mystring.scan("/ruby").count).to be >= 5 
    else
      expect($mystring.scan("ruby").count).to be == 2 # assuming ruby is is a ruby dir
      expect($mystring.scan("bin").count).to be >= 3 # assuming that gcc in in a bin dir
    end
  end  

end


end
