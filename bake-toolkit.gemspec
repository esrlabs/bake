$:.unshift(File.dirname(__FILE__)+"/")

require "lib/common/version"

include FileUtils

#YAML::ENGINE.yamler = 'syck'

PKG_VERSION = Bake::Version.number
PKG_FILES = Dir[
  "lib/**/*.rb",
  "Rakefile.rb",
  "license.txt"
]

Gem::Specification.new do |s|
  s.name = "bake-toolkit"
  s.version = PKG_VERSION
  s.summary = "Build tool to compile C/C++ projects fast and easy."
  s.description = "See documentation for more details"
  s.files = PKG_FILES
  s.require_path = "lib"
  s.author = "Alexander Schaal"
  s.email = "alexander.schaal@esrlabs.com"
  s.rdoc_options = ["-x", "doc"]
  s.add_dependency("rtext", "=0.9.0")
  s.add_dependency("rgen", "=0.8.2")
  s.add_dependency("highline", "=1.7.8")
  s.add_dependency("concurrent-ruby", "=1.0.5")
  s.add_dependency("colored", "=1.2")
  s.add_development_dependency("rake", "12.2.1")
  s.add_development_dependency("rspec")
  s.add_development_dependency("simplecov")
  s.add_development_dependency("coveralls")
  s.executables = ["bake", "bakery", "bake-doc", "bakeqac", "bakeclean", "bake-format", "bake-rtext-service"]
  s.licenses    = ['MIT']
  s.required_ruby_version = '>= 2.0'
end
