module Bake
  module Blocks
    class Show

      def self.secureShow
        begin
          yield
        rescue Exception => e
          if (not SystemExit === e)
            puts e
            puts e.backtrace
            ExitHelper.exit(1)
          else
            raise e
          end
        end
      end

      def self.includes
        secureShow {
        Blocks::ALL_COMPILE_BLOCKS.sort.each do |projName, blocks|
          print projName
          incs = []
          blocks.each do |block|
            if Bake.options.consoleOutput_fullnames
              incs += block.include_list.map { |i| File.expand_path(i, block.projectDir)  }
            else
              incs += block.include_list
            end
          end

          incs.uniq.each { |inc| print "##{inc}" }
          print "\n"
        end
        ExitHelper.exit(0) }
      end

      def self.readInternalIncludes(mainConfig, mainBlock, mainTcs)
        intIncs = []
        iinc = mainConfig.defaultToolchain.internalIncludes
        Dir.chdir(Bake.options.main_dir) do
          if (iinc)

            cppExe      = File.which(mainTcs[:COMPILER][:CPP][:COMMAND])
            cExe        = File.which(mainTcs[:COMPILER][:C][:COMMAND])
            asmExe      = File.which(mainTcs[:COMPILER][:ASM][:COMMAND])
            archiverExe = File.which(mainTcs[:ARCHIVER][:COMMAND])
            linkerExe   = File.which(mainTcs[:LINKER][:COMMAND])

            iname = mainBlock.convPath(iinc)
            if iname != ""
              if not File.exists?(iname)
                Bake.formatter.printError("InternalIncludes file #{iname} does not exist", iinc)
                ExitHelper.exit(1)
              end
              IO.foreach(iname) do |x|
                x.sub!("$(CPPPath)",      cppExe)
                x.sub!("$(CPath)",        cExe)
                x.sub!("$(ASMPath)",      asmExe)
                x.sub!("$(ArchiverPath)", archiverExe)
                x.sub!("$(LinkerPath)",   linkerExe)
                add_line_if_no_comment(intIncs,x)
              end
            end
          end
        end
        return intIncs
      end

      def self.readInternalDefines(mainConfig, mainBlock)
        intDefs = {:CPP => [], :C => [], :ASM => []}
        Dir.chdir(Bake.options.main_dir) do
          mainConfig.defaultToolchain.compiler.each do |c|
            if (c.internalDefines)
              dname = mainBlock.convPath(c.internalDefines)
              if dname != ""
                if not File.exists?(dname)
                  Bake.formatter.printError("InternalDefines file #{dname} does not exist", c.internalDefines)
                  ExitHelper.exit(1)
                end
                IO.foreach(dname) {|x| add_line_if_no_comment(intDefs[c.ctype],x)  }
              end
            end
          end
        end
        return intDefs
      end

      def self.includesAndDefines(mainConfig, mainTcs)
        secureShow {
        mainBlock = Blocks::ALL_BLOCKS[Bake.options.main_project_name+","+Bake.options.build_config]

        intIncs = readInternalIncludes(mainConfig, mainBlock, mainTcs)
        intDefs = readInternalDefines(mainConfig, mainBlock)


        projs = {}
        Blocks::ALL_COMPILE_BLOCKS.sort.each do |projName, blocks|

          blockIncs = []
          blockDefs = {:CPP => [], :C => [], :ASM => []}
          blocks.each do |block|
            block.calcFileTcs
            block.calcIncludes
            block.calcDefines
            block.calcFlags 
            if Bake.options.consoleOutput_fullnames
              blockIncs += block.include_list.map { |i| File.expand_path(i, block.projectDir)  }
            else
              blockIncs += block.include_list
            end
            [:CPP, :C, :ASM].each { |type| blockDefs[type] += block.block.tcs[:COMPILER][type][:DEFINES] }
          end
          if Bake.options.json
            projs[projName] =
              {  :includes => (blockIncs + intIncs).uniq,
                 :cpp_defines => (blockDefs[:CPP] + intDefs[:CPP]).uniq + Bake.options.defines,
                 :c_defines => (blockDefs[:C] + intDefs[:C]).uniq + Bake.options.defines,
                 :asm_defines => (blockDefs[:ASM] + intDefs[:ASM]).uniq + Bake.options.defines,
                 :dir => blocks.first.projectDir
              }
          else
            puts projName
            puts " dir #{blocks.first.projectDir}"
            puts " includes"
            (blockIncs + intIncs).uniq.each { |i| puts "  #{i}" }
            [:CPP, :C, :ASM].each do |type|
              puts " #{type} defines"
              (blockDefs[type] + intDefs[type] + Bake.options.defines).uniq.each { |d| puts "  #{d}" }
            end
            puts " done"
          end
        end

        if Bake.options.json
          require "json"
          puts JSON.pretty_generate(projs)
        end

        ExitHelper.exit(0) }
      end

    end
  end
end
