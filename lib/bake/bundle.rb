require 'fileutils'
require 'common/ext/rtext'


module Bake

  class Bundle

    def initialize()
      cleanup()
    end

    def cleanup
      @outputDir = nil
      @result = true
      @sources = []
      @libs = []
      @ls = nil
    end

    def self.instance
      @@bundle ||= Bundle.new
    end

    def setOutputDir(dir)
      @outputDir = dir
      FileUtils.mkdir_p(@outputDir)
    end

    def addLib(lib, mainConfig)
      return unless @outputDir
      dir = @outputDir+"/lib"
      FileUtils.mkdir_p(dir)
      FileUtils.cp(lib, dir)
      @libs << "lib/" + File.basename(lib) unless mainConfig
      createProjectMeta(mainConfig)
    end

    def addBinary(exe, ls, mainConfig)
      return unless @outputDir

      dir = @outputDir+"/bin"
      FileUtils.mkdir_p(dir)
      FileUtils.cp(exe, dir)

      if (ls and mainConfig)
        lsDir = @outputDir+"/ls"
        FileUtils.mkdir_p(lsDir)
        FileUtils.cp(ls, lsDir)
        @ls = "ls/" + File.basename(ls)
      end

      createProjectMeta(mainConfig)
    end

    def addSource(source, includeList, depFilename)
      return unless @outputDir
      if File.is_absolute?(source)
        Bake.formatter.printWarning("Warning: '#{source}' is an absolute filename, this is not supported by bundle feature. File will be ignored.")
        return
      end
      sdir = File.dirname(source)
      dir = @outputDir
      dir = dir + "/" + sdir unless sdir.empty?
      FileUtils.mkdir_p(dir)
      FileUtils.cp(source, dir)
      @sources << source

      addHeaders(makeAbsolute(includeList), parseDepFile(depFilename))
    end

    def addHeaders(absIncs, deps)
      deps.each do |d|
        absIncs.each do |a|
          if d.start_with?a
            filename = d[a.length+1..-1]
            hdir = File.dirname(filename)
            dir = @outputDir + "/inc"
            dir = dir + "/" + hdir unless hdir.empty?
            FileUtils.mkdir_p(dir)
            FileUtils.cp(d, dir)
            next
          end
        end
      end
    end

    def makeAbsolute(includeList)
      includeList.map { |x| File.expand_path(x) }
    end

    def parseDepFile(depFilename)
      res = []
      begin
        File.readlines(depFilename).map{|line| line.strip}.each do |dep|
          if File.exist?(dep)
            res << File.expand_path(dep)
          end
        end
      rescue Exception => ex
      end
      res
    end

    def createProjectMeta(mainConfig)
      return unless mainConfig

      project = Bake::Metamodel::Project.new
      project.setDefault("bundle")
      project.file_name = ""

      config = mainConfig.class.new
      config.setName("bundle")

      project.setConfig([config])

      sourceElements = @sources.map do |s|
        source = Bake::Metamodel::Files.new
        source.setName(s)
        source
      end
      config.setFiles(sourceElements)

      idir = Bake::Metamodel::IncludeDir.new
      idir.setName("inc")
      config.setIncludeDir([idir])

      exLibs = @libs.map do |s|
        lib = Bake::Metamodel::ExternalLibrary.new
        lib.setName(s)
        lib.setSearch(false)
        lib
      end
      config.setLibStuff(exLibs)

      if (mainConfig.toolchain)
        config.setToolchain(Bake::MergeConfig.clone(mainConfig.toolchain))
      end

      if (mainConfig.defaultToolchain)
        config.setDefaultToolchain(Bake::MergeConfig.clone(mainConfig.defaultToolchain))
      end

      if (@ls)
        ls = Bake::Metamodel::LinkerScript.new
        ls.setName(@ls)
        config.setLinkerScript(ls)
      end

      s = StringIO.new
      ser = RText::Serializer.new(Language)
      ser.serialize(project, s)
      File.write(@outputDir + "/Project.meta", s.string)

    end

  end

end