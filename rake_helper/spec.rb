$:.unshift(File.dirname(__FILE__)+"/../lib")

if defined?(RUBY_ENGINE) && RUBY_ENGINE == "ruby" && RUBY_VERSION >= "2.0"
  module Kernel
    alias :__at_exit :at_exit
    def at_exit(&block)
      __at_exit do
        exit_status = $!.status if $!.is_a?(SystemExit)
        block.call
        exit exit_status if exit_status
      end
    end
  end
end

begin
  require 'coveralls/rake/task'
  Coveralls::RakeTask.new
rescue LoadError
end

SPEC_PATTERN ='spec/**/*_spec.rb'

puts "Creating dummy libs"
`gcc -r -c rake_helper/dummy.c -o rake_helper/dummy.a`
FileUtils.mkdir_p("spec/testdata/merge/main/lib")
FileUtils.cp("rake_helper/dummy.a", "spec/testdata/merge/main/lib/libL1_1.a")
FileUtils.cp("rake_helper/dummy.a", "spec/testdata/merge/main/lib/libL1_2.a")
FileUtils.cp("rake_helper/dummy.a", "spec/testdata/merge/main/lib/libL2_1.a")
FileUtils.cp("rake_helper/dummy.a", "spec/testdata/merge/main/lib/libL2_2.a")
FileUtils.cp("rake_helper/dummy.a", "spec/testdata/merge/main/lib/libL3_1.a")
FileUtils.cp("rake_helper/dummy.a", "spec/testdata/merge/main/lib/libL3_2.a")
FileUtils.cp("rake_helper/dummy.a", "spec/testdata/merge/main/lib/libL5_1.a")
FileUtils.cp("rake_helper/dummy.a", "spec/testdata/merge/main/lib/libL5_2.a")
FileUtils.cp("rake_helper/dummy.a", "spec/testdata/cache/main/makefile/dummy.a")
puts "Dummy libs created"

def new_rspec
  require 'rspec/core/rake_task'
  desc "Run specs"
  RSpec::Core::RakeTask.new() do |t|
    t.pattern = SPEC_PATTERN
  end
end

def old_rspec
  require 'spec/rake/spectask'
  desc "Run specs"
  Spec::Rake::SpecTask.new() do |t|
    t.spec_files = SPEC_PATTERN
  end
end

namespace :test do
  begin
    new_rspec
  rescue LoadError
    begin
      old_rspec
    rescue LoadError
      desc "Run specs"
      task :spec do
        puts 'rspec not installed...! please install with "gem install rspec"'
      end
    end
  end
end

task :gem => [:spec]

task :test do
  puts 'Please specify a task in the namespace "test"'
end
task :spec do
  puts 'Please run test:spec'
end

task :travis do
  ENV["CI_RUNNING"] = "YES"
  if RUBY_VERSION.start_with?("2.4")
    ENV["COVERAGE_RUNNING"] = "YES"
  else
    ENV["COVERAGE_RUNNING"] = "NO"
  end

  Rake::Task["test:spec"].invoke
  begin
    Rake::Task["coveralls:push"].invoke
  rescue Exception
  end
end

task :appveyor do
  ENV["CI_RUNNING"] = "YES"
  ENV["COVERAGE_RUNNING"] = "NO"
  Rake::Task["test:spec"].invoke
end
