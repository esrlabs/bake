module Bake

  class ProcessHelper
    @@pid = nil
    @@rd = nil

    def self.run(cmdLineArray, immediateOutput=false, force=true, outpipe=nil, exitCodeArray = [0], dir = Dir.pwd)
      rd, wr = IO.pipe
      @@rd = force ? rd : nil
      duppedCmdLineArray = cmdLineArray.dup
      duppedCmdLineArray << { :chdir=>dir, :err=>wr, :out=>(outpipe ? outpipe : wr) }
      begin
        pid = spawn(*duppedCmdLineArray)
      rescue Exception => e
        return [false, e.message]
      end
      @@pid = force ? pid : nil
      wr.close
      output = ""
      begin
        while not rd.eof?
          tmp = rd.read(1)
          if (tmp != nil)
            tmp.encode!('UTF-8',  :invalid => :replace, :undef => :replace, :replace => '')
            tmp.encode!('binary', :invalid => :replace, :undef => :replace, :replace => '')
            output << tmp

            print tmp if immediateOutput
          end
        end
      rescue
        # Seems to be a bug in ruby: sometimes there is a bad file descriptor on Windows instead of eof, which causes
        # an exception on read(). However, this happens not before everything is read, so there is no practical difference
        # how to "break" the loop.
        # This problem occurs on Windows command shell and Cygwin.
      end

      begin
        rd.close
      rescue
      end
      pid, status = Process.wait2(pid)
      @@pid = nil
      @@rd = nil

      if status.nil? && output.empty?
        puts output.inspect
        output = "Process returned with unknown exit status"
        puts output if immediateOutput
      end
      return [false, output] if status.nil?

      exitCodeArray = [0] if exitCodeArray.empty?
      ret = (exitCodeArray.include?status.exitstatus)
      if ret == false && output.empty?
        output = "Process returned with exit status #{status.exitstatus}"
        puts output if immediateOutput
      end
      [ret, output]
    end

    def self.killProcess(force) # do not kill compile processes or implement rd and pid array if really needed
      if @@rd
        begin
          @@rd.close
        rescue Exception => e
        end
        @@rd = nil
      end
      if @@pid
        begin
          Process.kill("KILL",@@pid)
        rescue Exception => e
        end
        @@pid = nil
      end
    end

  end

end