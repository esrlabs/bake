module Bake

  def self.findDirOfFileToRoot(dir, filename)
    loop do
      completeName = dir + "/" + filename
      return dir if File.exist?(completeName)
      newDir = File.dirname(dir)
      return nil if newDir == dir
      dir = newDir
    end
  end

end
