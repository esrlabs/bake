$:.unshift(File.dirname(__FILE__)+"/")

require "rake"
require "lib/bake/version"

include FileUtils

YAML::ENGINE.yamler = 'syck'

PKG_VERSION = Cxxproject::Version.bake
PKG_FILES = FileList[
  "lib/**/*.rb",
  "Rakefile.rb",
  "license.txt"
]

Gem::Specification.new do |s|
  s.name = "bake-toolkit"
  s.version = PKG_VERSION
  s.summary = "Frontend for cxxproject."
  s.description = <<-EOF
    This build tool is used to compile projects fast and easy.
  EOF
  s.files = PKG_FILES.to_a
  s.require_path = "lib"
  s.author = "Alexander Schaal"
  s.email = "alexander.schaal@esrlabs.com"
  s.homepage = "http://www.esrlabs.com"
  s.rdoc_options = ["-x", "doc"]
  s.add_dependency("cxxproject", "=0.5.68")
  s.add_dependency("rtext", "=0.2.0")
  s.add_dependency("rgen", "=0.6.0")
  s.executables = ["bake", "bakery", "createVSProjects"]
end
