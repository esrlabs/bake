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
