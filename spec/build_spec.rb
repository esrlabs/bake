#!/usr/bin/env ruby

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'
require 'helper'

module Bake

describe "Building" do
  
  it 'workspace' do
    expect(File.exists?("spec/testdata/cache/main/build_test/main.exe")).to be == false
    
    Bake.startBake("cache/main", ["-b", "test", "-v2"])

    expect(File.exists?("spec/testdata/cache/main/build_test/main.exe")).to be == true
    
    expect($mystring.split("PREMAIN").length).to be == 3
    expect($mystring.split("POSTMAIN").length).to be == 3
    
    expect($mystring.include?("../lib1/build_testsub_main_test/liblib1.a makefile/dummy.a")).to be == true # makefile lib shall be put to the end of the lib string
  end

  it 'single lib' do
    expect(File.exists?("spec/testdata/cache/main/build_test/main.exe")).to be == false
    
    Bake.startBake("cache/main", ["-p", "lib1", "-b", "test"])

    expect(File.exists?("spec/testdata/cache/lib1/build_testsub_main_test/liblib1.a")).to be == true
    expect(File.exists?("spec/testdata/cache/main/build_test/main.exe")).to be == false
    
    expect($mystring.split("PRELIB1").length).to be == 3
    expect($mystring.split("POSTLIB1").length).to be == 3    
  end  

  it 'single exe should fail' do
    expect(File.exists?("spec/testdata/cache/lib1/testsub_main_test/src/lib1.o")).to be == false
    expect(File.exists?("spec/testdata/cache/lib1/testsub_main_test/liblib1.a")).to be == false

    expect(File.exists?("spec/testdata/cache/main/build_test/src/main.o")).to be == false
    expect(File.exists?("spec/testdata/cache/main/build_test/main.exe")).to be == false
    
    Bake.startBake("cache/main", ["-p", "main", "-b", "test"])

    expect(File.exists?("spec/testdata/cache/lib1/build_testsub_main_test/src/lib1.o")).to be == false
    expect(File.exists?("spec/testdata/cache/lib1/build_testsub_main_test/liblib1.a")).to be == false

    expect(File.exists?("spec/testdata/cache/main/build_test/src/main.o")).to be == true
    expect(File.exists?("spec/testdata/cache/main/build_test/main.exe")).to be == false
    
    expect($mystring.split("PREMAIN").length).to be == 3
    expect($mystring.split("POSTMAIN").length).to be == 1 # means not executed cause exe build failed
    
    expect(ExitHelper.exit_code).to be > 0
  end  

  it 'single file' do
    expect(File.exists?("spec/testdata/cache/main/build_test/src/main.o")).to be == false
    expect(File.exists?("spec/testdata/cache/main/build_test/main.exe")).to be == false

    Bake.startBake("cache/main", ["-b", "test", "-f", "src/main.cpp"])

    expect(File.exists?("spec/testdata/cache/main/build_test/src/main.o")).to be == true
    expect(File.exists?("spec/testdata/cache/main/build_test/main.exe")).to be == false
    
    expect(ExitHelper.exit_code).to be == 0
  end  

  it 'clean single file' do
    Bake.startBake("cache/main", ["-b", "test"])

    expect(File.exists?("spec/testdata/cache/main/build_test/src/main.o")).to be == true
    expect(File.exists?("spec/testdata/cache/main/build_test/src/main.d")).to be == true
    expect(File.exists?("spec/testdata/cache/main/build_test/main.exe")).to be == true

    Bake.startBake("cache/main", ["-b", "test", "-f", "src/main.cpp", "-c"])
    
    expect(File.exists?("spec/testdata/cache/main/build_test/src/main.o")).to be == false
    expect(File.exists?("spec/testdata/cache/main/build_test/src/main.d")).to be == false
    expect(File.exists?("spec/testdata/cache/main/build_test/main.exe")).to be == true
    
    expect(ExitHelper.exit_code).to be == 0
  end  
  
  it 'multiple file 1' do
    expect(File.exists?("spec/testdata/cache/main/build_testMultiFile/src/multi.o")).to be == false
    expect(File.exists?("spec/testdata/cache/main/build_testMultiFile/src/x/multi.o")).to be == false
    expect(File.exists?("spec/testdata/cache/lib1/build_testMultiFile_main_testMultiFile/src/multi.o")).to be == false

    Bake.startBake("cache/main", ["-b", "testMultiFile", "-f", "src/multi.cpp"])

    expect(File.exists?("spec/testdata/cache/main/build_testMultiFile/src/multi.o")).to be == true
    expect(File.exists?("spec/testdata/cache/main/build_testMultiFile/src/x/multi.o")).to be == false
    expect(File.exists?("spec/testdata/cache/lib1/build_testMultiFile_main_testMultiFile/src/multi.o")).to be == true

    Bake.startBake("cache/main", ["-b", "testMultiFile", "-f", "src/multi.cpp", "-c"])

    expect(File.exists?("spec/testdata/cache/main/build_testMultiFile/src/multi.o")).to be == false
    expect(File.exists?("spec/testdata/cache/main/build_testMultiFile/src/x/multi.o")).to be == false
    expect(File.exists?("spec/testdata/cache/lib1/build_testMultiFile_main_testMultiFile/src/multi.o")).to be == false
              
    expect(ExitHelper.exit_code).to be == 0
  end  

  it 'multiple file 2' do
    expect(File.exists?("spec/testdata/cache/main/build_testMultiFile/src/multi.o")).to be == false
    expect(File.exists?("spec/testdata/cache/main/build_testMultiFile/src/x/multi.o")).to be == false
    expect(File.exists?("spec/testdata/cache/lib1/build_testMultiFile_main_testMultiFile/src/multi.o")).to be == false

    Bake.startBake("cache/main", ["-b", "testMultiFile", "-f", "multi.cpp"])

    expect(File.exists?("spec/testdata/cache/main/build_testMultiFile/src/multi.o")).to be == true
    expect(File.exists?("spec/testdata/cache/main/build_testMultiFile/src/x/multi.o")).to be == true
    expect(File.exists?("spec/testdata/cache/lib1/build_testMultiFile_main_testMultiFile/src/multi.o")).to be == true

    Bake.startBake("cache/main", ["-b", "testMultiFile", "-f", "multi.cpp", "-c"])

    expect(File.exists?("spec/testdata/cache/main/build_testMultiFile/src/multi.o")).to be == false
    expect(File.exists?("spec/testdata/cache/main/build_testMultiFile/src/x/multi.o")).to be == false
    expect(File.exists?("spec/testdata/cache/lib1/build_testMultiFile_main_testMultiFile/src/multi.o")).to be == false
              
    expect(ExitHelper.exit_code).to be == 0
  end  

  it 'clean single lib' do
    Bake.startBake("cache/main", ["-b", "test"])
    
    expect(File.exists?("spec/testdata/cache/main/build_test")).to be == true
    expect(File.exists?("spec/testdata/cache/lib1/build_testsub_main_test")).to be == true
    expect(File.exists?("spec/testdata/cache/lib1/build_testsub_main_test/liblib1.a")).to be == true
    expect(File.exists?("spec/testdata/cache/main/build_test/main.exe")).to be == true

    Bake.startBake("cache/main", ["-b", "test", "-p", "lib1", "-c"])

    expect(File.exists?("spec/testdata/cache/main/build_test")).to be == true
    expect(File.exists?("spec/testdata/cache/lib1/build_testsub_main_test")).to be == false
    expect(File.exists?("spec/testdata/cache/lib1/build_testsub_main_test/liblib1.a")).to be == false
    expect(File.exists?("spec/testdata/cache/main/build_test/main.exe")).to be == true
    
    expect(ExitHelper.exit_code).to be == 0
  end
    
  it 'clean single lib' do
    Bake.startBake("cache/main", ["-b", "test"])
    
    expect(File.exists?("spec/testdata/cache/main/build_test")).to be == true
    expect(File.exists?("spec/testdata/cache/lib1/build_testsub_main_test")).to be == true
    expect(File.exists?("spec/testdata/cache/lib1/build_testsub_main_test/liblib1.a")).to be == true
    expect(File.exists?("spec/testdata/cache/main/build_test/main.exe")).to be == true

    Bake.startBake("cache/main", ["-b", "test","-p", "main", "-c"])

    expect(File.exists?("spec/testdata/cache/main/build_test")).to be == false
    expect(File.exists?("spec/testdata/cache/lib1/build_testsub_main_test")).to be == true
    expect(File.exists?("spec/testdata/cache/lib1/build_testsub_main_test/liblib1.a")).to be == true
    expect(File.exists?("spec/testdata/cache/main/build_test/main.exe")).to be == false
    
    expect(ExitHelper.exit_code).to be == 0
  end  
  
  it 'clobber' do
    Bake.startBake("cache/main", ["-b", "test"])

    expect(File.exists?("spec/testdata/cache/main/.bake")).to be == true
    expect(File.exists?("spec/testdata/cache/lib1/.bake")).to be == true

    Bake.startBake("cache/main", ["-b", "test", "--clobber"])

    expect(File.exists?("spec/testdata/cache/main/.bake")).to be == false
    expect(File.exists?("spec/testdata/cache/lib1/.bake")).to be == false
  end    
  
  it 'clobber project only' do
    Bake.startBake("cache/main", ["-b", "test", "-p", "lib1"])

    expect(File.exists?("spec/testdata/cache/main/.bake")).to be == true
    expect(File.exists?("spec/testdata/cache/lib1/.bake")).to be == true

    Bake.startBake("cache/main", ["-b", "test", "-p", "lib1", "--clobber"])

    expect(File.exists?("spec/testdata/cache/main/.bake")).to be == true
    expect(File.exists?("spec/testdata/cache/lib1/.bake")).to be == false
  end    

  
  it 'no src for lib' do
    Bake.startBake("noFiles/main", ["testLib", "--rebuild"])
    expect(ExitHelper.exit_code).to be == 0
  end 
  
  it 'no src for exe' do
    Bake.startBake("noFiles/main", ["testExe", "--rebuild"])
    expect(ExitHelper.exit_code).to be == 0
  end
  
  it 'no src for pattern*' do
    Bake.startBake("noFiles/main", ["testFilePattern1DoesNotExist", "--rebuild"])
    expect(ExitHelper.exit_code).to be == 0
  end
  
  it 'no src for pattern?' do
    Bake.startBake("noFiles/main", ["testFilePattern2DoesNotExist", "--rebuild"])
    expect(ExitHelper.exit_code).to be == 0
  end
  
  it 'no src for src' do
    Bake.startBake("noFiles/main", ["testFileDoesNotExist", "--rebuild"])
    expect(ExitHelper.exit_code).to be > 0
    expect($mystring.include?("Compiling")).to be == false
    expect($mystring.include?("Creating")).to be == false
  end
  
  it 'three exes' do
    Bake.startBake("threeExe/main", ["test", "-v2"])
    expect(ExitHelper.exit_code).to be == 0

    exe1 = "g++ -o build_test_main_test/exe1.exe build_test_main_test/src/main.o ../lib1/build_test_main_test/liblib1.a"     
    exe2 = "g++ -o build_test_main_test/exe2.exe build_test_main_test/src/main.o ../lib2/build_test_main_test/liblib2.a"     
    exe3 = "g++ -o build_test_main_test/exe3.exe build_test_main_test/src/main.o ../lib2/build_test_main_test/liblib2.a ../lib3/build_test_main_test/liblib3.a"     
    main = "g++ -o build_test/main.exe build_test/src/main.o ../lib1/build_test_main_test/liblib1.a ../lib2/build_test_main_test/liblib2.a ../lib3/build_test_main_test/liblib3.a"     
    expect($mystring.include?(exe1)).to be == true
    expect($mystring.include?(exe2)).to be == true
    expect($mystring.include?(exe3)).to be == true
    expect($mystring.include?(main)).to be == true
  end

  it 'MapFileEmpty' do
    Bake.startBake("cache/main", ["testMapEmpty", "-v2"])
    expect($mystring.include?("> build_testMapEmpty/main.map")).to be == true
    expect(File.exist?("spec/testdata/cache/main/build_testMapEmpty/main.map")).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end  

  it 'MapFileDada' do
    Bake.startBake("cache/main", ["testMapDada", "-v2"])
    expect($mystring.include?("> build_testMapDada/dada.map")).to be == true
    expect(File.exist?("spec/testdata/cache/main/build_testMapDada/dada.map")).to be == true
    expect(ExitHelper.exit_code).to be == 0
  end  
 
  it 'LibHasError_noLink' do
    Bake.startBake("errors/main", ["testWrong"])
    expect($mystring.include?("main.exe")).to be == false
  end  
   
  it 'ExeHasError_noLink' do
    Bake.startBake("errors/main", ["testWrong2"])
    expect($mystring.include?("main.exe")).to be == false
  end 
  
  it 'assembler' do
    Bake.startBake("assembler", ["test"])
    
    expect($mystring.include?("a.S")).to be == true
    expect($mystring.include?("main.cpp")).to be == true
    expect($mystring.include?("assembler.")).to be == true
      
    Bake.startBake("assembler", ["test"])
   
    expect(ExitHelper.exit_code).to be == 0
  end

  it 'touch header' do
    Bake.startBake("header/main", ["test"])
    expect($mystring.split("Compiling").length).to be == 2
    Bake.startBake("header/main", ["test"])
    expect($mystring.split("Compiling").length).to be == 2

    sleep 1.1
    FileUtils.touch("spec/testdata/header/main/include/inc1.h")

    Bake.startBake("header/main", ["test"])
    expect($mystring.split("Compiling").length).to be == 3
  end

    
end

end
