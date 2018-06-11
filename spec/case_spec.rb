#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'

module Bake

describe "Case" do

  it 'dcc installed' do
    begin
      `dcc`
      $dccInstalled = true
    rescue Exception
    end
  end

  it 'case errors' do
    if Bake::Utils::OS.windows?
      Bake.startBake("case/main", [])

      expect($mystring.include?("**** Building 1 of 1: main (test) ****")).to be == true
      expect($mystring.include?("Compiling main (test): src/file1.cpp")).to be == true
      expect($mystring.include?("Compiling main (test): src/file2.cpp")).to be == true
      expect($mystring.include?("Case sensitivity error in src/file2.cpp:")).to be == true
      expect($mystring.include?("  included: inc/i2.h")).to be == true
      expect($mystring.include?("  realname: INC/i2.h")).to be == true
      expect($mystring.include?("Case sensitivity error in src/file1.cpp:")).to be == true
      expect($mystring.include?("  included: include/I1.h")).to be == true
      expect($mystring.include?("  realname: include/i1.h")).to be == true
      expect($mystring.include?("Building failed.")).to be == true

      expect(ExitHelper.exit_code).to be > 0
    end
  end

  it 'no case errors' do
    if Bake::Utils::OS.windows?
      Bake.startBake("case/main", ["--no-case-check"])

      expect($mystring.include?("**** Building 1 of 1: main (test) ****")).to be == true
      expect($mystring.include?("Compiling main (test): src/file1.cpp")).to be == true
      expect($mystring.include?("Compiling main (test): src/file2.cpp")).to be == true
      expect($mystring.include?("Case sensitivity error in src/file2.cpp:")).to be == false
      expect($mystring.include?("  included: inc/i2.h")).to be == false
      expect($mystring.include?("  realname: INC/i2.h")).to be == false
      expect($mystring.include?("Case sensitivity error in src/file1.cpp:")).to be == false
      expect($mystring.include?("  included: include/I1.h")).to be == false
      expect($mystring.include?("  realname: include/i1.h")).to be == false
      expect($mystring.include?("Building done.")).to be == true

      expect(ExitHelper.exit_code).to be == 0
    end
  end

  it 'dcc case errors' do
    if Bake::Utils::OS.windows? and $dccInstalled
      begin
      Bake.startBake("case/main", ["test_diab", "--diab-case-check"])
      rescue Exception => e

      end

      expect($mystring.include?("**** Building 1 of 1: main (test_diab) ****")).to be == true
      expect($mystring.include?("Compiling main (test_diab): src/file1.cpp")).to be == true
      expect($mystring.include?("Compiling main (test_diab): src/file2.cpp")).to be == true
      expect($mystring.include?("Case sensitivity error in src/file2.cpp:")).to be == true
      expect($mystring.include?("  included: inc/i2.h")).to be == true
      expect($mystring.include?("  realname: INC/i2.h")).to be == true
      expect($mystring.include?("Case sensitivity error in src/file1.cpp:")).to be == true
      expect($mystring.include?("  included: include/I1.h")).to be == true
      expect($mystring.include?("  realname: include/i1.h")).to be == true
      expect($mystring.include?("Building failed.")).to be == true

      expect(ExitHelper.exit_code).to be > 0
    end
  end

  it 'dcc no case errors 1' do
    if Bake::Utils::OS.windows? and $dccInstalled
      Bake.startBake("case/main", ["test_diab", "--no-case-check"])

      expect($mystring.include?("**** Building 1 of 1: main (test_diab) ****")).to be == true
      expect($mystring.include?("Compiling main (test_diab): src/file1.cpp")).to be == true
      expect($mystring.include?("Compiling main (test_diab): src/file2.cpp")).to be == true
      expect($mystring.include?("Case sensitivity error in src/file2.cpp:")).to be == false
      expect($mystring.include?("  included: inc/i2.h")).to be == false
      expect($mystring.include?("  realname: INC/i2.h")).to be == false
      expect($mystring.include?("Case sensitivity error in src/file1.cpp:")).to be == false
      expect($mystring.include?("  included: include/I1.h")).to be == false
      expect($mystring.include?("  realname: include/i1.h")).to be == false
      expect($mystring.include?("Building done.")).to be == true

      expect(ExitHelper.exit_code).to be == 0
    end
  end

  it 'dcc no case errors 2' do
    if Bake::Utils::OS.windows? and $dccInstalled
      Bake.startBake("case/main", ["test_diab"])

      expect($mystring.include?("**** Building 1 of 1: main (test_diab) ****")).to be == true
      expect($mystring.include?("Compiling main (test_diab): src/file1.cpp")).to be == true
      expect($mystring.include?("Compiling main (test_diab): src/file2.cpp")).to be == true
      expect($mystring.include?("Case sensitivity error in src/file2.cpp:")).to be == false
      expect($mystring.include?("  included: inc/i2.h")).to be == false
      expect($mystring.include?("  realname: INC/i2.h")).to be == false
      expect($mystring.include?("Case sensitivity error in src/file1.cpp:")).to be == false
      expect($mystring.include?("  included: include/I1.h")).to be == false
      expect($mystring.include?("  realname: include/i1.h")).to be == false
      expect($mystring.include?("Building done.")).to be == true#

      expect(ExitHelper.exit_code).to be == 0
    end
  end

  it 'dcc no-check-check and diab-case-check' do
    if Bake::Utils::OS.windows? and $dccInstalled
      begin
      Bake.startBake("case/main", ["test_diab", "--no-case-check", "--diab-case-check"])
      rescue Exception
      end

      expect($mystring.include?("**** Building 1 of 1: main (test_diab) ****")).to be == false
      expect($mystring.include?("Error: --no-case-check and --diab-case-check not allowed at the same time")).to be == true
      expect(ExitHelper.exit_code).to be > 0
    end
  end

end

end
