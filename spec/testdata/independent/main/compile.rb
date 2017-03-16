require 'fileutils'
ARGV.each_with_index do |a,i|
  if a == "-MF"
    depFile = ARGV[i+1]
    FileUtils.mkdir_p(File.dirname(depFile))
    File.open(depFile, 'w') { |f|
      f.puts "x: "
    }
    break
  end
end
