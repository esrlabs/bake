#!/usr/bin/env ruby

$:.unshift(File.dirname(__FILE__)+"/../../cxxproject/lib")

require 'bake/version'

require 'tocxx'
require 'bake/options'
require 'cxxproject/utils/exit_helper'
require 'socket'
require 'cxxproject/utils/cleanup'

module Cxxproject

ExitHelper.enable_exit_test

describe "Socket Handler" do
  
  before(:all) do
    Utils.cleanup_rake
  end

  after(:all) do
    ExitHelper.reset_exit_code
  end

  before(:each) do
    $mystring=""
    $sstring=StringIO.open($mystring,"w+")
    $stdoutbackup=$stdout
    $stdout=$sstring
  end
  after(:each) do
    $stdout=$stdoutbackup
  end

  it 'should recv/send to a port on localhost' do
    ExitHelper.reset_exit_code
    options = Options.new(["--socket"])
    lambda { options.parse_options() }.should raise_error(ExitHelperException)
    $mystring.include?("Argument for option --socket missing").should == true

    ExitHelper.reset_exit_code
    options = Options.new(["--socket", "10000"])
    options.parse_options()
    options.socket.should == 10000
    
    tocxx = Cxxproject::ToCxx.new(options)
    lambda { tocxx.connect() }.should raise_error(ExitHelperException)

    serverSocket = TCPServer.new('localhost', 10000)

    tocxx = Cxxproject::ToCxx.new(options)
    tocxx.connect()
    clientSocket = serverSocket.accept
    clientSocket.nil?.should == false
    
    res = ErrorDesc.new
    res.file_name = "File"
    res.line_number = 123
    res.severity = ErrorParser::SEVERITY_ERROR
    res.message = "too bad..."
    
    Rake.application.idei.set_errors([res])
    
    sleep 0.1
    xx = clientSocket.recv_nonblock(1000)
    xx.should == "\x01\x17\x00\x00\x00\x04\x00\x00\x00\x46\x69\x6c\x65\x7b\x00\x00\x00\x02\x74\x6f\x6f\x20\x62\x61\x64\x2e\x2e\x2e"
    
    Rake.application.idei.get_abort.should == false
    
    clientSocket.send("X",0) # triggers abort
    sleep 1.1
    
    Rake.application.idei.get_abort.should == true
    
    tocxx.disconnect()
  end
  
end

end
