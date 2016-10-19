require 'fileutils'
FileUtils::mkdir_p ".qacdata"

testcase = ENV["QAC_UT"]

step = "unknown"
["admin", "analyze", "view"].each { |s| step = s if ARGV.include?s }

def getParam(flag)
  ARGV.each_with_index do |v,i|
    return ARGV[i+1] if v == flag
  end
  "unknown"
end

def getParams(flag)
  res = []
  ARGV.each_with_index do |v,i|
    res << ARGV[i+1] if v == flag
  end
  return res
end

def checkLicense
  timeStart = ENV["QAC_RETRY"].to_i
  return false if timeStart == 0
  sleep 1.0
  return ((Time.now.to_i - timeStart) > 5)
end

case testcase

when "home"
  puts "#{getParam("--cct").split('/config/cct/')[0]} = HOME"

when "steps_ok"
  puts "Rebuilding done." if step == "analyze"

when "steps_failureAdmin"
  case step
  when "admin"
    exit(1)
  when "analyze"
    puts "Rebuilding done."
  end

when "steps_failureAnalyze"
  # nothing to do here

when "steps_failureView"
  case step
  when "analyze"
    puts "Rebuilding done."
  when "view"
    exit(1)
  end


when "steps_qacdata"
  puts "Rebuilding done." if step == "analyze"

  qacDir = getParam("-P")
  qacDir = getParam("--qaf-project") if qacDir =="unknown"
  puts "#{step}: *#{qacDir}*"

when "config_files"
  getParams("--cct").each do |p|
    puts "#{p} - CCT"
  end
  puts "#{getParam("--rcf")} - RCF"
  puts "#{getParam("--acf")} - ACF"

when "old_format"
  case step
  when "analyze"
    puts "Project path: rspec\\lib1"
    puts "Project path: rspec/lib2"
    puts "Rebuilding done."
  when "view"
    puts "// ======= Results for rspec/lib1/bla.cpp"
    puts "rspec/lib1/bla.cpp(1,2): Msg(MCPP Rule 100:1234) FORMAT: #{getParam('-f') == 'unknown' ? 'old' : 'new'}"
    puts "rspec/lib1/bla.cpp(2,2): Msg(MCPP Rule 100:1234) Dummy"
    puts "rspec/lib1/bla.cpp(3,2): Msg(MCPP Rule 100:1234) Dummy"
    puts "// ======= Results for rspec/lib2/bla.cpp"
    puts "rspec/lib2/bla.cpp(4,2): Msg(MCPP Rule 100:1234) Dummy"
  end

when "new_format"
  case step
  when "analyze"
    puts "Project path: rspec\\lib1"
    puts "Project path: rspec/lib2"
    puts "Project path: rspec/gmock"
    puts "Project path: rspec/gtest"
    puts "Rebuilding done."
    puts "Filtered out 1."
  when "view"
    puts
    puts "Filtered out 2."
    puts "// ======= Results for rspec/lib1/bla.cpp"
    puts "MSG: rspec/lib1/bla.cpp(14,1): (MCPP Rule 100:1234) Dummy"
    puts "---- rspec/lib1/bla.cpp(2,1): (MCPP Rule 100:1234) Included from here"
    puts "MSG: rspec/lib1/bla.cpp(13,1): (MCPP Rule 100:1234) FORMAT: #{getParam('-f') == 'unknown' ? 'old' : 'new'}"
    puts "MSG: rspec/lib1/bla.cpp(14,1): (MCPP Rule 100:1234) Dummy"
    puts "MSG: rspec/lib1/bla.cpp(13,1): QAC++ Deep Flow Static Analyser"
    puts "// ======= Results for rspec/lib2/nothing.cpp"
    puts "// ======= Results for rspec/lib2/bla.cpp"
    puts "MSG: rspec/lib2/bla.cpp(1,1): (MCPP Rule 100:1234) Dummy"
    puts "// ======= Results for rspec/lib3/bla.cpp"
    puts "MSG: rspec/lib3/bla.cpp(1,1): (MCPP Rule 100:1234) Dummy"
    puts "// ======= Results for rspec/lib1/test/bla.cpp"
    puts "MSG: rspec/lib1/test/bla.cpp(1,1): (MCPP Rule 100:1234) Dummy"
    puts "// ======= Results for rspec/lib1/mock/bla.cpp"
    puts "MSG: rspec/lib1/mock/bla.cpp(1,1): (MCPP Rule 100:1234) Dummy"
    puts "// ======= Results for rspec/lib1/src/bla.cpp"
    puts "MSG: rspec/lib1/src/bla.cpp(1,1): (MCPP Rule 100:1234) Dummy"
    puts "// ======= Results for rspec/lib4/src/bla.cpp"
    puts "MSG: rspec/lib4/src/bla.cpp(1,1): (MCPP Rule 100:1234) Dummy"
    puts "// ======= Results for rspec/gmock/bla.cpp"
    puts "MSG: rspec/gmock/bla.cpp(1,1): (MCPP Rule 100:1234) Dummy"
    puts "// ======= Results for rspec/gtest/bla.cpp"
    puts "MSG: rspec/gtest/bla.cpp(1,1): (MCPP Rule 100:1234) Dummy"
  end

  when "no_license_analyze"
    case step
    when "analyze"
      puts "Project path: rspec/lib1"
      puts "Rebuilding done."
      puts "License Refused" if !checkLicense
      puts "Filtered out 1"
      exit(1)
    when "view"
      puts "Filtered out 2"
      puts "// ======= Results for rspec/lib1/bla.cpp"
      puts "MSG: rspec/lib1/bla.cpp(1,1): (MCPP Rule 100:1234) Dummy"
      puts "// ======= Results for rspec/lib2/bla.cpp"
      puts "MSG: rspec/lib2/bla.cpp(1,1): (MCPP Rule 100:1234) Dummy"
    end

  when "no_license_view"
    case step
    when "analyze"
      puts "Project path: rspec/lib1"
      puts "Rebuilding done."
      puts "Filtered out 1"
    when "view"
      licenseError = !checkLicense
      puts "License Refused" if licenseError
      puts "Filtered out 2"
      puts "// ======= Results for rspec/lib1/bla.cpp"
      puts "MSG: rspec/lib1/bla.cpp(1,1): (MCPP Rule 100:1234) Dummy"
      puts "// ======= Results for rspec/lib2/bla.cpp"
      puts "MSG: rspec/lib2/bla.cpp(1,1): (MCPP Rule 100:1234) Dummy"
    end

  when "no_license_view_c"
    case step
    when "analyze"
      puts "Project path: rspec/lib1"
      puts "Rebuilding done."
      puts "Filtered out 1"
    when "view"
      licenseError = !checkLicense
      puts "License Refused: C:" if licenseError
      puts "Filtered out 2"
      puts "// ======= Results for rspec/lib1/bla.cpp"
      puts "MSG: rspec/lib1/bla.cpp(1,1): (MCPP Rule 100:1234) Dummy"
      puts "// ======= Results for rspec/lib2/bla.cpp"
      puts "MSG: rspec/lib2/bla.cpp(1,1): (MCPP Rule 100:1234) Dummy"
    end


else
  exit(1)
end
