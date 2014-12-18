require 'bake/toolchain/errorparser/error_parser'
require 'bake/toolchain/colorizing_formatter'
require 'thread'

module Bake

  # header of tcp msg from bake to eclipse:
  # 1 byte = type (problem = 0x01)
  # 4 bytes = length of msg

  # payload of problem type:
  # 4 bytes = length filename
  # x bytes = filename
  # 4 bytes = linenumber
  # 1 byte = severity (0..2)
  # rest    = error msg
  class IDEInterface < ErrorParser

    def initialize()
      @socket = nil
      @abort = false
      @thread = nil
    end
    
    def self.instance
      @@ide ||= IDEInterface.new
    end
    

    def mutex
      @mutex ||= Mutex.new
    end

    def connect(port)
      begin
        @socket = TCPSocket.new('localhost', port)

        @thread = Thread.new do
          while true do
          begin
            @socket.recv_nonblock(1)
            set_abort(true)
            break
          rescue Errno::EWOULDBLOCK
            sleep 0.1
          rescue Errno::EAGAIN
            sleep 0.1
          rescue Exception => e
            break
          end
          end
        end

      rescue Exception => e
        Bake.formatter.printError "Error: #{e.message}"
        ExitHelper.exit(1)
      end
    end

    def disconnect()
      if @socket
        sleep 0.1 # hack to let ruby send all data via streams before closing ... strange .. perhaps this should be synchronized!
        begin
          @socket.close
        rescue Exception => e
          Bake.formatter.printError "Error: #{e.message}"
          ExitHelper.exit(1)
        end
        @socket = nil
      end

      begin
        @thread.join if @thread
      rescue
      end
      @thread = nil
    end

    def write_long(packet, l)
      4.times do
        packet << (l & 0xff)
        l = l >> 8
      end
    end

    def force_encoding(s)
      s.force_encoding("binary") if s.respond_to?("force_encoding") # for ruby >= 1.9
    end

    def set_length_in_header(packet)
      l = packet.length - 5
      if packet.respond_to?("setbyte")
        (1..4).each { |i| packet.setbyte(i, (l & 0xFF)); l = l >> 8 } # ruby >= 1.9
      else
        (1..4).each { |i| packet[i] = (l & 0xFF); l = l >> 8 } # ruby < 1.9
      end
    end

    def write_string(packet, s)
      write_long(packet, s.length)
      packet << s
    end

    def set_errors(error_array)
      if @socket

        merged_messages = []
        last_msg = nil
        error_array.each do |msg|
          if msg.severity != 255
            if msg.file_name.nil?
              last_msg.message += "\r\n#{msg.message}" if last_msg
            else
              last_msg = msg.dup
              merged_messages << last_msg
            end
          end
        end

        merged_messages.each do |msg|
          msg.message.rstrip!
          packet = create_error_packet(msg)
          begin
            mutex.synchronize { @socket.write(packet) }
          rescue Exception => e
            Bake.formatter.printError "Error: #{e.message}"
            set_abort(true)
          end
        end

      end
    end

    def create_error_packet(msg)
      packet = ""
      [packet, msg.file_name, msg.message].each {|s|force_encoding(s)}

      packet << 1 # error type
      write_long(packet,0) # length (will be corrected below)

      write_string(packet, msg.file_name)
      write_long(packet,msg.line_number)
      packet << (msg.severity & 0xFF)
      packet << msg.message

      set_length_in_header(packet)
      packet
    end

    def set_build_info(name_attr, config_name_attr, num = -1)
      @num = num if (num >= 0)
      name = String.new(name_attr)
      config_name = String.new(config_name_attr)

      packet = ""
      [packet, name, config_name].each {|s|force_encoding(s)}

      lname = name.length
      lconfig = config_name.length
      lsum = 4 + lname + 4 + lconfig + 4

      packet << 10 # build info type

      write_long(packet, lsum)
      write_long(packet, lname)
      packet << name
      write_long(packet, lconfig)
      packet << config_name
      write_long(packet, num >=0 ? num : 0)

      begin
        mutex.synchronize { @socket.write(packet) if @socket }
      rescue Exception => e
        Bake.formatter.printError "Error: #{e.message}"
        set_abort(true)
      end

    end

    def get_number_of_projects
      @num ||= 0
    end

    def get_abort()
      @abort
    end

    def set_abort(value)
      @abort = value
      ProcessHelper.killProcess(false) if @abort
    end

  end
end
