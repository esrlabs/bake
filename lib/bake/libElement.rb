module Bake

  class LibElement

    LIB = 1
    USERLIB = 2
    LIB_WITH_PATH = 3
    SEARCH_PATH = 4
    DEPENDENCY = 5

    attr_reader :type, :value

    def initialize(type, value)
      @type = type
      @value = value
    end
  end

  class LibElements

    def self.calc_linker_lib_string(block, tcs)
      @@lib_path_set = []
      @@dep_set = Set.new
      @@linker = tcs[:LINKER]
      @@projectDir = block.projectDir
      @@source_libraries = []
      @@linker_libs_array = []
      @@withpath = []

      levels = @@linker[:LINK_ONLY_DIRECT_DEPS] ? 1 : -1
      collect_recursive(block, levels)
      @@source_libraries.reverse!
      @@lib_path_set.reverse!
      if @@linker[:LIST_MODE] and not @@lib_path_set.empty?
        @@linker_libs_array.unshift (@@linker[:LIB_PATH_FLAG] + @@lib_path_set.join(","));
      end
      @@linker_libs_array.reverse!

      return [@@source_libraries + @@withpath, @@linker_libs_array]
    end

    def self.adaptPath(path, block, prefix)
      adaptedPath = path
      if not File.is_absolute?(path)
        prefix ||= File.rel_from_to_project(@@projectDir, block.projectDir)
        adaptedPath = prefix + path if prefix
        adaptedPath = Pathname.new(adaptedPath).cleanpath.to_s
      end
      #adaptedPath = "\"" + adaptedPath + "\"" if adaptedPath.include?(" ")
      [adaptedPath, prefix]
    end

    def self.addOwnLib(block)
      if block.library
        adaptedPath, prefix = adaptPath(block.library.archive_name, block, prefix)
        if (block.prebuild and File.exist?adaptedPath) or
           (!block.library.compileBlock.nil? and !block.library.compileBlock.objects.empty?) or
           (!block.library.compileBlock.nil? and !block.library.compileBlock.calcSources(true, true).empty?)
          @@linker_libs_array << adaptedPath
          @@source_libraries << adaptedPath
        end
      end
    end

    def self.collect_recursive(block, levels = -1)
      return if @@dep_set.include?block
      @@dep_set << block

      prefix = nil

      if levels != 0
        lib_elements = calcLibElements(block)
        lib_elements += block.lib_elements unless block.lib_elements.nil?

        lib_elements.reverse.each do |elem|
          case elem.type
          when LibElement::LIB
            @@linker_libs_array << "#{@@linker[:LIB_FLAG]}#{elem.value}"
          when LibElement::USERLIB
            @@linker_libs_array << "#{@@linker[:USER_LIB_FLAG]}#{elem.value}"
          when LibElement::LIB_WITH_PATH
            adaptedPath, prefix = adaptPath(elem.value, block, prefix)
            @@linker_libs_array <<  adaptedPath
            @@withpath << adaptedPath
          when LibElement::SEARCH_PATH
            adaptedPath, prefix = adaptPath(elem.value, block, prefix)
            lpf = "#{@@linker[:LIB_PATH_FLAG]}#{adaptedPath}"
  
            if not @@lib_path_set.include?adaptedPath
              @@lib_path_set << adaptedPath
              @@linker_libs_array << lpf if @@linker[:LIST_MODE] == false
            end
  
            # must be moved to the end, so delete it...
            ind1 = @@lib_path_set.index(adaptedPath)
            ind2 = @@linker_libs_array.index(lpf)
            @@lib_path_set.delete_at(ind1)      if not ind1.nil?
            @@linker_libs_array.delete_at(ind2) if not ind2.nil?
  
            # end place it at the end again
            @@lib_path_set << adaptedPath
            @@linker_libs_array << lpf if @@linker[:LIST_MODE] == false
  
          when LibElement::DEPENDENCY
            if Blocks::ALL_BLOCKS.include?elem.value
              bb = Blocks::ALL_BLOCKS[elem.value]
              collect_recursive(bb, levels-1)
            else
              # TODO: warning or error?
            end
          end
        end
      end
      addOwnLib(block)
    end


    def self.calcLibElements(block)
      lib_elements = [] # value = array pairs [type, name/path string]

      block.config.libStuff.each do |l|
        if (Metamodel::UserLibrary === l)
          ln = l.name
          ls = nil
          if l.name.include?("/")
            pos = l.name.rindex("/")
            ls = block.convPath(l.name[0..pos-1], l)
            ln = l.name[pos+1..-1]
          end
          lib_elements << LibElement.new(LibElement::SEARCH_PATH, ls) if !ls.nil?
          lib_elements << LibElement.new(LibElement::USERLIB, ln)
        elsif (Metamodel::ExternalLibrarySearchPath === l)
          lib_elements << LibElement.new(LibElement::SEARCH_PATH, block.convPath(l))
        elsif (Metamodel::ExternalLibrary === l)
          ln = l.name
          ls = nil
          if l.name.include?("/")
            pos = l.name.rindex("/")
            ls = block.convPath(l.name[0..pos-1], l)
            ln = l.name[pos+1..-1]
          end
          if l.search
            lib_elements << LibElement.new(LibElement::SEARCH_PATH, ls) if !ls.nil?
            lib_elements << LibElement.new(LibElement::LIB, ln)
          else
            ln = ls + "/" + ln unless ls.nil?
            lib_elements << LibElement.new(LibElement::LIB_WITH_PATH, ln)
          end
        elsif (Metamodel::Dependency === l)
          lib_elements << LibElement.new(LibElement::DEPENDENCY, l.name+","+l.config)
        end

      end

      return lib_elements
    end

  end

end
