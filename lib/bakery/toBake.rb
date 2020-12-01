require_relative "buildPattern"

module Bake

  def self.getBuildPattern(cols, name)

    colMeta = @options.collection_dir+"/Collection.meta"

    if (cols.length == 0)
      Bake.formatter.printError("Collection #{name} not found", colMeta)
      ExitHelper.exit(1)
    elsif (cols.length > 1)
      Bake.formatter.printError("Collection #{name} found more than once", colMeta)
      ExitHelper.exit(1)
    end

    col = cols[0]

    col.project.each do |p|
      if p.name == ""
        Bake.formatter.printError("Project name empty", p)
        ExitHelper.exit(1)
      end
      if p.config == ""
        Bake.formatter.printError("Config name empty", p)
        ExitHelper.exit(1)
      end
    end

    toBuildPattern = []
    @options.roots.each do |root|
      col.project.each do |p|
        projs = Root.search_to_depth(root.dir,p.name + "/Project.meta", root.depth)
        if File.basename(root.dir) == p.name && File.exist?(root.dir + "/Project.meta")
          projs << root.dir + "/Project.meta"
        end
        if projs.length == 0
          Bake.formatter.printWarning("pattern does not match any project: #{p.name}", p)
        end
        projs.each do |f|
          toBuildPattern << BuildPattern.new(f, "^"+p.config.gsub("*","(\\w*)")+"$", p.args, p)
        end
      end
    end

    toBuild = []
    toBuildPattern.each do |bp|
      next unless bp.proj
      contents = File.open(bp.proj, "r") {|io| io.read }
      contents.split("\n").each do |c|
        res = c.gsub(/#.*/,"").match("\\s*(Library|Executable|Custom){1}Config\\s*\"?([\\w:-]*)\"?")
        if res
          if res[2].match(bp.conf) != nil
            toBuild << BuildPattern.new(bp.proj, res[2], bp.args, nil)
            bp.coll_p.found
          end
        end
      end
    end

    toBuildPattern.select {|bp| !bp.coll_p.isFound}.map {|bp| bp.coll_p}.uniq.each do |p|
      Bake.formatter.printWarning("pattern does not match any config: #{p.config}", p)
    end

    col.exclude.each do |p|
      p.name = "/"+p.name.gsub("*","(\\w*)")+"/Project.meta"
      p.config = "^"+p.config.gsub("*","(\\w*)")+"$"
    end

    col.exclude_dir.each do |e|
      e.name = File.expand_path(e.name, @options.collection_dir)
    end

    toBuild.delete_if do |bp|
      exclude = false
      col.exclude.each do |p|
        exclude = true if (bp.proj.match(p.name) != nil and bp.conf.match(p.config) != nil)
      end
      col.exclude_dir.each do |e|
        exclude = true if bp.proj.start_with?(e.name)
      end
      exclude
    end

    toBuild.uniq!

    return toBuild
  end

end
