#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'bake/util'
require 'common/exit_helper'
require 'socket'
require 'fileutils'

require 'common/ext/stdout'

module Bake

describe "Synced" do


  # BURGER


  # ruby bin/bake -m spec/testdata/synced/main test_exe2 -a black  -O --rebuild -r
  # src/lib2/f1.cpp am Schluss, dann kein "Building" mehr

  # ruby bin/bake -m spec/testdata/synced/main test_exe2 -a black  -O --rebuild -j 1
  # src/lib2/f1.cpp in "Building 1 of" mehr, dann noch 2 und 3

  # ruby bin/bake -m spec/testdata/synced/main test_exe2 -a black  -O --rebuild
  #**** Building 1 of 3: main (test_lib2) ****
  #Compiling main (test_lib2)
  #**** Building 2 of 3: main (test_lib1) ****
  # Compiling main (test_lib1)
  #**** Building 3 of 3: main (test_exe2) ****
  #Compiling main (test_exe2)
  # ---> xy (z) immer nacheinander

  # ruby bin/bake -m spec/testdata/synced/main test_exe1 -a black  -O --rebuild (-r)
  # src/lib2/f1.cpp am Schluss, dann kein "Building" mehr
  # **** Building 1 of 2: main (test_lib1) ****
  # Compiling main (test_lib1)
  # **** Building 2 of 2: main (test_exe1) ****
  # Compiling main (test_exe1)
  # Linking   main (test_exe1): build/test_exe1/main.exe


  # prestep
  # $ ruby bin/bake -m spec/testdata/synced/main test_exe3 -a black  --rebuild -O
  # **** Building 1 of 3: main (test_lib1) ****
  # **** Building 2 of 3: main (test_preStepFailure) ****
  # **** Building 3 of 3: main (test_exe3) ****
  # Rebuilding failed.

  # $ ruby bin/bake -m spec/testdata/synced/main test_exe3 -a black  --rebuild -O -r
  #**** Building 1 of 3: main (test_lib1) ****
  #**** Building 2 of 3: main (test_preStepFailure) ****
  # KEIN 3 of 3
  # Rebuilding failed.
end

end
