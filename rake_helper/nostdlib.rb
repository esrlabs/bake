if (RUBY_PLATFORM =~ /cygwin|mswin|mingw|bccwin|wince|emx/) != nil
  puts "-nostdlib" # was puts "", but it seems its better to adapt rspec test instead of this hack, might be removed in future...
else
  puts "-nostdlib"
end