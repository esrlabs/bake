#!/usr/bin/env ruby

require 'fileutils'

$stdout.sync = true

File.open("../global.lock", File::RDWR|File::CREAT, 0644) {|f|
  f.flock(File::LOCK_EX)
  value = f.read.to_i + 1
  f.rewind
  f.write("#{value}\n")
  puts "MAX: #{value}"
  f.flush
  f.truncate(f.pos)
}

step = -1

foundOutput = false
foundDep = false
output = nil
dep = nil
ARGV.each do |v|
  if v == "-o" || v == "-rc"
    foundOutput = true
  elsif v == "-MF"
    foundDep = true
  elsif foundOutput
    output = v
    foundOutput = false
  elsif foundDep
    dep = v
    foundDep = false
  end
end

if output.include?"a1" or output.include?"a2" or output.include?"c1" or output.include?"c2" or output.include?"c3" or output.include?"/test/"
  step = 1;
elsif output.include?"a3" or output.include?"b1" or output.include?"b2" or output.include?"libA"
  step = 2;
elsif output.include?"b3" or output.include?"libB"
  step = 3;
end

# puts "  #{output} - #{dep ? dep : "n/a"} - #{step}"

File.open(dep, 'wb') do |f|
  f.puts("abc: def")
end if dep
FileUtils.touch output if output

begin
  x = File.read("../step.txt")
end while x.to_i < step

sleep 0.2

File.open("../global.lock", File::RDWR|File::CREAT, 0644) {|f|
  f.flock(File::LOCK_EX)
  value = f.read.to_i - 1
  f.rewind
  f.write("#{value}\n")
  f.flush
  f.truncate(f.pos)
}
