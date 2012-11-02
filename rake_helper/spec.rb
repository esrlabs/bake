$:.unshift(File.dirname(__FILE__)+"/../lib")
require 'bake/version'
$:.unshift(File.dirname(__FILE__)+"/../../cxxproject_master.git/lib")


SPEC_PATTERN ='spec/**/*_spec.rb'

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
  puts 'Please speficy a task in the namespace "test"'
end
task :spec do
  puts 'Please run test:spec'
end
