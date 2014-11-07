exit(1) if ARGV.length == 0

def isWin?
  (RUBY_PLATFORM =~ /cygwin|mswin|mingw|bccwin|wince|emx/) != nil
end

if ARGV[0] == "MAIN"
  puts (isWin? ? "C:/temp/testOutDirA" : "/tmp/testOutDirA")
elsif ARGV[0] == "LIB1"
  puts (isWin? ? "C:/temp/testOutDirB" : "/tmp/testOutDirB")
elsif ARGV[0] == "LIB2"
  puts (isWin? ? "C:/temp/testOutDirC" : "/tmp/testOutDirC")
elsif ARGV[0] == "ALL"
  puts (isWin? ? "C:/temp/testOutDirD" : "/tmp/testOutDirD")
else
  exit(1)
end
