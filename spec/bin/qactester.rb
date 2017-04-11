require 'fileutils'

testcase = ENV["QAC_UT"]

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

qacDir = getParam("-P")
qacDir = getParam("--qaf-project") if qacDir =="unknown"

if qacDir != "unknown"
  FileUtils::mkdir_p "#{qacDir}/cip"
  `echo test > #{qacDir}/cip/gcc.cip`
end

step = "unknown"
["admin", "analyze", "view", "report", "MDR"].each { |s| step = s if ARGV.include?s }

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

  puts "#{step}: *#{qacDir}*"
  puts "Rebuilding done." if step == "analyze"

when "config_files"
  ccts = getParams("--cct")
  ccts.each do |p|
    puts "#{p} - CCT"
  end
  puts "#{getParam("--rcf")} - RCF"
  puts "#{getParam("--acf")} - ACF"

  FileUtils::mkdir_p qacDir+"/prqa/config"
  FileUtils::touch qacDir+"/prqa/config/" + File.basename(ccts[0])

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

when "mdr_test_okay"
  if step == "analyze"
    puts "Project path: lib1"
    puts "Rebuilding done."
  elsif step == "MDR"
    FileUtils::rm_rf(qacDir + "/prqa/reports/data")
    FileUtils::mkdir_p(qacDir + "/prqa/reports/data")
    File.open(qacDir + "/prqa/reports/data/1.json", "w") do |file|
      file.puts "{"
      file.puts "  \"file\": \"C:/path/lib1/src/File1.cpp\","
      file.puts "  \"entities\":"
      file.puts "  ["
      file.puts "    {"
      file.puts "      \"type\": \"function\","
      file.puts "      \"name\": \"Func1\","
      file.puts "      \"line\": 11,"
      file.puts "      \"metrics\":"
      file.puts "      {"
      file.puts "        \"ABC\": \"0\", \"STCYC\": \"13\", \"XYZ\": \"0\""
      file.puts "      }"
      file.puts "    },"
      file.puts "    {"
      file.puts "      \"type\": \"function\","
      file.puts "      \"name\": \"Func2\","
      file.puts "      \"line\": 22,"
      file.puts "      \"metrics\":"
      file.puts "      {"
      file.puts "        \"ABC\": \"0\", \"STCYC\": \"2\", \"XYZ\": \"0\""
      file.puts "      }"
      file.puts "    }"
      file.puts "  ]"
      file.puts "}"
    end
    File.open(qacDir + "/prqa/reports/data/2.json", "w") do |file|
      file.puts "{"
      file.puts "  \"file\": \"C:/path/lib2/src/File2.cpp\","
      file.puts "  \"entities\":"
      file.puts "  ["
      file.puts "    {"
      file.puts "      \"type\": \"function\","
      file.puts "      \"name\": \"Wrong_Func1\","
      file.puts "      \"line\": 1,"
      file.puts "      \"metrics\":"
      file.puts "      {"
      file.puts "        \"ABC\": \"0\", \"STCYC\": \"14\", \"XYZ\": \"0\""
      file.puts "      }"
      file.puts "    },"
      file.puts "    {"
      file.puts "      \"type\": \"function\","
      file.puts "      \"name\": \"Wrong_Func2\","
      file.puts "      \"line\": 220,"
      file.puts "      \"metrics\":"
      file.puts "      {"
      file.puts "        \"ABC\": \"0\", \"STCYC\": \"3\", \"XYZ\": \"0\""
      file.puts "      }"
      file.puts "    }"
      file.puts "  ]"
      file.puts "}"
    end
  end

else
  exit(1)
end
