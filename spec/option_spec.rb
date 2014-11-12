#!/usr/bin/env ruby



require 'bake/version'

require 'tocxx'
require 'bake/options'
require 'imported/utils/exit_helper'

module Bake

ExitHelper.enable_exit_test

describe "Option Parser" do

  before(:each) do
    $mystring=""
    $sstring=StringIO.open($mystring,"w+")
    $stdoutbackup=$stdout
    $stdout=$sstring
  end
  after(:each) do
    $stdout=$stdoutbackup
  end

  it 'should provide a help flag' do
    ExitHelper.reset_exit_code
    options = Options.new(["-h"])
    lambda { options.parse_options() }.should raise_error(ExitHelperException)
    ExitHelper.exit_code.should == 0

    ExitHelper.reset_exit_code
    options = Options.new(["--help"])
    lambda { options.parse_options() }.should raise_error(ExitHelperException)
    ExitHelper.exit_code.should == 0
  end

  it 'should provide an available toolchains flag' do
    options = Options.new(["--toolchain_names"])
    lambda { options.parse_options() }.should raise_error(ExitHelperException)
    $mystring.include?("Available toolchains:").should == true
    $mystring.include?("Diab").should == true
  end
  
  it 'should provide a flag for printing tool options' do
    options = Options.new(["--toolchain_info"])
    lambda { options.parse_options() }.should raise_error(ExitHelperException)
    $mystring.include?("Argument for option --toolchain_info missing").should == true

    options = Options.new(["--toolchain_info", "blah"])
    lambda { options.parse_options() }.should raise_error(ExitHelperException)
    $mystring.include?("Toolchain not available").should == true
    
    options = Options.new(["--toolchain_info", "Diab"])
    lambda { options.parse_options() }.should raise_error(ExitHelperException)
    $mystring.split("SOURCE_FILE_ENDINGS").length.should == 4 # included 3 times
  end

  it 'should provide a flag to specify number of compile threads' do
    options = Options.new(["--threads"])
    lambda { options.parse_options() }.should raise_error(ExitHelperException)
    $mystring.include?("Argument for option --threads missing").should == true
    Rake::application.max_parallel_tasks.should == 8 # default

    options = Options.new(["--threads", "aaaaah"])
    lambda { options.parse_options() }.should raise_error(ExitHelperException)
    Rake::application.max_parallel_tasks.should == 8
    
    options = Options.new(["--threads", "2"])
    options.parse_options()
    Rake::application.max_parallel_tasks.should == 2
  end
  
 
end

end
