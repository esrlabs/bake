$:.unshift(File.dirname(__FILE__)+"/")

require "rake"
require "lib/common/version"

include FileUtils

#YAML::ENGINE.yamler = 'syck'

PKG_VERSION = Bake::Version.number
PKG_FILES = FileList[
  "lib/**/*.rb",
  "Rakefile.rb",
  "doc/**/*",
  "doc/index.html",
  "license.txt"
]

Gem::Specification.new do |s|
  s.name = "bake-toolkit"
  s.version = PKG_VERSION
  s.summary = "Build tool to compile C/C++ projects fast and easy."
  s.description = "See documentation for more details"
  s.files = PKG_FILES.to_a
  s.require_path = "lib"
  s.author = "Alexander Schaal"
  s.email = "alexander.schaal@esrlabs.com"
  s.homepage = "http://www.esrlabs.com"
  s.rdoc_options = ["-x", "doc"]
  s.add_dependency("rtext", "=0.2.0")
  s.add_dependency("rgen", "=0.6.0")
  s.add_dependency("highline", ">= 1.6.0")
  s.add_dependency("colored")
  s.executables = ["bake", "bakery", "createVSProjects", "bake-doc"]
  s.licenses    = ['MIT']
  s.required_ruby_version = '>= 1.9'
end
