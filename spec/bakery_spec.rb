#!/usr/bin/env ruby

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'
require 'helper'

module Bake

describe "bake" do

  it 'collection double' do
    str = `ruby bin/bakery -m spec/testdata/root1/main -b double`
    expect(str.include?("found more than once")).to be == true
  end  

  it 'collection empty' do
    str = `ruby bin/bakery -m spec/testdata/root1/main gugu`
    expect(str.include?("0 of 0 builds ok")).to be == true
  end  

  it 'collection onlyExclude' do
    str = `ruby bin/bakery -m spec/testdata/root1/main -b gigi`
    expect(str.include?("0 of 0 builds ok")).to be == true
    
  end  

  it 'collection working' do
    str = `ruby bin/bakery -m spec/testdata/root1/main gaga -w spec/testdata/root1 -w spec/testdata/root2`
    expect(str.include?("1 of 3 builds failed")).to be == true
  end  
  
  it 'two collection names without -b' do
    str = `ruby bin/bakery -m spec/testdata/root1/main gaga gigi -w spec/testdata/root1 -w spec/testdata/root2`
    expect(str.include?("1 of 3 builds failed")).to be == false
  end 
  
  it 'two collection names with -b' do
    str = `ruby bin/bakery -m spec/testdata/root1/main -b gaga -b gigi -w spec/testdata/root1 -w spec/testdata/root2`
    expect(str.include?("1 of 3 builds failed")).to be == false
  end 

  it 'collection parse params' do
    str = `ruby bin/bakery -m spec/testdata/root1/main -b gaga -w spec/testdata/root1 -w spec/testdata/root2 -v2 -a black --ignore-cache -r -c`
    expect(str.include?(" -r")).to be == true
    expect(str.include?(" -a black")).to be == true
    expect(str.include?(" -v2")).to be == true
    expect(str.include?(" --ignore-cache")).to be == true
    expect(str.include?(" -r")).to be == true
    expect(str.include?(" -c")).to be == true
  end
  
  it 'collection wrong' do
    str = `ruby bin/bakery -m spec/testdata/root1/main -b wrong -w spec/testdata/root1 -w spec/testdata/root2 -r`
    expect(str.include?("bakery aborted")).to be == true
    expect(str.include?("must contain DefaultToolchain")).to be == true
    str = `ruby bin/bakery -m spec/testdata/root1/main -b wrong -w spec/testdata/root1 -w spec/testdata/root2`
    expect(str.include?("1 of 1 builds failed")).to be == true
  end  

  it 'collection error' do
    str = `ruby bin/bakery -m spec/testdata/root1/main -b error -w spec/testdata/root1 -w spec/testdata/root2 -r`
    expect(str.include?("bakery aborted")).to be == true
    expect(str.include?("Error: system command failed")).to be == false
    str = `ruby bin/bakery -m spec/testdata/root1/main -b error -w spec/testdata/root1 -w spec/testdata/root2`
    expect(str.include?("1 of 1 builds failed")).to be == true
  end

  it 'collection ref without -b' do
    str = `ruby bin/bakery -m spec/testdata/root1/main -b Combined -w spec/testdata/root1 -w spec/testdata/root2 -r`
    expect(str.include?("3 of 3 builds ok")).to be == true
    expect(str.include?("root1/lib1 -b test")).to be == true
    expect(str.include?("root2/lib2 -b test")).to be == true
    expect(str.include?("root1/main -b test")).to be == true
  end    
  
  it 'collection ref with -b' do
    str = `ruby bin/bakery -m spec/testdata/root1/main -b Combined -w spec/testdata/root1 -w spec/testdata/root2 -r`
    expect(str.include?("3 of 3 builds ok")).to be == true
    expect(str.include?("root1/lib1 -b test")).to be == true
    expect(str.include?("root2/lib2 -b test")).to be == true
    expect(str.include?("root1/main -b test")).to be == true
  end    

  it 'collection only ref to itself' do
    str = `ruby bin/bakery -m spec/testdata/root1/main -b Nothing -w spec/testdata/root1 -w spec/testdata/root2 -r`
    expect(str.include?("0 of 0 builds ok")).to be == true
  end    
  
  it 'collection invalid ref' do
    str = `ruby bin/bakery -m spec/testdata/root1/main -b InvalidRef -w spec/testdata/root1 -w spec/testdata/root2 -r`
    expect(str.include?("Collection Wrong not found")).to be == true
  end    

  it 'collection option ok' do
    str = `ruby bin/bakery -m spec/testdata/root1/main -b Combined -w spec/testdata/root1 -w spec/testdata/root2 -r --list`
    expect(str.include?("3 of 3 builds ok")).to be == true
  end  
  
  it 'collection option not ok' do
    str = `ruby bin/bakery -m spec/testdata/root1/main -b Combined -w spec/testdata/root1 -w spec/testdata/root2 --lint_min`
    expect(str.include?("Argument for option --lint_min missing")).to be == true
  end 
  
  it 'recursive test 1' do
    str = `ruby bin/bakery -m spec/testdata/recursiveBakery/gaga gaga`
    expect(str.include?("ONLYGAGA")).to be == true
    expect(str.include?("GAGAV")).to be == true
    expect(str.include?("GAGAW")).to be == true
    expect(str.include?("3 of 3 builds ok")).to be == true
  end 
  
  it 'recursive test 2' do
    str = `ruby bin/bakery -m spec/testdata/recursiveBakery/gaga gugu`
    expect(str.include?("GUGUV")).to be == true
    expect(str.include?("GUGUW")).to be == true
    expect(str.include?("2 of 2 builds ok")).to be == true
  end   
   
end

end
