require 'fileutils'

module Bake

  class Create

    def self.exeTemplate
      "Project default: main {\n"+
      "\n"+
      "  Responsible {\n"+
      "    Person \"#{ENV["USER"]}\"\n"+
      "  }\n"+
      "\n"+
      "  ExecutableConfig main {\n"+
      "    # Dependency ...\n"+
      "    Files \"src/**/*.cpp\"\n"+
      "    IncludeDir \"include\"\n"+
      "    DefaultToolchain GCC\n"+
      "  }\n"+
      "}\n"
    end

    def self.libTemplate
      "Project default: lib {\n"+
      "\n"+
      "  Responsible {\n"+
      "    Person \"#{ENV["USER"]}\"\n"+
      "  }\n"+
      "\n"+
      "  LibraryConfig lib {\n"+
      "    Files \"src/**/*.cpp\"\n"+
      "    IncludeDir \"include\"\n"+
      "  }\n"+
      "\n"+
      "  ExecutableConfig UnitTest {\n"+
      "    Dependency config: lib\n"+
      "    Files \"test/src/**/*.cpp\"\n"+
      "    IncludeDir \"include\"\n"+
      "    DefaultToolchain GCC\n"+
      "  }\n"+
      "}\n"
    end

    def self.customTemplate
      "Project default: lib {\n"+
      "\n"+
      "  Responsible {\n"+
      "    Person \"#{ENV["USER"]}\"\n"+
      "  }\n"+
      "\n"+
      "  CustomConfig lib {\n"+
      "    Files \"src/**/*.cpp\"\n"+
      "    IncludeDir \"include\"\n"+
      "  }\n"+
      "}\n"
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
