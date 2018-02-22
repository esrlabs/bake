require 'stringio'
require 'blocks/block'

class ThreadOut

  def initialize(out)
    @out = out
  end

  def write(stuff='')
    if Thread.current[:stdout] then
      Thread.current[:stdout].write stuff
    else
      begin
        @out.write stuff
      rescue Exception
      end
    end
  end

  def puts(stuff='')
    if Thread.current[:stdout] then
      Thread.current[:stdout].puts stuff
    else
      begin
         @out.puts stuff
      rescue Exception
      end
    end
  end

  def print(stuff='')
    if Thread.current[:stdout] then
      Thread.current[:stdout].puts stuff
    else
      begin
        @out.print stuff
      rescue Exception
      end
    end
  end

  def flush
    if Thread.current[:stdout] then
      Thread.current[:stdout].flush
    else
      begin
        @out.flush
      rescue Exception
      end
    end
  end
end

STDOUT.sync = true
STDERR.sync = true
$stdout = ThreadOut.new(STDOUT)
$stderr = ThreadOut.new(STDERR)

def puts(o)
  tmp = Thread.current[:stdout]
  tmp ? tmp.puts(o) : super(o)
end

class SyncOut
  def self.mutex
    @@mutex ||= Mutex.new
  end

  def self.flushOutput
    mutex.synchronize do
      tmp = Thread.current[:stdout]
      if tmp.string.length > 0
        Thread.current[:stdout] = Thread.current[:tmpStdout][Thread.current[:tmpStdout].length-1]
        puts tmp.string
        tmp.reopen("")
        Thread.current[:stdout] = tmp
      end
    end
  end

  def self.startStream
    s = StringIO.new
    if Thread.current[:tmpStdout].nil?
      Thread.current[:tmpStdout] = [Thread.current[:stdout]]
    else
      Thread.current[:tmpStdout] << Thread.current[:stdout]
    end
    Thread.current[:stdout] = s
  end

  def self.convertConfNum(str)
    if Bake.options.syncedOutput
      while str.sub!(">>CONF_NUM<<", Bake::Blocks::Block.block_counter.to_s) do
        Bake::Blocks::Block.inc_block_counter
      end
    end
  end

  def self.stopStream()
    mutex.synchronize do

      s = Thread.current[:stdout]
      return if s.nil?
      Thread.current[:stdout] = Thread.current[:tmpStdout] ? Thread.current[:tmpStdout].pop : nil

      if s.string.length > 0
        convertConfNum(s.string)
        puts s.string
        s.reopen("")
      end

    end

  end


  def self.discardStreams()
    mutex.synchronize do
      Thread.current[:stdout] = Thread.current[:tmpStdout] ? Thread.current[:tmpStdout].pop : nil
    end
  end

end

