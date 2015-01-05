#!/usr/bin/env ruby

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'
require 'helper'

module Bake

describe "Lint" do
  
  it 'project needed' do
    if Utils::OS.windows? 
      expect { Bake.startBake("stop/main", ["test1", "--lint"]) }.to raise_error(SystemExit)
      expect($mystring.include?("Error: --lint must be used together with -p")).to be == true
    end
  end
  
  it 'lint proj' do
    if Utils::OS.windows?
      Bake.startBake("stop/main", ["test1", "--lint", "-p", "main"])
      expect($mystring.split("Module:").length).to be == 4
    end
  end
  
  it 'lint proj diab' do
    if Utils::OS.windows?
      Bake.startBake("stop/main", ["testDiabLint", "--lint", "-p", "main"])
      expect($mystring.split("Module:").length).to be == 4
    end
  end
  
  it 'lint all files' do
    if Utils::OS.windows?
      Bake.startBake("stop/main", ["test1", "--lint", "-p", "main", "-f", "a"])
      expect($mystring.split("Module:").length).to be == 4
    end
  end  
  
  it 'lint one file' do
    if Utils::OS.windows?
      Bake.startBake("stop/main", ["test1", "--lint", "-p", "main", "-f", "maina"])
      expect($mystring.split("Module:").length).to be == 2
    end
  end   
 
  it 'lint no file' do
    if Utils::OS.windows?
      Bake.startBake("stop/main", ["test1", "--lint", "-p", "main", "-f", "x"])
      expect($mystring.split("Module:").length).to be == 1
    end
  end    
  
  it 'lint min' do
    if Utils::OS.windows?
      Bake.startBake("stop/main", ["test1", "--lint", "-p", "main", "--lint_min", "1"])
      expect($mystring.split("Module:").length).to be == 3
      expect($mystring.include?("mainb")).to be == true
      expect($mystring.include?("mainc")).to be == true
    end
  end    
  
  it 'lint max' do
    if Utils::OS.windows?
      Bake.startBake("stop/main", ["test1", "--lint", "-p", "main", "--lint_max", "1"])
      expect($mystring.split("Module:").length).to be == 3
      expect($mystring.include?("maina")).to be == true
      expect($mystring.include?("mainb")).to be == true
    end
  end   
  
  it 'lint minmax eq' do
    if Utils::OS.windows?
      Bake.startBake("stop/main", ["test1", "--lint", "-p", "main", "--lint_min", "1", "--lint_max", "1"])
      expect($mystring.split("Module:").length).to be == 2
      expect($mystring.include?("mainb")).to be == true
    end
  end   
  
  it 'lint minmax pos' do
    if Utils::OS.windows?
      Bake.startBake("stop/main", ["test1", "--lint", "-p", "main", "--lint_min", "1", "--lint_max", "2"])
      expect($mystring.split("Module:").length).to be == 3
      expect($mystring.include?("mainb")).to be == true
      expect($mystring.include?("mainc")).to be == true
    end
  end   
  
  it 'lint minmax neg' do
    if Utils::OS.windows?
      Bake.startBake("stop/main", ["test1", "--lint", "-p", "main", "--lint_min", "2", "--lint_max", "1"])
      expect($mystring.split("Module:").length).to be == 1
      expect($mystring.include?("Info: No files to lint")).to be == true
    end
  end     
  
  it 'lint min too high' do
    if Utils::OS.windows?
      Bake.startBake("stop/main", ["test1", "--lint", "-p", "main", "--lint_min", "3"])
      expect($mystring.split("Module:").length).to be == 1
      expect($mystring.include?("Info: No files to lint")).to be == true
    end
  end    

  it 'lint multi proj' do
    if Utils::OS.windows?
      Bake.startBake("multiProj/main", ["test1", "--lint", "-p", "main"])
      expect($mystring.split("Module:").length).to be == 3
      expect($mystring.include?("Linting failed.")).to be == true
    end
  end 
  
end

end
