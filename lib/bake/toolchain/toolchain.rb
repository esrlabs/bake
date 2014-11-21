require 'yaml'

class Hash
  def method_missing(m, *args, &block)
    if m.to_s =~ /(.*)=$/ # was assignment
      self[$1] = args[0]
    else
      fetch(m.to_s, nil)
    end
  end
  def recursive_merge(h)
    self.merge!(h) {|key, _old, _new| if _old.class == Hash then _old.recursive_merge(_new) else _new end  } 
  end

end

class Toolchain
  attr_reader :toolchain
  def initialize(toolchain_file)
    @toolchain = YAML::load(File.open(toolchain_file))
    if @toolchain.base
      @based_on = @toolchain.base
    else
      @based_on = "base"
    end
    basechain = YAML::load(File.open(File.join(File.dirname(__FILE__),"#{@based_on}.json")))
    @toolchain = basechain.recursive_merge(@toolchain)
  end
  def method_missing(m, *args, &block)  
    if @toolchain[m.to_s]
      self.class.send(:define_method, m) { @toolchain[m.to_s] }
      @toolchain[m.to_s]
    else
      return super
    end
  end  

end
