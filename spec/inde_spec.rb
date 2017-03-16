#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'

module Bake

describe "Independent" do
=begin
  it 'Presteps' do
    Bake.startBake("independent/main", ["test_pre_abcd"])
    expect(ExitHelper.exit_code).to be == 0
    expect($mystring.include?("Building done")).to be == true

    posA = $mystring.index("(test_pre_a)")
    posB = $mystring.index("(test_pre_b)")
    posC = $mystring.index("(test_pre_c)")
    posD = $mystring.index("(test_pre_d)")
    posCMDA = $mystring.index("CMD_A")
    posCMDB = $mystring.index("CMD_B")
    posCMDC = $mystring.index("CMD_C")
    posCMDD = $mystring.index("CMD_D")

    expect((posA < posB)).to be == true
    expect((posB < posC)).to be == true
    expect((posC < posCMDA)).to be == true
    expect((posC < posCMDB)).to be == true
    expect((posC < posCMDC)).to be == true
    expect((posD > posCMDA)).to be == true
    expect((posD > posCMDB)).to be == true
    expect((posD > posCMDC)).to be == true
    expect((posD < posCMDD)).to be == true
  end

  it 'Presteps block' do
    Bake.startBake("independent/main", ["test_pre_abcd", "-O"])
    expect(ExitHelper.exit_code).to be == 0
    expect($mystring.include?("Building done")).to be == true

    posA = $mystring.index("(test_pre_a)")
    posB = $mystring.index("(test_pre_b)")
    posC = $mystring.index("(test_pre_c)")
    posD = $mystring.index("(test_pre_d)")
    posCMDA = $mystring.index("CMD_A")
    posCMDB = $mystring.index("CMD_B")
    posCMDC = $mystring.index("CMD_C")
    posCMDD = $mystring.index("CMD_D")

    expect((posA < posCMDA)).to be == true
    expect((posB < posCMDB)).to be == true
    expect((posC < posCMDC)).to be == true
    expect((posD < posCMDD)).to be == true

    expect((posA < posC)).to be == true
    expect((posB < posC)).to be == true
    expect((posC < posD)).to be == true
  end

  it 'Poststeps' do
    Bake.startBake("independent/main", ["test_post_abcd"])
    expect(ExitHelper.exit_code).to be == 0
    expect($mystring.include?("Building done")).to be == true

    posA = $mystring.index("(test_post_a)")
    posB = $mystring.index("(test_post_b)")
    posC = $mystring.index("(test_post_c)")
    posD = $mystring.index("(test_post_d)")
    posCMDA = $mystring.index("CMD_A")
    posCMDB = $mystring.index("CMD_B")
    posCMDC = $mystring.index("CMD_C")
    posCMDD = $mystring.index("CMD_D")

    expect((posA < posB)).to be == true
    expect((posB < posC)).to be == true
    expect((posC < posCMDA)).to be == true
    expect((posC < posCMDB)).to be == true
    expect((posC < posCMDC)).to be == true
    expect((posD > posCMDA)).to be == true
    expect((posD > posCMDB)).to be == true
    expect((posD > posCMDC)).to be == true
    expect((posD < posCMDD)).to be == true
  end

  it 'Poststeps block' do
    Bake.startBake("independent/main", ["test_post_abcd", "-O"])
    expect(ExitHelper.exit_code).to be == 0
    expect($mystring.include?("Building done")).to be == true

    posA = $mystring.index("(test_post_a)")
    posB = $mystring.index("(test_post_b)")
    posC = $mystring.index("(test_post_c)")
    posD = $mystring.index("(test_post_d)")
    posCMDA = $mystring.index("CMD_A")
    posCMDB = $mystring.index("CMD_B")
    posCMDC = $mystring.index("CMD_C")
    posCMDD = $mystring.index("CMD_D")

    expect((posA < posCMDA)).to be == true
    expect((posB < posCMDB)).to be == true
    expect((posC < posCMDC)).to be == true
    expect((posD < posCMDD)).to be == true

    expect((posA < posC)).to be == true
    expect((posB < posC)).to be == true
    expect((posC < posD)).to be == true
  end

  it 'MainSteps' do
    Bake.startBake("independent/main", ["test_abcd"])
    expect(ExitHelper.exit_code).to be == 0
    expect($mystring.include?("Building done")).to be == true

    posA = $mystring.index("(test_a)")
    posB = $mystring.index("(test_b)")
    posC = $mystring.index("(test_c)")
    posD = $mystring.index("(test_d)")
    posCMDA = $mystring.index("CMD_A")
    posCMDB = $mystring.index("CMD_B")
    posCMDC = $mystring.index("CMD_C")
    posCMDD = $mystring.index("CMD_D")

    expect((posA < posB)).to be == true
    expect((posB < posC)).to be == true
    expect((posC < posCMDA)).to be == true
    expect((posC < posCMDB)).to be == true
    expect((posC < posCMDC)).to be == true
    expect((posD > posCMDA)).to be == true
    expect((posD > posCMDB)).to be == true
    expect((posD > posCMDC)).to be == true
    expect((posD < posCMDD)).to be == true
  end

  it 'MainSteps block' do
    Bake.startBake("independent/main", ["test_abcd", "-O"])
    expect(ExitHelper.exit_code).to be == 0
    expect($mystring.include?("Building done")).to be == true

    posA = $mystring.index("(test_a)")
    posB = $mystring.index("(test_b)")
    posC = $mystring.index("(test_c)")
    posD = $mystring.index("(test_d)")
    posCMDA = $mystring.index("CMD_A")
    posCMDB = $mystring.index("CMD_B")
    posCMDC = $mystring.index("CMD_C")
    posCMDD = $mystring.index("CMD_D")

    expect((posA < posCMDA)).to be == true
    expect((posB < posCMDB)).to be == true
    expect((posC < posCMDC)).to be == true
    expect((posD < posCMDD)).to be == true

    expect((posA < posC)).to be == true
    expect((posB < posC)).to be == true
    expect((posC < posD)).to be == true
  end
=end

  it 'Lib' do
    Bake.startBake("independent/main", ["test_lib_abcd"])
    expect(ExitHelper.exit_code).to be == 0
    expect($mystring.include?("Building done")).to be == true

    posA = $mystring.index("b.cpp")
    posCMDA = $mystring.index("CMD_A")
    posCMDC = $mystring.index("CMD_C")
    posC = $mystring.index("c.cpp")

    expect((posA < posCMDA)).to be == true
    expect((posCMDA < posCMDC)).to be == true
    expect((posCMDC < posC)).to be == true
  end

  it 'Lib Block' do
    Bake.startBake("independent/main", ["test_lib_abcd", "-O"])
    expect(ExitHelper.exit_code).to be == 0
    expect($mystring.include?("Building done")).to be == true

    pos11 = $mystring.index("**** Building 1 of 5: main (test_lib_b) ****")
    pos12 = $mystring.index("Compiling main (test_lib_b): src/b.cpp")
    pos13 = $mystring.index("Creating  main (test_lib_b): build/test_lib_b_main_test_lib_abcd/libmain.a")
    pos14 = $mystring.index("**** Building 2 of 5: main (test_lib_a) ****")
    pos15 = $mystring.index("Compiling main (test_lib_a): src/a.cpp")
    pos16 = $mystring.index("Creating  main (test_lib_a): build/test_lib_a_main_test_lib_abcd/libmain.a")
    pos17 = $mystring.index("CMD_A")

    pos21 = $mystring.index("of 5: main (test_lib_d) ****")
    pos22 = $mystring.index("CMD_D")

    pos31 = $mystring.index("of 5: main (test_lib_c) ****")
    pos32 = $mystring.index("CMD_C")
    pos33 = $mystring.index("Compiling main (test_lib_c): src/c.cpp")
    pos34 = $mystring.index("Creating  main (test_lib_c): build/test_lib_c_main_test_lib_abcd/libmain.a")

    pos41 = $mystring.index("**** Building 5 of 5: main (test_lib_abcd) ****")
    pos42 = $mystring.index("Compiling main (test_lib_abcd): src/e.cpp")
    pos43 = $mystring.index("Linking   main (test_lib_abcd): build/test_lib_abcd/main.exe")

    expect((pos11 < pos21)).to be == true
    expect((pos11 < pos31)).to be == true
    expect((pos21 < pos41)).to be == true
    expect((pos31 < pos41)).to be == true

    expect((pos11 < pos12)).to be == true
    expect((pos12 < pos13)).to be == true
    expect((pos13 < pos14)).to be == true
    expect((pos14 < pos15)).to be == true
    expect((pos15 < pos16)).to be == true
    expect((pos16 < pos17)).to be == true

    expect((pos21 < pos22)).to be == true

    expect((pos31 < pos32)).to be == true
    expect((pos32 < pos33)).to be == true
    expect((pos33 < pos34)).to be == true

    expect((pos41 < pos42)).to be == true
    expect((pos42 < pos43)).to be == true
  end

end

end
