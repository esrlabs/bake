#!/usr/bin/env ruby

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'
require 'helper'

module Bake

describe "Filter" do
  
  it 'OneStep' do
    Bake.startBake("filter",  ["OneStep"])
    expect($mystring.include?("test done")).to be == true
  end
  it 'OneStep_include' do
    Bake.startBake("filter", ["OneStep", "--include_filter", "FILTER"])
    expect($mystring.include?("test done")).to be == true
  end
  it 'OneStep_exclude' do
    Bake.startBake("filter", ["OneStep", "--exclude_filter", "FILTER"])
    expect($mystring.include?("test done")).to be == true
  end
  
  it 'OneStepDefaultOn' do
    Bake.startBake("filter", ["OneStepDefaultOn"])
    expect($mystring.include?("test done")).to be == true
  end
  it 'OneStepDefaultOn_include' do
    Bake.startBake("filter", ["OneStepDefaultOn", "--include_filter", "FILTER"])
    expect($mystring.include?("test done")).to be == true
  end
  it 'OneStepDefaultOn_exclude' do
    Bake.startBake("filter", ["OneStepDefaultOn", "--exclude_filter", "FILTER"])
    expect($mystring.include?("test done")).to be == true
  end
 
  it 'OneStepDefaultOff' do
    Bake.startBake("filter", ["OneStepDefaultOff"])
    expect($mystring.include?("test done")).to be == false
  end
  it 'OneStepDefaultOff_include' do
    Bake.startBake("filter", ["OneStepDefaultOff", "--include_filter", "FILTER"])
    expect($mystring.include?("test done")).to be == false
  end
  it 'OneStepDefaultOff_exclude' do
    Bake.startBake("filter", ["OneStepDefaultOff", "--exclude_filter", "FILTER"])
    expect($mystring.include?("test done")).to be == false
  end
  
  it 'OneStepDefaultOnFILTER' do
    Bake.startBake("filter", ["OneStepDefaultOnFILTER"])
    expect($mystring.include?("test done")).to be == true
  end
  it 'OneStepDefaultOnFILTER_include' do
    Bake.startBake("filter", ["OneStepDefaultOnFILTER", "--include_filter", "FILTER"])
    expect($mystring.include?("test done")).to be == true
  end
  it 'OneStepDefaultOnFILTER_exclude' do
    Bake.startBake("filter", ["OneStepDefaultOnFILTER", "--exclude_filter", "FILTER"])
    expect($mystring.include?("test done")).to be == false
  end
  
  it 'OneStepDefaultOffFILTER' do
    Bake.startBake("filter", ["OneStepDefaultOffFILTER"])
    expect($mystring.include?("test done")).to be == false
  end  
  it 'OneStepDefaultOffFILTER_include' do
    Bake.startBake("filter", ["OneStepDefaultOffFILTER", "--include_filter", "FILTER"])
    expect($mystring.include?("test done")).to be == true
  end
  it 'OneStepDefaultOffFILTER_exclude' do
    Bake.startBake("filter", ["OneStepDefaultOffFILTER", "--exclude_filter", "FILTER"])
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
    Bake.startBake("filter", ["MultipleSteps", "--include_filter", "FILTER"])
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
    Bake.startBake("filter", ["MultipleSteps", "--exclude_filter", "FILTER"])
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
    Bake.startBake("filter", ["MultipleSteps", "--include_filter", "FILTER", "--include_filter", "FILTER2"])
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
    Bake.startBake("filter", ["MultipleSteps", "--exclude_filter", "FILTER", "--exclude_filter", "FILTER2"])
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
    Bake.startBake("filter", ["MultipleSteps", "--include_filter", "PRE"])
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
     
end

end
