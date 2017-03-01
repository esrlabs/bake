require 'stringio'

class ThreadOut

  def initialize(out)
    @out = out
  end

  def write(stuff='')
    if Thread.current[:stdout] then
      Thread.current[:stdout].write stuff
    else
      @out.write stuff
    end
  end

  def puts(stuff='')
    if Thread.current[:stdout] then
      Thread.current[:stdout].puts stuff
    else
      @out.puts stuff
    end
  end

  def print(stuff='')
    if Thread.current[:stdout] then
      Thread.current[:stdout].puts stuff
    else
      @out.print stuff
    end
  end

  def flush
    if Thread.current[:stdout] then
      Thread.current[:stdout].flush
    else
      @out.flush
    end
  end
end

STDOUT.sync = true
STDERR.sync = true
$stdout = ThreadOut.new(STDOUT)
$stderr = ThreadOut.new(STDERR)


class SyncOut
  def self.mutex
    @@mutex ||= Mutex.new
  end

  def self.flushOutput
    mutex.synchronize do
      tmp = Thread.current[:stdout]
      if tmp.string.length > 0
        Thread.current[:stdout] = Thread.current[:tmpStdout]
        puts tmp.string
        tmp.reopen("")
        Thread.current[:stdout] = tmp
      end
    end
  end

  def self.startStream
    s = StringIO.new
    Thread.current[:tmpStdout] = Thread.current[:stdout]
    Thread.current[:stdout] = s
  end

  def self.stopStream
    s = Thread.current[:stdout]
    Thread.current[:stdout] = Thread.current[:tmpStdout]
    mutex.synchronize do
      puts s.string if s.string.length > 0
    end
  end

end

