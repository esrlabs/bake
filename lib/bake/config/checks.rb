module Bake
  module Configs

    class Checks

      @@warnedCase = []
    
      def self.cleanupWarnings
        @@warnedCase.clear
      end

      def self.symlinkCheck(filename)
        dirOfProjMeta = File.dirname(filename)
        Dir.chdir(dirOfProjMeta) do
          if Dir.pwd != dirOfProjMeta and File.dirname(Dir.pwd) != File.dirname(dirOfProjMeta)
            isSym = false
            begin
              isSym = File.symlink?(dirOfProjMeta)
            rescue
            end
            if isSym
              Bake.formatter.printError("Symlinks only allowed with the same parent dir as the target: #{dirOfProjMeta} --> #{Dir.pwd}", filename)
              ExitHelper.exit(1)
            end
          end
        end
      end
      
      def self.sanityFolderName(dorg)
        return if !Bake.options.caseSensitivityCheck
        return if Bake.options.verbose < 1
        d = dorg
        while (d != File.dirname(d))
          b = File.basename(d)
          dnew = File.dirname(d)
          Dir.chdir(dnew) do
            files = Dir.glob("*")
            if !files.include?(b)
              possible = files.select{ |f| f.casecmp(b)==0 }
              if possible.length > 0 && !@@warnedCase.include?(d)
                @@warnedCase << d
                Bake.formatter.printWarning("Warning: '#{b}' not found in '#{dnew}'. Alternatives: #{possible.map{|p| "'#{p}'"}.join(", ")}. Maybe a typo happened while entering a folder in the shell?")
              end
            end
          end
          d = dnew
        end
      end

      def self.commonMetamodelCheck(configs, filename, isAdapt = false)

        if configs.length == 0 && !isAdapt
          Bake.formatter.printError("No config found", filename)
          ExitHelper.exit(1)
        end

        configs.each do |config|
          if config.respond_to?("toolchain") and config.toolchain
            config.toolchain.compiler.each do |c|
              if [:CPP,:C,:ASM].none? {|t| t == c.ctype}
                Bake.formatter.printError("Type of compiler must be CPP, C or ASM", c)
                ExitHelper.exit(1)
              end
              if not c.internalDefines.nil? and c.internalDefines != ""
                Bake.formatter.printError("InternalDefines only allowed in DefaultToolchain", c.internalDefines)
                ExitHelper.exit(1)
              end
              if c.fileEndings && c.fileEndings.endings.empty?
                Bake.formatter.printError("FileEnding must not be empty.", c.fileEndings)
                ExitHelper.exit(1)
              end
            end
            config.toolchain.lintPolicy.each do |l|
              Bake.formatter.printWarning("Lint support was removed. Please delete LintPolicy from Project.meta.", l)
            end
          end
          if config.respond_to?("defaultToolchain") and config.defaultToolchain
            config.defaultToolchain.lintPolicy.each do |l|
              Bake.formatter.printWarning("Lint support was removed. Please delete LintPolicy from Project.meta.", l)
            end
            config.defaultToolchain.compiler.each do |c|
              if [:CPP,:C,:ASM].none? {|t| t == c.ctype}
                Bake.formatter.printError("Type of compiler must be CPP, C or ASM", c)
                ExitHelper.exit(1)
              end
              if c.fileEndings && c.fileEndings.endings.empty?
                Bake.formatter.printError("FileEnding must not be empty.", c.fileEndings)
                ExitHelper.exit(1)
              end
            end
          end

          config.includeDir.each do |inc|
            if not ["front", "back", ""].include?inc.inject
              Bake.formatter.printError("inject of IncludeDir must be 'front' or 'back'", inc)
              ExitHelper.exit(1)
            end
            if not ["front", "back", ""].include?inc.infix
              Bake.formatter.printError("infix of IncludeDir must be 'front' or 'back'", inc)
              ExitHelper.exit(1)
            end
            if (inc.infix != "" and inc.inject != "")
              Bake.formatter.printError("IncludeDir must have inject OR infix (deprecated)", inc)
              ExitHelper.exit(1)
            end
            if (inc.name.empty? || inc.name[0] == " ")
              Bake.formatter.printError("IncludeDir must not be empty or start with a space", inc)
              ExitHelper.exit(1)
            end
          end if config.respond_to?("includeDir")

          if not ["", "yes", "no", "all"].include?config.mergeInc
            Bake.formatter.printError("Allowed modes are 'all', 'yes', 'no' and unset.",config)
            ExitHelper.exit(1)
          end

        end

      end

    end

  end
end