#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'tocxx'
require 'bake/options/options'
require 'common/exit_helper'
require 'socket'

module Bake

describe "Socket Handler" do

  it 'socket option invalid' do
    expect { Bake.startBake("set_set/A", ["test", "--socket"]) }.to raise_error(SystemExit)
    expect($mystring.include?("Argument for option --socket missing")).to be == true
  end

  it 'no server socket' do
    Bake.options = Options.new(["-m", "spec/testdata/root1/main", "test", "--socket", "10000"])
    Bake.options.parse_options()
    expect(Bake.options.socket).to be == 10000
    tocxx = Bake::ToCxx.new
    expect { tocxx.connect() }.to raise_error(SystemExit)
  end

  it 'abort' do
    serverSocket = TCPServer.new('localhost', 10000)

    Bake.options = Options.new(["-m", "spec/testdata/root1/main", "test", "--socket", "10000"])
    Bake.options.parse_options()
    tocxx = Bake::ToCxx.new
    tocxx.connect()

    clientSocket = serverSocket.accept
    expect(clientSocket.nil?).to be == false

    res = ErrorDesc.new
    res.file_name = "File"
    res.line_number = 123
    res.severity = ErrorParser::SEVERITY_ERROR
    res.message = "too bad..."

    Bake::IDEInterface.instance.set_errors([res])

    sleep 0.1
    xx = clientSocket.recv_nonblock(1000)
    expect(xx).to be == "\x01\x17\x00\x00\x00\x04\x00\x00\x00\x46\x69\x6c\x65\x7b\x00\x00\x00\x02\x74\x6f\x6f\x20\x62\x61\x64\x2e\x2e\x2e"

    expect(Bake::IDEInterface.instance.get_abort).to be == false

    clientSocket.send("X",0) # triggers abort
    sleep 1.1

    expect(Bake::IDEInterface.instance.get_abort).to be == true
    tocxx.disconnect()
  end

end

end
