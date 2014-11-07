module Cxxproject

  class BuildPattern
    attr_reader :proj, :conf, :coll_p
    def initialize(proj, conf, coll_p)
      @proj = proj
      @conf = conf
      @coll_p = coll_p
    end
    def getId
      proj + "*******" + conf
    end
    def hash
      getId.hash
    end
    def eql?(comparee)
      self == comparee
    end
    def ==(comparee)
      self.getId == comparee.getId
    end
  end
  
end
