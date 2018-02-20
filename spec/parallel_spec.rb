#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'

module Bake

  def self.setStep(step)
    File.open("spec/testdata/parallel/step.txt", 'wb') do |f|
      STDERR.puts "Set step to #{step}"
      f.puts(step.to_s)
    end
  end

describe "Parallel" do

  it '-j8' do

    File.open("spec/testdata/parallel/global.lock", 'wb') do |f|
      f.puts("0")
    end

    Bake.setStep(1)
    t = Thread.new() {
      inc = proc {|e| $mystring.include?(e) }

      sleep 5
      checks = []
      checks << ["a1.cpp", "a2.cpp", "a3.cpp", "b1.cpp", "b2.cpp", "b3.cpp", "c1.cpp", "c2.cpp", "c3.cpp"].all?(&inc)
      checks << ["libA", "libB", "Linking"].none?(&inc)


      Bake.setStep(2)
      sleep 5
      checks << ["libA"].all?(&inc)
      checks << ["libB", "Linking"].none?(&inc)

      Bake.setStep(3)
      sleep 5
      checks << ["libB", "Linking"].none?(&inc)

      Bake.setStep(4)
      sleep 5
      checks << ["libB", "Linking"].all?(&inc)

      checks
    }
    Bake.startBake("parallel/C",[])
    t.join()
    checks = t.value
    expect(checks.all?{|c| c}).to be == true
    expect($mystring.include?("MAX: 2")).to be == true
    expect($mystring.include?("MAX: 9")).to be == false

  end

  it '-j2' do

    File.open("spec/testdata/parallel/global.lock", 'wb') do |f|
      f.puts("0")
    end

    Bake.setStep(1)
    t = Thread.new() {
      inc = proc {|e| $mystring.include?(e) }

      sleep 5
      checks = []
      checks << ["c1.cpp", "c2.cpp", "c3.cpp", "libA", "libB", "Linking"].none?(&inc)


      Bake.setStep(2)
      sleep 5
      checks << ["libA"].all?(&inc)
      checks << ["libB", "Linking"].none?(&inc)

      Bake.setStep(3)
      sleep 5
      checks << ["c1.cpp", "c2.cpp", "c3.cpp"].all?(&inc)
      checks << ["libB", "Linking"].none?(&inc)

      Bake.setStep(4)
      sleep 5
      checks << ["libB", "Linking"].all?(&inc)

      checks
    }

    Bake.startBake("parallel/C",["-j", "2"])
    t.join()
    checks = t.value
    expect(checks.all?{|c| c}).to be == true
    expect($mystring.include?("MAX: 2")).to be == true
    expect($mystring.include?("MAX: 5")).to be == false

  end

  it 'Steps' do
    10.times do |i|
      $sstring.reopen($mystring,"w+")

      Bake.startBake("parallel/C",["test_steps", "--do", "steps", "--rebuild", "-j", "#{i+1}"])
      expect(ExitHelper.exit_code).to be == 0

      posLibA = $mystring.index("libA.a")
      posPostStep = $mystring.index("POSTSTEP")
      posB = $mystring.index("2 of 3: B")
      posSrcB= $mystring.index("src/b")
      posLibB= $mystring.index("libB.a")
      posPreStep = $mystring.index("PRESTEP")
      posSrcC = $mystring.index("src/c")

      expect(posLibA<posPostStep).to be == true
      expect(posPostStep<posB).to be == true
      expect(posB<posSrcB).to be == true
      expect(posSrcB<posLibB).to be == true
      expect(posLibB<posPreStep).to be == true
      expect(posPreStep<posSrcC).to be == true
    end
  end

  it 'Custom' do
    Bake.startBake("parallel/C",["test_custom"])
    expect(ExitHelper.exit_code).to be == 0

    posLibA = $mystring.index("libA.a")
    posCustom = $mystring.index("CUSTOM")
    posSrcC= $mystring.index("src/c")

    expect(posLibA<posCustom).to be == true
    expect(posCustom<posSrcC).to be == true
  end

end

end
