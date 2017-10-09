#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'

module Bake

describe "Filter" do

  it 'OneStep' do
    Bake.startBake("filter",  ["OneStep"])
    expect($mystring.include?("test done")).to be == true
  end
  it 'OneStep_include' do
    Bake.startBake("filter", ["OneStep", "--do", "FILTER"])
    expect($mystring.include?("test done")).to be == true
  end
  it 'OneStep_exclude' do
    Bake.startBake("filter", ["OneStep", "--omit", "FILTER"])
    expect($mystring.include?("test done")).to be == true
  end

  it 'OneStepDefaultOn' do
    Bake.startBake("filter", ["OneStepDefaultOn"])
    expect($mystring.include?("test done")).to be == true
  end
  it 'OneStepDefaultOn_include' do
    Bake.startBake("filter", ["OneStepDefaultOn", "--do", "FILTER"])
    expect($mystring.include?("test done")).to be == true
  end
  it 'OneStepDefaultOn_exclude' do
    Bake.startBake("filter", ["OneStepDefaultOn", "--omit", "FILTER"])
    expect($mystring.include?("test done")).to be == true
  end

  it 'OneStepDefaultOff' do
    Bake.startBake("filter", ["OneStepDefaultOff"])
    expect($mystring.include?("test done")).to be == false
  end
  it 'OneStepDefaultOff_include' do
    Bake.startBake("filter", ["OneStepDefaultOff", "--do", "FILTER"])
    expect($mystring.include?("test done")).to be == false
  end
  it 'OneStepDefaultOff_exclude' do
    Bake.startBake("filter", ["OneStepDefaultOff", "--omit", "FILTER"])
    expect($mystring.include?("test done")).to be == false
  end

  it 'OneStepDefaultOnFILTER' do
    Bake.startBake("filter", ["OneStepDefaultOnFILTER"])
    expect($mystring.include?("test done")).to be == true
  end
  it 'OneStepDefaultOnFILTER_include' do
    Bake.startBake("filter", ["OneStepDefaultOnFILTER", "--do", "FILTER"])
    expect($mystring.include?("test done")).to be == true
  end
  it 'OneStepDefaultOnFILTER_exclude' do
    Bake.startBake("filter", ["OneStepDefaultOnFILTER", "--omit", "FILTER"])
    expect($mystring.include?("test done")).to be == false
  end

  it 'OneStepDefaultOffFILTER' do
    Bake.startBake("filter", ["OneStepDefaultOffFILTER"])
    expect($mystring.include?("test done")).to be == false
  end
  it 'OneStepDefaultOffFILTER_include' do
    Bake.startBake("filter", ["OneStepDefaultOffFILTER", "--do", "FILTER"])
    expect($mystring.include?("test done")).to be == true
  end
  it 'OneStepDefaultOffFILTER_exclude' do
    Bake.startBake("filter", ["OneStepDefaultOffFILTER", "--omit", "FILTER"])
    expect($mystring.include?("test done")).to be == false
  end

  it 'MultipleSteps' do
    Bake.startBake("filter", ["MultipleSteps"])
    expect($mystring.include?("test pre1")).to be == false
    expect($mystring.include?("test pre2")).to be == false
    expect($mystring.include?("test pre3")).to be == true
    expect($mystring.include?("test pre4")).to be == true
    expect($mystring.include?("test post1")).to be == false
    expect($mystring.include?("test post2")).to be == false
    expect($mystring.include?("test post3")).to be == true
    expect($mystring.include?("test post4")).to be == true
  end

  it 'MultipleSteps_includeFILTER' do
    Bake.startBake("filter", ["MultipleSteps", "--do", "FILTER"])
    expect($mystring.include?("test pre1")).to be == true
    expect($mystring.include?("test pre2")).to be == false
    expect($mystring.include?("test pre3")).to be == true
    expect($mystring.include?("test pre4")).to be == true
    expect($mystring.include?("test post1")).to be == true
    expect($mystring.include?("test post2")).to be == false
    expect($mystring.include?("test post3")).to be == true
    expect($mystring.include?("test post4")).to be == true
  end

  it 'MultipleSteps_excludeFILTER' do
    Bake.startBake("filter", ["MultipleSteps", "--omit", "FILTER"])
    expect($mystring.include?("test pre1")).to be == false
    expect($mystring.include?("test pre2")).to be == false
    expect($mystring.include?("test pre3")).to be == true
    expect($mystring.include?("test pre4")).to be == false
    expect($mystring.include?("test post1")).to be == false
    expect($mystring.include?("test post2")).to be == false
    expect($mystring.include?("test post3")).to be == true
    expect($mystring.include?("test post4")).to be == false
  end

  it 'MultipleSteps_includeALL' do
    Bake.startBake("filter", ["MultipleSteps", "--do", "FILTER", "--do", "FILTER2"])
    expect($mystring.include?("test pre1")).to be == true
    expect($mystring.include?("test pre2")).to be == true
    expect($mystring.include?("test pre3")).to be == true
    expect($mystring.include?("test pre4")).to be == true
    expect($mystring.include?("test post1")).to be == true
    expect($mystring.include?("test post2")).to be == true
    expect($mystring.include?("test post3")).to be == true
    expect($mystring.include?("test post4")).to be == true
  end

  it 'MultipleSteps_excludeALL' do
    Bake.startBake("filter", ["MultipleSteps", "--omit", "FILTER", "--exclude_filter", "FILTER2"])
    expect($mystring.include?("test pre1")).to be == false
    expect($mystring.include?("test pre2")).to be == false
    expect($mystring.include?("test pre3")).to be == false
    expect($mystring.include?("test pre4")).to be == false
    expect($mystring.include?("test post1")).to be == false
    expect($mystring.include?("test post2")).to be == false
    expect($mystring.include?("test post3")).to be == false
    expect($mystring.include?("test post4")).to be == false
  end

  it 'MultipleSteps_includePRE' do
    Bake.startBake("filter", ["MultipleSteps", "--do", "PRE"])
    expect($mystring.include?("test pre1")).to be == true
    expect($mystring.include?("test pre2")).to be == true
    expect($mystring.include?("test pre3")).to be == true
    expect($mystring.include?("test pre4")).to be == true
    expect($mystring.include?("test post1")).to be == false
    expect($mystring.include?("test post2")).to be == false
    expect($mystring.include?("test post3")).to be == true
    expect($mystring.include?("test post4")).to be == true
  end

  it 'MultipleSteps_excludePRE' do
    Bake.startBake("filter", ["MultipleSteps", "--exclude_filter", "PRE"])
    expect($mystring.include?("test pre1")).to be == false
    expect($mystring.include?("test pre2")).to be == false
    expect($mystring.include?("test pre3")).to be == false
    expect($mystring.include?("test pre4")).to be == false
    expect($mystring.include?("test post1")).to be == false
    expect($mystring.include?("test post2")).to be == false
    expect($mystring.include?("test post3")).to be == true
    expect($mystring.include?("test post4")).to be == true
  end

  it 'MultipleSteps_includePOST' do
    Bake.startBake("filter", ["MultipleSteps", "--include_filter", "POST"])
    expect($mystring.include?("test pre1")).to be == false
    expect($mystring.include?("test pre2")).to be == false
    expect($mystring.include?("test pre3")).to be == true
    expect($mystring.include?("test pre4")).to be == true
    expect($mystring.include?("test post1")).to be == true
    expect($mystring.include?("test post2")).to be == true
    expect($mystring.include?("test post3")).to be == true
    expect($mystring.include?("test post4")).to be == true
  end

  it 'MultipleSteps_excludePOST' do
    Bake.startBake("filter", ["MultipleSteps", "--exclude_filter", "POST"])
    expect($mystring.include?("test pre1")).to be == false
    expect($mystring.include?("test pre2")).to be == false
    expect($mystring.include?("test pre3")).to be == true
    expect($mystring.include?("test pre4")).to be == true
    expect($mystring.include?("test post1")).to be == false
    expect($mystring.include?("test post2")).to be == false
    expect($mystring.include?("test post3")).to be == false
    expect($mystring.include?("test post4")).to be == false
  end

  it 'MultipleSteps_doSTARTUP' do
    Bake.startBake("filter", ["MultipleSteps", "--do", "STARTUP"])
    expect($mystring.include?("test startup1")).to be == true
    expect($mystring.include?("test startup2")).to be == true
  end

  it 'MultipleSteps_omitSTARTUP' do
    Bake.startBake("filter", ["MultipleSteps", "--omit", "STARTUP"])
    expect($mystring.include?("test startup1")).to be == false
    expect($mystring.include?("test startup2")).to be == false
  end

  it 'MultipleSteps_doEXIT' do
    Bake.startBake("filter", ["MultipleSteps", "--do", "EXIT"])
    expect($mystring.include?("test exit1")).to be == true
    expect($mystring.include?("test exit2")).to be == true
  end

  it 'MultipleSteps_omitEXIT' do
    Bake.startBake("filter", ["MultipleSteps", "--omit", "EXIT"])
    expect($mystring.include?("test exit1")).to be == false
    expect($mystring.include?("test exit2")).to be == false
  end

  it 'MultipleSteps_doCLEAN' do
    Bake.startBake("filter", ["MultipleSteps", "--do", "CLEAN", "-c"])
    expect($mystring.include?("test clean1")).to be == true
    expect($mystring.include?("test clean2")).to be == true
  end

  it 'MultipleSteps_omitCLEAN' do
    Bake.startBake("filter", ["MultipleSteps", "--omit", "CLEAN", "-c"])
    expect($mystring.include?("test clean1")).to be == false
    expect($mystring.include?("test clean2")).to be == false
  end

  it 'MultipleSteps_doCLEAN without cleaning' do
    Bake.startBake("filter", ["MultipleSteps", "--do", "CLEAN"])
    expect($mystring.include?("test clean1")).to be == false
    expect($mystring.include?("test clean2")).to be == false
  end

  it 'MultipleSteps_includeFILTERandPRE_excludePOST' do
    Bake.startBake("filter", ["MultipleSteps", "--include_filter", "PRE", "--exclude_filter", "POST", "--include_filter", "FILTER"])
    expect($mystring.include?("test pre1")).to be == true
    expect($mystring.include?("test pre2")).to be == true
    expect($mystring.include?("test pre3")).to be == true
    expect($mystring.include?("test pre4")).to be == true
    expect($mystring.include?("test post1")).to be == true
    expect($mystring.include?("test post2")).to be == false
    expect($mystring.include?("test post3")).to be == false
    expect($mystring.include?("test post4")).to be == true
  end

  it 'Filter_Main_off' do
    Bake.startBake("filter", ["FilterMain"])
    expect($mystring.include?("PREFILTER")).to be == false
    expect($mystring.include?("MAINFILTER")).to be == false
    expect($mystring.include?("POSTFILTER")).to be == false
  end

  it 'Filter_Main_Filter1' do
    Bake.startBake("filter", ["FilterMain", "--include_filter", "FILTER1"])
    expect($mystring.include?("PREFILTER")).to be == true
    expect($mystring.include?("MAINFILTER")).to be == true
    expect($mystring.include?("POSTFILTER")).to be == false
  end

  it 'Filter_Main_Filter1_Filter2' do
    Bake.startBake("filter", ["FilterMain", "--include_filter", "FILTER1", "--include_filter", "FILTER2"])
    expect($mystring.include?("PREFILTER")).to be == true
    expect($mystring.include?("MAINFILTER")).to be == true
    expect($mystring.include?("POSTFILTER")).to be == true
  end

  it 'Filter args nothing' do
    Bake.startBake("filter", ["FilterArgs", "--include_filter", "run"])
    expect($mystring.include?("run:  :run")).to be == true
  end

  it 'Filter args empty string' do
    Bake.startBake("filter", ["FilterArgs", "--include_filter", "run="])
    expect($mystring.include?("run:  :run")).to be == true
  end

  it 'Filter args simple filter' do
    Bake.startBake("filter", ["FilterArgs", "--include_filter", "run=abc"])
    expect($mystring.include?("run: abc :run")).to be == true
  end

  it 'Filter args complex filter' do
    Bake.startBake("filter", ["FilterArgs", "--include_filter", "run=--bla=2,3 --fasel"])
    expect($mystring.include?("run: --bla=2,3 --fasel :run")).to be == true
  end

end

end
