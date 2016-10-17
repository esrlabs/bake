require 'fileutils'
FileUtils::mkdir_p "qacdata"

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

else
  exit(1)
end
