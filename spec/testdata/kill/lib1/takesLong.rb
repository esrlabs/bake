require 'fileutils'
FileUtils.rm 'timestamp' if File.exist?'timestamp'

STDOUT.puts "FIRST"
STDERR.puts "first"
STDOUT.flush
STDERR.flush
sleep 1.5
STDOUT.puts "SECOND"
STDERR.puts "second"
STDOUT.flush
STDERR.flush
sleep 1.5
STDOUT.puts "THIRD"
STDERR.puts "third"
STDOUT.flush
STDERR.flush
FileUtils.touch 'timestamp'
