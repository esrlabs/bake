#!/usr/bin/env ruby

require 'helper'

require 'common/version'

require 'bake/options/options'
require 'common/exit_helper'
require 'fileutils'

module Bake

describe "Cuda" do

  it 'Example' do
    Bake.startBake("root1/main", ["cuda", "-w", "spec/testdata/root1", "-w", "spec/testdata/root2", "-v2"])

    expect($mystring.include?("nvcc -c -Xcompiler -MD -Xcompiler -MF -Xcompiler build/cuda_main_cuda/src/anotherOne.d -Iinclude -o build/cuda_main_cuda/src/anotherOne.o src/anotherOne.cpp")).to be == true
    expect($mystring.include?("nvcc -c -Xcompiler -MD -Xcompiler -MF -Xcompiler build/cuda_main_cuda/src/lib1.d -Iinclude -o build/cuda_main_cuda/src/lib1.o src/lib1.cpp")).to be == true
  end

end

end
