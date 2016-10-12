#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'

module Bake

  def self.startBakeqac(proj, opt)
    cmd = ["ruby", "bin/bakeqac","-m", "spec/testdata/#{proj}"].concat(opt).join(" ")
    puts `#{cmd}`
    Bake::cleanup
  end

describe "Qac" do

  it 'qac installed' do
    begin
      `qacli --version`
      $qacInstalled = true
    rescue Exception
      if not Bake.ciRunning?
        fail "qac not installed" # fail only once on non qac systems
      end
    end
  end

  it 'standard' do
    if $qacInstalled

      Bake.startBakeqac("qac/main", ["test_template"])

      $mystring.gsub!(/\\/,"/")

      expect($mystring.include?("bakeqac: creating database...")).to be == true
      expect($mystring.include?("bakeqac: building and analyzing files...")).to be == true
      expect($mystring.include?("bakeqac: printing results...")).to be == true
      expect($mystring.include?("bakeqac: printing results...")).to be == true

      expect($mystring.include?("spec/testdata/qac/lib/src/lib.cpp")).to be == true
      expect($mystring.include?("spec/testdata/qac/main/include/A.h")).to be == true
      expect($mystring.include?("spec/testdata/qac/main/src/main.cpp")).to be == true

      expect($mystring.include?("spec/testdata/qac/main/mock/src/mock.cpp")).to be == false
      expect($mystring.include?("spec/testdata/qac/gtest/src/gtest.cpp")).to be == false

      expect(ExitHelper.exit_code).to be == 0
    end
  end

end

end
