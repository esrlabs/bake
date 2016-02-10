require 'bake/toolchain/colorizing_formatter'
require 'common/exit_helper'

module Bake

  class Parser
    
    def initialize(argv)
      @arguments = {}
      @argv = argv
    end
    
    #def add_option(opt)
    #  @arguments[opt.param] = opt
    #end
    
    def add_option(params, block)
      params.each { |p| @arguments[p] = block }
    end
    
    def get_block(param)
      opt = @arguments[param]
      raise "Internal error in option handling" unless opt
      opt.block
    end
    
    def valid?(argument)
      @arguments.include?argument
    end
    
    def has_parameter?(argument)
      return false unless valid?(argument)
      @arguments[argument].parameters.length == 1
    end
    
    def parse_internal(ignore_invalid, subOptions = nil)
      pos = 0
      begin
        while pos < @argv.length do
          arg = @argv[pos]
          if not valid?arg
            
            # used in bake config, must be passed from bakery to bake
            if subOptions and subOptions.valid?arg           
              if subOptions.has_parameter?(arg)
                if pos+1 < @argv.length and @argv[pos+1][0] != "-"
                  pos = pos + 1
                else
                  raise "Argument for option #{arg} missing" 
                end
              end
            end
            
            index = arg.index('-')
            if index != nil and index == 0
              raise "Option #{arg} unknown" if not ignore_invalid
            else
              @arguments[""].call(arg) # default paramter without "-"
            end
          else
            option = @arguments[arg]
            if option.parameters.length == 1
              if pos+1 < @argv.length and @argv[pos+1][0] != "-"
                option.call(@argv[pos+1])
                pos = pos + 1
              else
                raise "Argument for option #{arg} missing" 
              end
            else
              option.call()
            end
          end
          pos = pos + 1
        end
      rescue SystemExit => e
        raise
      rescue Exception => e
        Bake.formatter.printError("Error: " + e.message)
        ExitHelper.exit(1)
      end
      
    end
  
  end

end