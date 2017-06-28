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

    def valid?(argument)
      @arguments.any? { |a, b|
        argument == a || (a != "" && argument.start_with?(a) && (!b || (b.parameters.length==3 && argument[a.length..-1].scan(/\A\d*\z/).length > 0)))
      }
    end

    def get_block(argument)
      arg = nil
      block = nil
      @arguments.each do |a, b|
        if argument.start_with?(a) && a != ""
          return [b, nil] if a == argument
          if b && b.parameters.length==3 && argument[a.length..-1].scan(/\A\d*\z/).length > 0
            block = b
            arg = argument[a.length..-1]
          end
        end
      end
      return [block, arg]
    end

    def has_parameter?(argument)
      b, inPlaceArg = get_block(argument)
      return false unless b
      return false if inPlaceArg
      b.parameters.length >= 1
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
              @arguments[""].call(arg) # default parameter without "-"
            end
          else
            option, inPlaceArg = get_block(arg)
            hasArgument = (pos+1 < @argv.length and @argv[pos+1][0] != "-")
            if option.parameters.length == 3 && (hasArgument || inPlaceArg)
              if inPlaceArg
                option.call(inPlaceArg, nil, nil)
              else
                option.call(@argv[pos+1], nil, nil) # do not use inplace value
                pos = pos + 1
              end
            elsif option.parameters.length == 2
              if hasArgument
                option.call(@argv[pos+1], nil) # do not use default value
                pos = pos + 1
              else
                option.call(nil, nil) # use default value
              end
            elsif option.parameters.length == 1 && hasArgument
              option.call(@argv[pos+1])
              pos = pos + 1
            elsif option.parameters.length == 0
              option.call()
            else
              raise "Argument for option #{arg} missing"
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