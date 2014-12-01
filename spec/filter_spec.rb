#!/usr/bin/env ruby

require 'common/version'

require 'tocxx'
require 'bake/options/options'
require 'imported/utils/exit_helper'
require 'imported/utils/cleanup'
require 'fileutils'
require 'helper'

module Bake

def self.startFilter(opt)
  Bake.options = Options.new(["-m", "spec/testdata/filter"].concat(opt))
  Bake.options.parse_options()
  tocxx = Bake::ToCxx.new
  tocxx.doit()
  tocxx.start()
end
  
describe "Filter" do
  
  it 'OneStep' do
    Bake.startFilter(["OneStep"])
    expect($mystring.include?("test done")).to be == true
  end
  it 'OneStep_include' do
    Bake.startFilter(["OneStep", "--include_filter", "FILTER"])
    expect($mystring.include?("test done")).to be == true
  end
  it 'OneStep_exclude' do
    Bake.startFilter(["OneStep", "--exclude_filter", "FILTER"])
    expect($mystring.include?("test done")).to be == true
  end
  
  it 'OneStepDefaultOn' do
    Bake.startFilter(["OneStepDefaultOn"])
    expect($mystring.include?("test done")).to be == true
  end
  it 'OneStepDefaultOn_include' do
    Bake.startFilter(["OneStepDefaultOn", "--include_filter", "FILTER"])
    expect($mystring.include?("test done")).to be == true
  end
  it 'OneStepDefaultOn_exclude' do
    Bake.startFilter(["OneStepDefaultOn", "--exclude_filter", "FILTER"])
    expect($mystring.include?("test done")).to be == true
  end
 
  it 'OneStepDefaultOff' do
    Bake.startFilter(["OneStepDefaultOff"])
    expect($mystring.include?("test done")).to be == false
  end
  it 'OneStepDefaultOff_include' do
    Bake.startFilter(["OneStepDefaultOff", "--include_filter", "FILTER"])
    expect($mystring.include?("test done")).to be == false
  end
  it 'OneStepDefaultOff_exclude' do
    Bake.startFilter(["OneStepDefaultOff", "--exclude_filter", "FILTER"])
    expect($mystring.include?("test done")).to be == false
  end
  
  it 'OneStepDefaultOnFILTER' do
    Bake.startFilter(["OneStepDefaultOnFILTER"])
    expect($mystring.include?("test done")).to be == true
  end
  it 'OneStepDefaultOnFILTER_include' do
    Bake.startFilter(["OneStepDefaultOnFILTER", "--include_filter", "FILTER"])
    expect($mystring.include?("test done")).to be == true
  end
  it 'OneStepDefaultOnFILTER_exclude' do
    Bake.startFilter(["OneStepDefaultOnFILTER", "--exclude_filter", "FILTER"])
    expect($mystring.include?("test done")).to be == false
  end
  
  it 'OneStepDefaultOffFILTER' do
    Bake.startFilter(["OneStepDefaultOffFILTER"])
    expect($mystring.include?("test done")).to be == false
  end  
  it 'OneStepDefaultOffFILTER_include' do
    Bake.startFilter(["OneStepDefaultOffFILTER", "--include_filter", "FILTER"])
    expect($mystring.include?("test done")).to be == true
  end
  it 'OneStepDefaultOffFILTER_exclude' do
    Bake.startFilter(["OneStepDefaultOffFILTER", "--exclude_filter", "FILTER"])
    expect($mystring.include?("test done")).to be == false
  end
  
  it 'MultipleSteps' do
    Bake.startFilter(["MultipleSteps"])
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
    Bake.startFilter(["MultipleSteps", "--include_filter", "FILTER"])
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
    Bake.startFilter(["MultipleSteps", "--exclude_filter", "FILTER"])
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
    Bake.startFilter(["MultipleSteps", "--include_filter", "FILTER", "--include_filter", "FILTER2"])
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
    Bake.startFilter(["MultipleSteps", "--exclude_filter", "FILTER", "--exclude_filter", "FILTER2"])
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
    Bake.startFilter(["MultipleSteps", "--include_filter", "PRE"])
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
    Bake.startFilter(["MultipleSteps", "--exclude_filter", "PRE"])
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
    Bake.startFilter(["MultipleSteps", "--include_filter", "POST"])
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
    Bake.startFilter(["MultipleSteps", "--exclude_filter", "POST"])
    expect($mystring.include?("test pre1")).to be == false
    expect($mystring.include?("test pre2")).to be == false
    expect($mystring.include?("test pre3")).to be == true
    expect($mystring.include?("test pre4")).to be == true
    expect($mystring.include?("test post1")).to be == false
    expect($mystring.include?("test post2")).to be == false
    expect($mystring.include?("test post3")).to be == false
    expect($mystring.include?("test post4")).to be == false
  end 
  
  it 'MultipleSteps_includeFILTERandPRE_excludePOST' do
    Bake.startFilter(["MultipleSteps", "--include_filter", "PRE", "--exclude_filter", "POST", "--include_filter", "FILTER"])
    expect($mystring.include?("test pre1")).to be == true
    expect($mystring.include?("test pre2")).to be == true
    expect($mystring.include?("test pre3")).to be == true
    expect($mystring.include?("test pre4")).to be == true
    expect($mystring.include?("test post1")).to be == true
    expect($mystring.include?("test post2")).to be == false
    expect($mystring.include?("test post3")).to be == false
    expect($mystring.include?("test post4")).to be == true
  end   
    
end

end
