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
    exit_code = $?.exitstatus
    Bake::cleanup
    exit_code
  end

  def self.getCct(cVersion = "")
    gccVersion = Bake::Toolchain::getGccVersion

    if RUBY_PLATFORM =~ /mingw/
      plStr = "w64-mingw32"
    elsif RUBY_PLATFORM =~ /cygwin/
      plStr = "pc-cygwin"
    else
      plStr = "generic-linux"
    end

    cct = ""
    while (cct == "" or gccVersion[0]>=5)
      cct = "config/cct/GNU_GCC-g++_#{gccVersion[0]}.#{gccVersion[1]}-i686-#{plStr}-C++#{cVersion}.cct"
      break if File.exist?cct[0]
      cct = "config/cct/GNU_GCC-g++_#{gccVersion[0]}.#{gccVersion[1]}-x86_64-#{plStr}-C++#{cVersion}.cct"
      break if File.exist?cct[0]
      if gccVersion[1]>0
        gccVersion[1] -= 1
      else
        gccVersion[0] -= 1
        gccVersion[1] = 20
      end
    end

    return cct
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

  it 'integration test' do
    if $qacInstalled

      exit_code = Bake.startBakeqac("qac/main", ["test_template", "--qacretry", "60", "--qacdoc"])

      $mystring.gsub!(/\\/,"/")

      expect($mystring.include?("bakeqac: creating database...")).to be == true
      expect($mystring.include?("bakeqac: building and analyzing files...")).to be == true
      expect($mystring.include?("bakeqac: printing results...")).to be == true

      expect($mystring.include?("spec/testdata/qac/lib/src/lib.cpp")).to be == true
      expect($mystring.include?("spec/testdata/qac/main/include/A.h")).to be == true
      expect($mystring.include?("spec/testdata/qac/main/src/main.cpp")).to be == true

      expect($mystring.include?("spec/testdata/qac/main/mock/src/mock.cpp")).to be == false
      expect($mystring.include?("spec/testdata/qac/gtest/src/gtest.cpp")).to be == false

      expect($mystring.include?("doc: ")).to be == true

      expect(exit_code).to be == 0
    end
  end

  it 'version' do
    exit_code = Bake.startBakeqac("qac/main", ["--version"])
    expect($mystring.include?("-- bakeqac")).to be == true
    expect($mystring.include?("bakeqac: creating database...")).to be == false
    expect(exit_code).to be == 0
  end

  it 'help1' do
    exit_code = Bake.startBakeqac("qac/main", ["-h"])
    expect($mystring.include?("Usage:")).to be == true
    expect($mystring.include?("bakeqac: creating database...")).to be == false
    expect(exit_code).to be == 0
  end

  it 'help2' do
    exit_code = Bake.startBakeqac("qac/main", ["--help"])
    expect($mystring.include?("Usage:")).to be == true
    expect($mystring.include?("bakeqac: creating database...")).to be == false
    expect(exit_code).to be == 0
  end

  it 'simple test' do
    ENV["QAC_HOME"] = File.dirname(__FILE__)+"/bin\\"
    ENV["QAC_UT"] = "steps_ok"
    exit_code = Bake.startBakeqac("qac/main", ["--qacunittest"])
    expect($mystring.include?("bakeqac: creating database...")).to be == true
    expect($mystring.include?("bakeqac: building and analyzing files...")).to be == true
    expect($mystring.include?("bakeqac: printing results...")).to be == true
    expect($mystring.include?("Number of messages: 0")).to be == true
    expect(exit_code).to be == 0
  end

  it 'no_home' do
    ENV.delete("QAC_HOME")
    exit_code = Bake.startBakeqac("qac/main", ["--qacunittest"])
    expect($mystring.include?("Error: specify the environment variable QAC_HOME.")).to be == true
    expect($mystring.include?("bakeqac: creating database...")).to be == false
    expect(exit_code).to be > 0
  end

  it 'home' do
    ENV["QAC_HOME"] = File.dirname(__FILE__)+"/bin\\"
    ENV["QAC_UT"] = "home"
    exit_code = Bake.startBakeqac("qac/main", ["--qacstep", "admin", "--qacunittest"])
    expect($mystring.include?("bakeqac: creating database...")).to be == true
    expect($mystring.include?("bake/spec/bin = HOME")).to be == true
    expect(exit_code).to be == 0
  end

  it 'wrong_step' do
    ENV["QAC_HOME"] = File.dirname(__FILE__)+"/bin\\"
    exit_code = Bake.startBakeqac("qac/main", ["--qacstep", "\"wrong|admin\"", "--qacunittest"])
    expect($mystring.include?("Error: incorrect qacstep name.")).to be == true
    expect($mystring.include?("bakeqac: creating database...")).to be == false
    expect(exit_code).to be > 0
  end

  it 'steps_all1' do
    ENV["QAC_HOME"] = File.dirname(__FILE__)+"/bin\\"
    ENV["QAC_UT"] = "steps_ok"
    exit_code = Bake.startBakeqac("qac/main", ["--qacunittest"])
    expect($mystring.include?("bakeqac: creating database...")).to be == true
    expect($mystring.include?("bakeqac: building and analyzing files...")).to be == true
    expect($mystring.include?("bakeqac: printing results...")).to be == true
    expect(exit_code).to be == 0
  end

  it 'steps_all2' do
    ENV["QAC_HOME"] = File.dirname(__FILE__)+"/bin\\"
    ENV["QAC_UT"] = "steps_ok"
    exit_code = Bake.startBakeqac("qac/main", ["--qacstep", "\"admin|view|analyze\"", "--qacunittest"])
    expect($mystring.include?("bakeqac: creating database...")).to be == true
    expect($mystring.include?("bakeqac: building and analyzing files...")).to be == true
    expect($mystring.include?("bakeqac: printing results...")).to be == true
    expect(exit_code).to be == 0
  end

  it 'steps_failureAdmin' do
    ENV["QAC_HOME"] = File.dirname(__FILE__)+"/bin\\"
    ENV["QAC_UT"] = "steps_failureAdmin"
    exit_code = Bake.startBakeqac("qac/main", ["--qacunittest"])
    expect($mystring.include?("bakeqac: creating database...")).to be == true
    expect($mystring.include?("bakeqac: building and analyzing files...")).to be == false
    expect($mystring.include?("bakeqac: printing results...")).to be == false
    expect(exit_code).to be > 0
  end

  it 'steps_failureAnalyze' do
    ENV["QAC_HOME"] = File.dirname(__FILE__)+"/bin\\"
    ENV["QAC_UT"] = "steps_failureAnalyze"
    exit_code = Bake.startBakeqac("qac/main", ["--qacunittest"])
    expect($mystring.include?("bakeqac: creating database...")).to be == true
    expect($mystring.include?("bakeqac: building and analyzing files...")).to be == true
    expect($mystring.include?("bakeqac: printing results...")).to be == false
    expect(exit_code).to be > 0
  end

  it 'steps_failureView' do
    ENV["QAC_HOME"] = File.dirname(__FILE__)+"/bin\\"
    ENV["QAC_UT"] = "steps_failureView"
    exit_code = Bake.startBakeqac("qac/main", ["--qacunittest"])
    expect($mystring.include?("bakeqac: creating database...")).to be == true
    expect($mystring.include?("bakeqac: building and analyzing files...")).to be == true
    expect($mystring.include?("bakeqac: printing results...")).to be == true
    expect(exit_code).to be > 0
  end

  it 'steps_onlyAdmin' do
    ENV["QAC_HOME"] = File.dirname(__FILE__)+"/bin\\"
    ENV["QAC_UT"] = "steps_ok"
    exit_code = Bake.startBakeqac("qac/main", ["--qacstep", "admin", "--qacunittest"])
    expect($mystring.include?("bakeqac: creating database...")).to be == true
    expect($mystring.include?("bakeqac: building and analyzing files...")).to be == false
    expect($mystring.include?("bakeqac: printing results...")).to be == false
    expect(exit_code).to be == 0
  end

  it 'steps_onlyAnalyze' do
    ENV["QAC_HOME"] = File.dirname(__FILE__)+"/bin\\"
    ENV["QAC_UT"] = "steps_ok"
    exit_code = Bake.startBakeqac("qac/main", ["--qacstep", "analyze", "--qacunittest"])
    expect($mystring.include?("bakeqac: creating database...")).to be == false
    expect($mystring.include?("bakeqac: building and analyzing files...")).to be == true
    expect($mystring.include?("bakeqac: printing results...")).to be == false
    expect(exit_code).to be == 0
  end

  it 'steps_onlyView' do
    ENV["QAC_HOME"] = File.dirname(__FILE__)+"/bin\\"
    ENV["QAC_UT"] = "steps_ok"
    exit_code = Bake.startBakeqac("qac/main", ["--qacstep", "view", "--qacunittest"])
    expect($mystring.include?("bakeqac: creating database...")).to be == false
    expect($mystring.include?("bakeqac: building and analyzing files...")).to be == false
    expect($mystring.include?("bakeqac: printing results...")).to be == true
    expect(exit_code).to be == 0
  end

  it 'steps_AnalyzeAndView' do
    ENV["QAC_HOME"] = File.dirname(__FILE__)+"/bin\\"
    ENV["QAC_UT"] = "steps_ok"
    exit_code = Bake.startBakeqac("qac/main", ["--qacstep", "\"analyze|view\"", "--qacunittest"])
    expect($mystring.include?("bakeqac: creating database...")).to be == false
    expect($mystring.include?("bakeqac: building and analyzing files...")).to be == true
    expect($mystring.include?("bakeqac: printing results...")).to be == true
    expect(exit_code).to be == 0
  end

  it 'steps_qacdata' do
    ENV["QAC_HOME"] = File.dirname(__FILE__)+"/bin\\"
    ENV["QAC_UT"] = "steps_qacdata"
    exit_code = Bake.startBakeqac("qac/main", ["--qacunittest", "--qacnofilter"])
    expect($mystring.include?("admin: *.qacdata*")).to be == true
    expect($mystring.include?("analyze: *.qacdata*")).to be == true
    expect($mystring.include?("view: *.qacdata*")).to be == true
    expect(exit_code).to be == 0
  end

  it 'steps_qacdataUser' do
    ENV["QAC_HOME"] = File.dirname(__FILE__)+"/bin\\"
    ENV["QAC_UT"] = "steps_qacdata"
    exit_code = Bake.startBakeqac("qac/main", ["--qacunittest", "--qacdata", "\"testQacData\\bla\"", "--qacnofilter"])
    expect($mystring.include?("admin: *testQacData/bla*")).to be == true
    expect($mystring.include?("analyze: *testQacData/bla*")).to be == true
    expect($mystring.include?("view: *testQacData/bla*")).to be == true
    expect(exit_code).to be == 0
  end

  it 'acf_user' do
    ENV["QAC_HOME"] = File.dirname(__FILE__)+"/bin\\"
    ENV["QAC_UT"] = "config_files"
    exit_code = Bake.startBakeqac("qac/main", ["--qacunittest", "--qacstep", "admin", "--acf", "\"bla\\fasel\""])
    expect($mystring.include?("bla/fasel - ACF")).to be == true
    expect(exit_code).to be == 0
  end

  it 'acf_default' do
    ENV["QAC_HOME"] = File.dirname(__FILE__)+"/bin\\"
    ENV["QAC_UT"] = "config_files"
    exit_code = Bake.startBakeqac("qac/main", ["--qacunittest", "--qacstep", "admin"])
    expect($mystring.include?("config/acf/default.acf - ACF")).to be == true
    expect(exit_code).to be == 0
  end

  it 'rcf_user' do
    ENV["QAC_HOME"] = File.dirname(__FILE__)+"/bin\\"
    ENV["QAC_UT"] = "config_files"
    exit_code = Bake.startBakeqac("qac/main", ["--qacunittest", "--qacstep", "admin", "--rcf", "\"bla\\fasel\""])
    expect($mystring.include?("bla/fasel - RCF")).to be == true
    expect(exit_code).to be == 0
  end

  it 'rcf_default' do
    ENV["QAC_HOME"] = File.dirname(__FILE__)+"/bin\\"
    ENV["QAC_UT"] = "config_files"
    exit_code = Bake.startBakeqac("qac/main", ["--qacunittest", "--qacstep", "admin"])
    expect($mystring.include?("config/rcf/mcpp-1_5_1-en_US.rcf - RCF")).to be == true
    expect(exit_code).to be == 0
  end

  it 'rcf_file' do
    ENV["QAC_HOME"] = File.dirname(__FILE__)+"/bin\\"
    ENV["QAC_UT"] = "config_files"
    FileUtils.cp("spec/testdata/qac/_qac.rcf", "spec/testdata/qac/qac.rcf")
    exit_code = Bake.startBakeqac("qac/main", ["--qacunittest", "--qacstep", "admin"])
    expect($mystring.include?("qac/qac.rcf - RCF")).to be == true
    expect(exit_code).to be == 0
    FileUtils.rm_f("spec/testdata/qac/qac.rcf")
  end

  it 'cct user_1' do
    ENV["QAC_HOME"] = File.dirname(__FILE__)+"/bin\\"
    ENV["QAC_UT"] = "config_files"
    exit_code = Bake.startBakeqac("qac/main", ["--qacunittest", "--qacstep", "admin", "--cct", "\"bla\\fasel\""])
    expect($mystring.include?("bla/fasel - CCT")).to be == true
    expect(exit_code).to be == 0
  end

  it 'cct user_2' do
    ENV["QAC_HOME"] = File.dirname(__FILE__)+"/bin\\"
    ENV["QAC_UT"] = "config_files"
    exit_code = Bake.startBakeqac("qac/main", ["--qacunittest", "--qacstep", "admin", "--cct", "\"bla\\fasel\"", "--cct", "more"])
    expect($mystring.include?("bla/fasel - CCT")).to be == true
    expect($mystring.include?("more - CCT")).to be == true
    expect(exit_code).to be == 0
  end

  it 'cct auto' do
    ENV["QAC_HOME"] = File.dirname(__FILE__)+"/bin\\"
    ENV["QAC_UT"] = "config_files"
    exit_code = Bake.startBakeqac("qac/main", ["--qacunittest", "--qacstep", "admin"])
    expect($mystring.include?("#{Bake.getCct} - CCT")).to be == true
    expect(exit_code).to be == 0
  end

  it 'cct auto 11' do
    ENV["QAC_HOME"] = File.dirname(__FILE__)+"/bin\\"
    ENV["QAC_UT"] = "config_files"
    exit_code = Bake.startBakeqac("qac/main", ["--qacunittest", "--qacstep", "admin", "--c++11"])
      puts Bake.getCct("--c++11")
    expect($mystring.include?("#{Bake.getCct("-c++11")} - CCT")).to be == true
    expect(exit_code).to be == 0
  end

  it 'cct auto 14' do
    ENV["QAC_HOME"] = File.dirname(__FILE__)+"/bin\\"
    ENV["QAC_UT"] = "config_files"
    exit_code = Bake.startBakeqac("qac/main", ["--qacunittest", "--qacstep", "admin", "--c++14"])
    expect($mystring.include?("#{Bake.getCct("-c++14")} - CCT")).to be == true
    expect(exit_code).to be == 0
  end

  it 'main dir not found' do
    ENV["QAC_HOME"] = File.dirname(__FILE__)+"/bin\\"
    exit_code = Bake.startBakeqac("qac/main2", ["--qacunittest"])
    expect($mystring.include?("Error: Directory spec/testdata/qac/main2 does not exist")).to be == true
    expect(exit_code).to be > 0
  end

  it 'main dir not found' do
    ENV["QAC_HOME"] = File.dirname(__FILE__)+"/bin\\"
    exit_code = Bake.startBakeqac("qac/main/Project.meta", ["--qacunittest"])
    expect($mystring.include?("Error: spec/testdata/qac/main/Project.meta is not a directory")).to be == true
    expect(exit_code).to be > 0
  end

  it 'oldformat' do
    ENV["QAC_HOME"] = File.dirname(__FILE__)+"/bin\\"
    ENV["QAC_UT"] = "old_format"
    exit_code = Bake.startBakeqac("qac/main", ["--qacunittest", "-b", "Dummy", "--qacrawformat"])

    expect($mystring.include?("FORMAT: old")).to be == true
    expect($mystring.include?("Number of messages: 4")).to be == true
    expect(exit_code).to be == 0
  end

  it 'newformat' do
    ENV["QAC_HOME"] = File.dirname(__FILE__)+"/bin\\"
    ENV["QAC_UT"] = "new_format"
    exit_code = Bake.startBakeqac("qac/main", ["--qacunittest"])

    expect($mystring.include?("FORMAT: new")).to be == true
    expect($mystring.include?("Number of messages: 5")).to be == true
    expect(exit_code).to be == 0
  end

  it 'filter' do
    ENV["QAC_HOME"] = File.dirname(__FILE__)+"/bin\\"
    ENV["QAC_UT"] = "new_format"
    exit_code = Bake.startBakeqac("qac/main", ["--qacunittest"])
    expect($mystring.include?("rspec/lib1")).to be == true
    expect($mystring.include?("rspec/lib2")).to be == true
    expect($mystring.include?("rspec/lib3")).to be == false
    expect($mystring.include?("rspec/lib1/test")).to be == false
    expect($mystring.include?("rspec/lib1/mock")).to be == false
    expect($mystring.include?("rspec/gmook")).to be == false
    expect($mystring.include?("rspec/gtest")).to be == false
    expect($mystring.include?("QAC++ Deep Flow Static Analyser")).to be == false
    expect($mystring.include?("Filtered out 1")).to be == false
    expect($mystring.include?("Filtered out 2")).to be == false
    expect($mystring.include?("Project path")).to be == false
    expect($mystring.include?("Rebuilding done.")).to be == true
    expect(exit_code).to be == 0
  end

  it 'no filter' do
    ENV["QAC_HOME"] = File.dirname(__FILE__)+"/bin\\"
    ENV["QAC_UT"] = "new_format"
    exit_code = Bake.startBakeqac("qac/main", ["--qacunittest", "--qacnofilter"])
    expect($mystring.include?("rspec/lib1")).to be == true
    expect($mystring.include?("rspec/lib2")).to be == true
    expect($mystring.include?("rspec/lib3")).to be == true
    expect($mystring.include?("rspec/lib1/test")).to be == true
    expect($mystring.include?("rspec/lib1/mock")).to be == true
    expect($mystring.include?("rspec/gmock")).to be == true
    expect($mystring.include?("rspec/gtest")).to be == true
    expect($mystring.include?("QAC++ Deep Flow Static Analyser")).to be == true
    expect($mystring.include?("Filtered out 1")).to be == true
    expect($mystring.include?("Filtered out 2")).to be == true
    expect($mystring.include?("Project path")).to be == true
    expect($mystring.include?("Rebuilding done.")).to be == true
    expect(exit_code).to be == 0
  end

  it 'no filter.txt' do
    ENV["QAC_HOME"] = File.dirname(__FILE__)+"/bin\\"
    ENV["QAC_UT"] = "new_format"
    exit_code = Bake.startBakeqac("qac/main", ["--qacunittest", "--qacnofilter", "--qacstep view"])
    expect($mystring.include?("rspec/lib1")).to be == true
    expect($mystring.include?("rspec/lib2")).to be == true
    expect($mystring.include?("rspec/lib3")).to be == true
    expect($mystring.include?("rspec/lib1/test")).to be == true
    expect($mystring.include?("rspec/lib1/mock")).to be == true
    expect($mystring.include?("rspec/gmock")).to be == true
    expect($mystring.include?("rspec/gtest")).to be == true
    expect($mystring.include?("QAC++ Deep Flow Static Analyser")).to be == true
    expect($mystring.include?("Filtered out 2")).to be == true
    expect(exit_code).to be == 0
  end

  it 'no license analyze' do
    ENV["QAC_HOME"] = File.dirname(__FILE__)+"/bin\\"
    ENV["QAC_UT"] = "no_license_analyze"
    ENV["QAC_RETRY"] = "0"
    exit_code = Bake.startBakeqac("qac/main", ["--qacunittest"])
    expect($mystring.include?("License Refused")).to be == true
    expect($mystring.include?("Filtered out 1")).to be == true
    expect($mystring.include?("Filtered out 2")).to be == false
    expect($mystring.include?("rspec/lib1/bla")).to be == false
    expect($mystring.include?("rspec/lib2/bla")).to be == false
    expect(exit_code).to be > 0
  end

  it 'no license view' do
    ENV["QAC_HOME"] = File.dirname(__FILE__)+"/bin\\"
    ENV["QAC_UT"] = "no_license_view"
    ENV["QAC_RETRY"] = "0"
    exit_code = Bake.startBakeqac("qac/main", ["--qacunittest"])
    expect($mystring.include?("License Refused")).to be == true
    expect($mystring.include?("Filtered out 1")).to be == false
    expect($mystring.include?("Filtered out 2")).to be == true
    expect($mystring.include?("rspec/lib1/bla")).to be == true
    expect($mystring.include?("rspec/lib2/bla")).to be == true
    expect(exit_code).to be > 0
  end

  it 'no license view c' do
    ENV["QAC_HOME"] = File.dirname(__FILE__)+"/bin\\"
    ENV["QAC_UT"] = "no_license_view_c"
    ENV["QAC_RETRY"] = "0"
    exit_code = Bake.startBakeqac("qac/main", ["--qacunittest"])
    expect($mystring.include?("License Refused")).to be == false
    expect($mystring.include?("Filtered out 1")).to be == false
    expect($mystring.include?("Filtered out 2")).to be == false
    expect($mystring.include?("rspec/lib1/bla")).to be == true
    expect($mystring.include?("rspec/lib2/bla")).to be == false
    expect(exit_code).to be == 0
  end

  it 'no license analyze retry' do
    ENV["QAC_HOME"] = File.dirname(__FILE__)+"/bin\\"
    ENV["QAC_UT"] = "no_license_analyze"
    ENV["QAC_RETRY"] = Time.now.to_i.to_s
    exit_code = Bake.startBakeqac("qac/main", ["--qacunittest", "--qacretry", "10"]) # after 5s the license is available
    expect($mystring.split("License refused, retry").length).to be > 3
    expect($mystring.split("License refused, retry").length).to be < 10
    expect($mystring.include?("Filtered out 1")).to be == false
    expect($mystring.include?("Filtered out 2")).to be == false
    expect($mystring.include?("rspec/lib1/bla")).to be == true
    expect($mystring.include?("rspec/lib2/bla")).to be == false
    expect(exit_code).to be == 0
  end

  it 'no license view retry' do
    ENV["QAC_HOME"] = File.dirname(__FILE__)+"/bin\\"
    ENV["QAC_UT"] = "no_license_view"
    ENV["QAC_RETRY"] = Time.now.to_i.to_s
    exit_code = Bake.startBakeqac("qac/main", ["--qacunittest", "--qacretry", "10"]) # after 5s the license is available
    expect($mystring.split("License refused, retry").length).to be > 3
    expect($mystring.split("License refused, retry").length).to be < 10
    expect($mystring.include?("Filtered out 1")).to be == false
    expect($mystring.include?("Filtered out 2")).to be == false
    expect($mystring.include?("rspec/lib1/bla")).to be == true
    expect($mystring.include?("rspec/lib2/bla")).to be == false
    expect(exit_code).to be == 0
  end

  it 'no license view c retry' do
    ENV["QAC_HOME"] = File.dirname(__FILE__)+"/bin\\"
    ENV["QAC_UT"] = "no_license_view_c"
    ENV["QAC_RETRY"] = Time.now.to_i.to_s
    exit_code = Bake.startBakeqac("qac/main", ["--qacunittest", "--qacretry", "10"]) # after 5s the license is available
    expect($mystring.split("License refused, retry").length).to be == 1
    expect($mystring.include?("Filtered out 1")).to be == false
    expect($mystring.include?("Filtered out 2")).to be == false
    expect($mystring.include?("rspec/lib1/bla")).to be == true
    expect($mystring.include?("rspec/lib2/bla")).to be == false
    expect(exit_code).to be == 0
  end

  it 'no license analyze retry timeout' do
    ENV["QAC_HOME"] = File.dirname(__FILE__)+"/bin\\"
    ENV["QAC_UT"] = "no_license_analyze"
    ENV["QAC_RETRY"] = Time.now.to_i.to_s
    exit_code = Bake.startBakeqac("qac/main", ["--qacunittest", "--qacretry", "3"]) # after 5s the license is available
    expect($mystring.split("License refused, retry").length).to be > 3
    expect($mystring.include?("License refused, retry timeout")).to be == true
    expect($mystring.include?("Filtered out 1")).to be == true
    expect($mystring.include?("Filtered out 2")).to be == false
    expect($mystring.include?("rspec/lib1/bla")).to be == false
    expect($mystring.include?("rspec/lib2/bla")).to be == false
    expect(exit_code).to be > 0
  end

  it 'no license view retry timeout' do
    ENV["QAC_HOME"] = File.dirname(__FILE__)+"/bin\\"
    ENV["QAC_UT"] = "no_license_view"
    ENV["QAC_RETRY"] = Time.now.to_i.to_s
    exit_code = Bake.startBakeqac("qac/main", ["--qacunittest", "--qacretry", "3"]) # after 5s the license is available
    expect($mystring.split("License refused, retry").length).to be > 3
    expect($mystring.include?("License refused, retry timeout")).to be == true
    expect($mystring.include?("Filtered out 1")).to be == false
    expect($mystring.include?("Filtered out 2")).to be == true
    expect($mystring.include?("rspec/lib1/bla")).to be == true
    expect($mystring.include?("rspec/lib2/bla")).to be == true
    expect(exit_code).to be > 0
  end

end

end
