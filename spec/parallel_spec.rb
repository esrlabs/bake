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
    Bake.setStep(1)
    t = Thread.new() {
      Bake.startBake("parallel/C",[])
    }
    sleep 5
    expect($mystring.include?("a1.cpp")).to be == true
    expect($mystring.include?("a2.cpp")).to be == true
    expect($mystring.include?("a3.cpp")).to be == true
    expect($mystring.include?("b1.cpp")).to be == true
    expect($mystring.include?("b2.cpp")).to be == true
    expect($mystring.include?("b3.cpp")).to be == true
    expect($mystring.include?("c1.cpp")).to be == true
    expect($mystring.include?("c2.cpp")).to be == true
    expect($mystring.include?("c3.cpp")).to be == true
    expect($mystring.include?("libA")).to be == false
    expect($mystring.include?("libB")).to be == false
    expect($mystring.include?("Linking")).to be == false

    Bake.setStep(2)
    sleep 5
    expect($mystring.include?("libA")).to be == true
    expect($mystring.include?("libB")).to be == false
    expect($mystring.include?("Linking")).to be == false

    Bake.setStep(3)
    sleep 5
    expect($mystring.include?("libB")).to be == false
    expect($mystring.include?("Linking")).to be == false

    Bake.setStep(4)
    t.join()
    expect($mystring.include?("libB")).to be == true
    expect($mystring.include?("Linking")).to be == true
    expect(ExitHelper.exit_code).to be == 0

    expect($mystring.include?("MAX: 2")).to be == true
    expect($mystring.include?("MAX: 9")).to be == false
  end


  it '-j2' do

    File.open("spec/testdata/parallel/global.lock", 'wb') do |f|
      f.puts("0")
    end

    Bake.setStep(1)
    t = Thread.new() {
      Bake.startBake("parallel/C",["-j", "2"])
    }
    sleep 5
    expect($mystring.include?("c1.cpp")).to be == false
    expect($mystring.include?("c2.cpp")).to be == false
    expect($mystring.include?("c3.cpp")).to be == false
    expect($mystring.include?("libA")).to be == false
    expect($mystring.include?("libB")).to be == false
    expect($mystring.include?("Linking")).to be == false

    Bake.setStep(2)
    sleep 5
    expect($mystring.include?("libA")).to be == true
    expect($mystring.include?("libB")).to be == false
    expect($mystring.include?("Linking")).to be == false

    Bake.setStep(3)
    sleep 5
    expect($mystring.include?("c1.cpp")).to be == true
    expect($mystring.include?("c2.cpp")).to be == true
    expect($mystring.include?("c3.cpp")).to be == true
    expect($mystring.include?("libB")).to be == false
    expect($mystring.include?("Linking")).to be == false

    Bake.setStep(4)
    t.join()
    expect($mystring.include?("libB")).to be == true
    expect($mystring.include?("Linking")).to be == true
    expect(ExitHelper.exit_code).to be == 0

    expect($mystring.include?("MAX: 2")).to be == true
    expect($mystring.include?("MAX: 3")).to be == false
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
