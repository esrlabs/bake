require "bakery/buildPattern"

module Cxxproject

  def self.getBuildPattern(cols, name)

    if (cols.length == 0)
      Printer.printError "Collection #{name} not found in #{@options.collection_dir+"/Collection.meta"}"
      ExitHelper.exit(1)
    elsif (cols.length > 1)
      Printer.printError "Collection #{name} found more than once in #{@options.collection_dir+"/Collection.meta"}"
      ExitHelper.exit(1)
    end

    col = cols[0]

    col.project.each do |p|
      if p.name == ""
        Printer.printError "Error in #{@options.collection_dir+"/Collection.meta"} (line #{p.line_number}): Project name empty"
        ExitHelper.exit(1)
      end
      if p.config == ""
        Printer.printError "Error in #{@options.collection_dir+"/Collection.meta"} (line #{p.line_number}): Config name empty"
        ExitHelper.exit(1)
      end
    end

    toBuildPattern = []
    @options.roots.each do |r|
      col.project.each do |p|
        projs = Dir.glob(r+"/"+p.name+"/Project.meta")
        if projs.length == 0
          toBuildPattern << BuildPattern.new(nil, nil, p) # remember it for sorted info printout
        end
        projs.each do |f|
          toBuildPattern << BuildPattern.new(f, "^"+p.config.gsub("*","(\\w*)")+"$", p)
        end
      end
    end

    toBuild = []
    toBuildPattern.each do |bp|
      next unless bp.proj
      contents = File.open(bp.proj, "r") {|io| io.read }
      contents.split("\n").each do |c|
        res = c.match("\\s*(Library|Executable|Custom){1}Config\\s*(\\w*)")
        if res
          if res[2].match(bp.conf) != nil
            toBuild << BuildPattern.new(bp.proj, res[2], nil)
            bp.coll_p.found
          end
        end
      end
    end

    toBuildPattern.each do |bp|
      Printer.printInfo "Info in #{@options.collection_dir+"/Collection.meta"} (line #{bp.coll_p.line_number}): No match for project #{bp.coll_p.name} with config #{bp.coll_p.config}" unless bp.coll_p.isFound
    end

    col.exclude.each do |p|
      p.name = "/"+p.name.gsub("*","(\\w*)")+"/Project.meta"
      p.config = "^"+p.config.gsub("*","(\\w*)")+"$"
    end

    toBuild.delete_if do |bp|
      exclude = false
      col.exclude.each do |p|
        exclude = true if (bp.proj.match(p.name) != nil and bp.conf.match(p.config) != nil)
      end
      exclude
    end

    toBuild.uniq!

    return toBuild
  end

end