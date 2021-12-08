require 'rake'

puts RbConfig::CONFIG['host_os']
puts "---------"
puts RUBY_PLATFORM

require './rake_helper/spec.rb'
