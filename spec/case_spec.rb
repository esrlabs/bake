#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'

module Bake

describe "Case" do

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

end

end
