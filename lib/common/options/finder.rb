module Bake

  def self.findDirOfFileToRoot(dir, filename)
    if !File.exists?(dir)
      Bake.formatter.printError("Error: #{dir} does not exist")
      ExitHelper.exit(1)
    end
    loop do
      completeName = dir + "/" + filename
      return dir if File.exist?(completeName)
      newDir = File.dirname(dir)
      return nil if newDir == dir
      dir = newDir
    end
  end

end
