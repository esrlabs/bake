module Bake

  class BuildPattern
    attr_reader :proj, :conf, :args, :coll_p
    def initialize(proj, conf, args, coll_p)
      @proj = proj
      @conf = conf
      @args = args
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
