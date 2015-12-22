#!/usr/bin/env ruby

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'
require 'helper'

module Bake

describe "Version" do
  
  it 'minimumOK' do
    Bake.startBake("version/minimumOK", ["test"])
    expect($mystring.include?("DONE")).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end
  it 'minimumNOK1' do
    Bake.startBake("version/minimumNOK1", ["test"])
    expect($mystring.include?("DONE")).to be == false
    expect(ExitHelper.exit_code).to be > 0
  end  
  it 'minimumNOK2' do
    Bake.startBake("version/minimumNOK2", ["test"])
    expect($mystring.include?("DONE")).to be == false
    expect(ExitHelper.exit_code).to be > 0
  end
  
  it 'maximumOK' do
    Bake.startBake("version/maximumOK", ["test"])
    expect($mystring.include?("DONE")).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end
  it 'maximumNOK1' do
    Bake.startBake("version/maximumNOK1", ["test"])
    expect($mystring.include?("DONE")).to be == false
    expect(ExitHelper.exit_code).to be > 0
  end 
  it 'maximumNOK2' do
    Bake.startBake("version/maximumNOK2", ["test"])
    expect($mystring.include?("DONE")).to be == false
    expect(ExitHelper.exit_code).to be > 0
  end 
  
  it 'minimumOKmaximumOK' do
    Bake.startBake("version/minimumOKmaximumOK", ["test"])
    expect($mystring.include?("DONE")).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end
  
  it 'noVersion' do
    Bake.startBake("version/noVersion", ["test"])
    expect($mystring.include?("DONE")).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end 
  it 'wrongNumber1' do
    Bake.startBake("version/wrongNumber1", ["test"])
    expect($mystring.include?("DONE")).to be == false
    expect(ExitHelper.exit_code).to be > 0
  end 
  it 'wrongNumber2' do
    Bake.startBake("version/wrongNumber2", ["test"])
    expect($mystring.include?("DONE")).to be == false
    expect(ExitHelper.exit_code).to be > 0
  end    
end

end
