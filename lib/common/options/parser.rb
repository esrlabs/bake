require 'bake/toolchain/colorizing_formatter'
require 'imported/utils/exit_helper'

module Bake

  class Parser
    
    def initialize(argv)
      @arguments = {}
      @argv = argv
      @default = nil
    end
    
    def add_option(opt)
      @arguments[opt.param] = opt
    end
    
    def add_default(opt)
      @default = opt
    end
    
    def parse_internal(ignoreInvalid = true)
      pos = 0
      begin
        while pos < @argv.length do
          if not @arguments.include?@argv[pos]
            if @default
              res = @default.call(@argv[pos])
              if (not res and not ignoreInvalid)
                raise "Option #{@argv[pos]} unknown"
              end
            end
          else
            option = @arguments[@argv[pos]]
            if option.arg
              if pos+1 < @argv.length and @argv[pos+1][0] != "-"
                option.block.call(@argv[pos+1])
                pos = pos + 1
              else
                raise "Argument for option #{@argv[pos]} missing" 
              end
            else
              option.block.call()
            end
          end
          pos = pos + 1
        end
      rescue SystemExit => e
        raise
      rescue Exception => e
        Bake.formatter.printError e.message unless e.message.include?("Bake::ExitHelperException")
        ExitHelper.exit(1)
      end
      
    end
  
  end

end