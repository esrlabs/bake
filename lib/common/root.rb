module Bake

  class Root
    attr_accessor :dir
    attr_accessor :depth

    def initialize(directory,search_depth)
      @dir = directory
      @depth = search_depth
    end

    def self.uniq(array)
      maxDepth = {}
      newArray = []
      array.each do |r|
        if maxDepth.has_key?r.dir
          d = maxDepth[r.dir]
          if !d.nil? && (r.depth.nil? || d < r.depth) # not covered yet
            newArray << r
            maxDepth[r.dir] = r.depth
          end
        else
          newArray << r
          maxDepth[r.dir] = r.depth
        end
      end
      return newArray
    end

    def self.extract_depth(str)
      regex = /\s*(\S*)\s*,\s*(\d+)\s*\z/
      scan_res = str.scan(regex)
      if scan_res.length > 0
        return Root.new(scan_res[0][0],scan_res[0][1].to_i)
      else
        return Root.new(str, nil)
      end
    end

    def self.equal(rootArrayA, rootArrayB)
      return false if rootArrayA.length != rootArrayB.length
      rootArrayA.each_with_index do |a, i|
        b = rootArrayB[i]
        return false if (a.dir != b.dir) || (a.depth != b.depth)
      end
      return true
    end

    def self.searchRootsFile(dir)
      rootsFile = dir+"/roots.bake"
      return rootsFile if File.exist?(rootsFile)

      parent = File.dirname(dir)
      return searchRootsFile(parent) if parent != dir

      return nil
    end

    def self.calc_roots_bake(dir)
      def_roots = []
      rootsFile = searchRootsFile(dir)
      if (rootsFile)
        File.open(rootsFile).each do |line|
          line = line.split("#")[0].strip.gsub(/[\\]/,'/')
          if line != ""
            root = Root.extract_depth(line)
            root.dir = root.dir[0..-2] if root.dir.end_with?("/")
            if !File.is_absolute?(root.dir)
              root.dir = File.expand_path(File.dirname(rootsFile) + "/" + root.dir)
            end
            def_roots << root
          end
        end
      end
      return def_roots
    end

    def self.calc_def_roots(dir)
      return [Root.new(File.dirname(dir), nil)]
    end

    def self.search_to_depth(root, baseName, depth)
      if not File.exist?(root)
        Bake.formatter.printError("Root #{root} does not exist.")
        ExitHelper.exit(1)
      end
      if depth != nil
        array = Array.new(depth+1) {|i| root + '/*'*i + '/' + baseName}
        return Dir.glob(array).sort
      else
        # when using junctions, /**/ does not work, so the glob is splitted into two globs to find at least first level projects
        str1 = "#{root}/#{baseName}"
        str2 = "#{root}/*/**/#{baseName}"
        return (Dir.glob(str1) + Dir.glob(str2)).sort
      end
    end

  end
end