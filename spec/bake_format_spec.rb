require 'helper'
require 'format/bake_format'

describe 'bake_format' do
  it 'should replace leading whitespace with the correct indentation and final newline' do
    input = "test {\ntest2\n}"
    output = StringIO.new
    bake_format(input, output, "    ")
    expect(output.string).to eq("test {\n    test2\n}\n")
  end

  it 'default indentation of the bake-format tool are two spaces' do
    output = `ruby #{File.dirname(__FILE__)}/../bin/bake-format spec/testdata/format.txt -`
    expect(output).to eq("test {\n\n  test2\n}\n")
  end

  it 'should close the output resource' do
    output = StringIO.new
    bake_format("test", output, "    ")
    expect(output.closed?).to be true
  end

  it "should not indent empty lines" do
    output = StringIO.new
    bake_format("test {\n\n}", output, "    ")
    expect(output.string).to eq("test {\n\n}\n")

    output = StringIO.new
    bake_format("test {\n\n}", output, "\t")
    expect(output.string).to eq("test {\n\n}\n")
  end

  it "should not format the lines which are not in range" do
    output = StringIO.new
    bake_format_in_range("test {\n\ntest2\ntest3\n}\n", output, "\t", 0, 2)
    expect(output.string).to eq("test {\n\n\ttest2\ntest3\n}\n")
  end
end
