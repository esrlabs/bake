require 'fileutils'
require_relative '../../common/version'

module Bake

  class Create

    def self.header
      "\n"+
      "  RequiredBakeVersion minimum: \"#{Bake::Version.number}\"\n"+
      "\n"+
      "  Responsible {\n"+
      "    Person \"#{ENV["USER"]}\"\n"+
      "  }\n"
    end

    def self.includeOnly
      "\n"+
      "  CustomConfig IncludeOnly {\n"+
      "    IncludeDir include, inherit: true\n"+
      "  }\n"
    end

    def self.unitTestBase
      "\n"+
      "  ExecutableConfig UnitTestBase {\n"+
      "    Files \"test/src/**/*.cpp\"\n"+
      "    Dependency config: Lib\n"+
      "    DefaultToolchain GCC\n"+
      "  }\n"
    end

    def self.exeTemplate
      "Project default: Main {\n"+
      self.header +
      self.includeOnly+
      "\n"+
      "  ExecutableConfig Main {\n"+
      "    Files \"src/**/*.cpp\"\n"+
      "    Dependency config: IncludeOnly\n"+
      "    DefaultToolchain GCC\n"+
      "  }\n"+
      "\n}\n"
    end

    def self.libTemplate
      "Project default: Lib {\n"+
      self.header +
      self.includeOnly+
      "\n"+
      "  LibraryConfig Lib {\n"+
      "    Files \"src/**/*.cpp\"\n"+
      "    Dependency config: IncludeOnly\n"+
      "  }\n"+
      self.unitTestBase +
      "\n}\n"
    end

    def self.customTemplate
      "Project default: Lib {\n"+
      self.header+
      "\n"+
      "  CustomConfig Lib {\n"+
      "    Dependency config: IncludeOnly\n"+
      "  }\n"+
      self.unitTestBase +
      "\n}\n"
    end

    def self.mainTemplate
      "int main()\n"+
      "{\n"+
      "  return 0;\n"+
      "}\n"
    end

    def self.checkFile(name)
      if File.exists?(name)
        puts "#{name} already exists"
        ExitHelper.exit(1)
      end
    end

    def self.proj(type)
      checkFile("Project.meta")
      checkFile("src/main.cpp") if (type == "exe")
      FileUtils::mkdir_p "src"
      FileUtils::mkdir_p "include"

      if (type == "lib")
        File.write("Project.meta", libTemplate);
      elsif (type == "exe")
        File.write("Project.meta", exeTemplate);
        File.write("src/main.cpp", mainTemplate);
      elsif (type == "custom")
        File.write("Project.meta", customTemplate);
      else
        puts "'--create' must be followed by 'lib', 'exe' or 'custom'"
        ExitHelper.exit(1)
      end

      puts "Project created."
      ExitHelper.exit(0)
    end

  end

end
