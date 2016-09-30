#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'

module Bake

describe "Lint" do

  it 'lint installed' do
    begin
      `lint-nt.exe -v`
      $lintInstalled = true
    rescue Exception
      if not Bake.ciRunning?
        fail "lint not installed" # fail only once on non lint systems
      end
    end
  end

  it 'lint zero' do
    if $lintInstalled
      Bake.startBake("stop/main", ["test1", "--lint", "-p", "main"])
      expect($mystring.include?("Error")).to be == true
      expect(ExitHelper.exit_code).to be == 0
    end
  end

  it 'lint proj' do
    if $lintInstalled
      Bake.startBake("stop/main", ["test1", "--lint", "-p", "main"])
      expect($mystring.split("Module:").length).to be == 4
    end
  end

  it 'lint proj diab' do
    if $lintInstalled
      Bake.startBake("stop/main", ["testDiabLint", "--lint", "-p", "main"])
      expect($mystring.split("Module:").length).to be == 4
    end
  end

  it 'lint all files' do
    if $lintInstalled
      Bake.startBake("stop/main", ["test1", "--lint", "-p", "main", "-f", "a"])
      expect($mystring.split("Module:").length).to be == 4
    end
  end

  it 'lint one file' do
    if $lintInstalled
      Bake.startBake("stop/main", ["test1", "--lint", "-p", "main", "-f", "maina"])
      expect($mystring.split("Module:").length).to be == 2
    end
  end

  it 'lint no file' do
    if $lintInstalled
      Bake.startBake("stop/main", ["test1", "--lint", "-p", "main", "-f", "x"])
      expect($mystring.split("Module:").length).to be == 1
    end
  end

  it 'lint min' do
    if $lintInstalled
      Bake.startBake("stop/main", ["test1", "--lint", "-p", "main", "--lint-min", "1"])
      expect($mystring.split("Module:").length).to be == 3
      expect($mystring.include?("mainb")).to be == true
      expect($mystring.include?("mainc")).to be == true
    end
  end

  it 'lint max' do
    if $lintInstalled
      Bake.startBake("stop/main", ["test1", "--lint", "-p", "main", "--lint-max", "1"])
      expect($mystring.split("Module:").length).to be == 3
      expect($mystring.include?("maina")).to be == true
      expect($mystring.include?("mainb")).to be == true
    end
  end

  it 'lint minmax eq' do
    if $lintInstalled
      Bake.startBake("stop/main", ["test1", "--lint", "-p", "main", "--lint-min", "1", "--lint-max", "1"])
      expect($mystring.split("Module:").length).to be == 2
      expect($mystring.include?("mainb")).to be == true
    end
  end

  it 'lint minmax pos' do
    if $lintInstalled
      Bake.startBake("stop/main", ["test1", "--lint", "-p", "main", "--lint_min", "1", "--lint_max", "2"])
      expect($mystring.split("Module:").length).to be == 3
      expect($mystring.include?("mainb")).to be == true
      expect($mystring.include?("mainc")).to be == true
    end
  end

  it 'lint minmax neg' do
    if $lintInstalled
      Bake.startBake("stop/main", ["test1", "--lint", "-p", "main", "--lint_min", "2", "--lint_max", "1"])
      expect($mystring.split("Module:").length).to be == 1
      expect($mystring.include?("Info: No files to lint")).to be == true
    end
  end

  it 'lint min too high' do
    if $lintInstalled
      Bake.startBake("stop/main", ["test1", "--lint", "-p", "main", "--lint_min", "3"])
      expect($mystring.split("Module:").length).to be == 1
      expect($mystring.include?("Info: No files to lint")).to be == true
    end
  end

  it 'lint multi proj' do
    if $lintInstalled
      Bake.startBake("multiProj/main", ["test1", "--lint", "-p", "main"])
      expect($mystring.split("Module:").length).to be == 3
      expect($mystring.include?("Linting done.")).to be == true
    end
  end

end

end
