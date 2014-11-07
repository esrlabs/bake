if (RUBY_PLATFORM =~ /cygwin|mswin|mingw|bccwin|wince|emx/) != nil
  puts ""
else
  puts "-nostdlib"
end