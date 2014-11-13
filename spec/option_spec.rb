#!/usr/bin/env ruby

require 'bake/version'

require 'tocxx'
require 'bake/options'
require 'imported/utils/exit_helper'

module Bake

describe "Option Parser" do

  it 'should provide a help flag' do
    ExitHelper.reset_exit_code
    options = Options.new(["-h"])
    expect { options.parse_options() }.to raise_error(ExitHelperException)
    expect(ExitHelper.exit_code).to be == 0

    ExitHelper.reset_exit_code
    options = Options.new(["--help"])
    expect { options.parse_options() }.to raise_error(ExitHelperException)
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'should provide an available toolchains flag' do
    options = Options.new(["--toolchain_names"])
    expect { options.parse_options() }.to raise_error(ExitHelperException)
    expect($mystring.include?("Available toolchains:")).to be == true
    expect($mystring.include?("Diab")).to be == true
  end
  
  it 'should provide a flag for printing tool options' do
    options = Options.new(["--toolchain_info"])
    expect { options.parse_options() }.to raise_error(ExitHelperException)
    expect($mystring.include?("Argument for option --toolchain_info missing")).to be == true

    options = Options.new(["--toolchain_info", "blah"])
    expect { options.parse_options() }.to raise_error(ExitHelperException)
    expect($mystring.include?("Toolchain not available")).to be == true
    
    options = Options.new(["--toolchain_info", "Diab"])
    expect { options.parse_options() }.to raise_error(ExitHelperException)
    expect($mystring.split("SOURCE_FILE_ENDINGS").length).to be == 4 # included 3 times
  end

  it 'should provide a flag to specify number of compile threads' do
    options = Options.new(["--threads"])
    expect { options.parse_options() }.to raise_error(ExitHelperException)
    expect($mystring.include?("Argument for option --threads missing")).to be == true
    expect(Rake::application.max_parallel_tasks).to be == 8 # default

    options = Options.new(["--threads", "aaaaah"])
    expect { options.parse_options() }.to raise_error(ExitHelperException)
    expect(Rake::application.max_parallel_tasks).to be == 8
    
    options = Options.new(["--threads", "2"])
    options.parse_options()
    expect(Rake::application.max_parallel_tasks).to be == 2
  end
  
 
end

end
