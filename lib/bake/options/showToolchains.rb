module Bake
  class ToolchainInfo
    
    def self.printHash(x, level)
      x.each do |k,v|
        if Hash === v
          if level > 0
            level.times {print "  "}
          else
            print "\n"
          end
          puts k
          printHash(v,level+1)
        elsif Array === v or String === v
          level.times {print "  "}
          print "\n" if (level == 0)
          puts "#{k} = #{v}"
        end
      end
    end

    def self.showToolchain(x)
      tcs = Bake::Toolchain::Provider[x]
      if tcs.nil?
        puts "Toolchain not available"
      else
        printHash(tcs, 0)
      end 
      ExitHelper.exit(0)
    end
    
    def self.showToolchainList()
      puts "Available toolchains:"
      Bake::Toolchain::Provider.list.keys.each { |c| puts "* #{c}" }
      ExitHelper.exit(0)
    end
    
  end
end