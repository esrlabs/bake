module Bake

  class ProcessHelper
    @@pid = nil
    @@rd = nil

    def self.run(cmdLineArray, immediateOutput=false, force=true, outpipe=nil, exitCodeArray = [0])
      rd, wr = IO.pipe
      @@rd = rd if force
      duppedCmdLineArray = cmdLineArray.dup
      duppedCmdLineArray << { :err=>wr, :out=>(outpipe ? outpipe : wr) }
      begin
        pid = spawn(*duppedCmdLineArray)
      rescue Exception => e
        return [false, e.message]
      end
      @@pid = pid if force
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
      return [false, output] if status.nil?
      exitCodeArray = [0] if exitCodeArray.empty?
      [(exitCodeArray.include?status.exitstatus), output]
    end
       
    def self.killProcess(force) # do not kill compile processes or implement rd and pid array if really needed
      begin
        puts "_a"
        @@rd.close
        puts "_b"
      rescue Exception => e
        puts "_c"
      end
      begin
        puts "_d"
        Process.kill("KILL",@@pid)
        puts "_e"
      rescue Exception => e
        puts "_f"
      end
      puts "_g"
      @@rd = nil
      @@pid = nil
    end
    
  end

end