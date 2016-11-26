require 'bake/bake_format'
describe 'bake_format' do
  it 'should replace leading whitespace with the correct identation and final newline' do
    input = "test {\ntest2\n}"
    output = StringIO.new
    bake_format(input, output, "    ")
    puts output
    expect(output.string).to eq("test {\n    test2\n}\n")
  end

  it 'should close the output resource' do
    output = StringIO.new
    bake_format("test", output, "    ")
    expect(output.closed?).to be true
  end
end
