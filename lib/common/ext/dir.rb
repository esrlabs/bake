class Dir

  @@mutex = Mutex.new

  def self.glob_dir(pattern, dir)
    result = nil
    @@mutex.synchronize do
      Dir.chdir(dir) do
        result = Dir.glob(pattern)
      end
    end
    return result
  end

  def self.mutex
    @@mutex
  end

end
