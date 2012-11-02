require 'cxxproject/utils/printer'
require 'cxxproject/utils/exit_helper'

module Cxxproject


class Option
  attr_reader :param, :arg, :block
  def initialize(param, arg, &f)
    @param = param
    @arg = arg # true / false
    @block = f
    f
    
  end
end


class Parser
  
  def initialize(argv)
    @options = {}
    @argv = argv
  end
  
  def add_option(opt)
    @options[opt.param] = opt
  end
  
  def parse_internal(ignoreInvalid = true)
    pos = 0
    begin
      while pos < @argv.length do
        if not @options.include?@argv[pos]
          if ignoreInvalid
            pos = pos + 1
            next
          end
          raise "Option #{@argv[pos]} unknown"
        end
        option = @options[@argv[pos]]
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
        pos = pos + 1
      end
    rescue SystemExit => e
      raise
    rescue Exception => e
      Printer.printError e.message
      ExitHelper.exit(1)
    end
    
  end

end


end