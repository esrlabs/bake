module Bake

  class ProcessHelper
    @@pid = nil

    def self.readOutput(sp, rd, wr)
      @@pid = sp
      wr.close
        
      consoleOutput = ""
      begin
        while not rd.eof? 
           tmp = rd.read(1000)
           if (tmp != nil)
             consoleOutput << tmp
           end  
        end
      rescue Exception=>e
        # Seems to be a bug in ruby: sometimes there is a bad file descriptor on Windows instead of eof, which causes
        # an exception on read(). However, this happens not before everything is read, so there is no practical difference
        # how to "break" the loop.
        # This problem occurs on Windows command shell and Cygwin.
      end
        
      Process.wait(sp)
      @@pid = nil
      rd.close
      
      consoleOutput.encode!('UTF-8',  :invalid => :replace, :undef => :replace, :replace => '')
      consoleOutput.encode!('binary', :invalid => :replace, :undef => :replace, :replace => '')
      
      consoleOutput
    end

    def self.spawnProcess(cmdLine)
      return system(cmdLine) if Bake::Utils.old_ruby?
      @@pid = spawn(cmdLine)
      pid, status = Process.wait2(@@pid)
      @@pid = nil
      status.success? 
    end

    def self.killProcess
      begin
        Process.kill("KILL",@@pid)
      rescue
      end
      @@pid = nil
    end
    
    def self.safeExecute
      begin
        consoleOutput = yield
        [($?.to_i >> 8) == 0, consoleOutput, false]
      rescue Exception => e
        if Bake.options.debug
          puts e.message
          puts e.backtrace
        end
        [false, "Error: internal error with safeExecute()", true]
      end
    end
  end

end