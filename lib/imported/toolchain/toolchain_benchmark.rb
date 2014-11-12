$:.unshift File.dirname(__FILE__)
require 'toolchain'
require 'benchmark'

Benchmark.bm do |x|

  n = 1000
  x.report("load Toolchain #{n}-times") do
    n.times do
      tc = Toolchain.new('gcc.json')
    end
  end

  tc = Toolchain.new('gcc.json')
  n = 1000000
  x.report("access fields as methods #{n}-times") do
    n.times do
      x = tc.compiler.c.source_file_endings
    end
  end
	
end

