#!/usr/bin/env ruby

require 'common/version'

require 'tocxx'
require 'bake/options/options'
require 'imported/utils/exit_helper'
require 'helper'

module Bake

describe "Option Parser" do

  it 'should provide a help flag' do
    ExitHelper.reset_exit_code
    Bake.options = Options.new(["-h"])
    expect { Bake.options.parse_options() }.to raise_error(ExitHelperException)
    expect(ExitHelper.exit_code).to be == 0

    ExitHelper.reset_exit_code
    Bake.options = Options.new(["--help"])
    expect { Bake.options.parse_options() }.to raise_error(ExitHelperException)
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'should provide an available toolchains flag' do
    Bake.options = Options.new(["--toolchain_names"])
    expect { Bake.options.parse_options() }.to raise_error(ExitHelperException)
    expect($mystring.include?("Available toolchains:")).to be == true
    expect($mystring.include?("Diab")).to be == true
  end
  
  it 'should provide a flag for printing tool options' do
    Bake.options = Options.new(["--toolchain_info"])
    expect { Bake.options.parse_options() }.to raise_error(ExitHelperException)
    expect($mystring.include?("Argument for option --toolchain_info missing")).to be == true

    Bake.options = Options.new(["--toolchain_info", "blah"])
    expect { Bake.options.parse_options() }.to raise_error(ExitHelperException)
    expect($mystring.include?("Toolchain not available")).to be == true
    
    Bake.options = Options.new(["--toolchain_info", "Diab"])
    expect { Bake.options.parse_options() }.to raise_error(ExitHelperException)
    expect($mystring.split("SOURCE_FILE_ENDINGS").length).to be == 4 # included 3 times
  end

  it 'should provide a flag to specify number of compile threads' do
    Bake.options = Options.new([])
    expect { Bake.options.parse_options() }.to raise_error(ExitHelperException)
    expect(Bake.options.threads).to be == 8 # default
    
    Bake.options = Options.new(["--threads"])
    expect { Bake.options.parse_options() }.to raise_error(ExitHelperException)
    expect($mystring.include?("Argument for option --threads missing")).to be == true

    Bake.options = Options.new(["--threads", "aaaaah"])
    expect { Bake.options.parse_options() }.to raise_error(ExitHelperException)
    
    Bake.options = Options.new(["--threads", "2"])
    expect { Bake.options.parse_options() }.to raise_error(ExitHelperException)
    expect(Bake.options.threads).to be == 2
  end
  
 
end

end
