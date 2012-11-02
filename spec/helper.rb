module Cxxproject

class SpecHelper

  def self.clean_testdata_build(name,main,setup)
    r = Dir.glob("spec/testdata/#{name}/#{main}/#{setup}")
    r.each { |f| FileUtils.rm_rf(f) }
    r = Dir.glob("spec/testdata/#{name}/**/.bake")
    r.each { |f| FileUtils.rm_rf(f) }
  end

end

end