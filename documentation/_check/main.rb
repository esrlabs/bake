require_relative 'check'

fixInplace = ARGV.include?("--fix")

files = Dir.glob("source/**/*.rst") << "index.rst"

checker = Check::Documentation.new()

files.uniq.each do |rst_filename|
  checker.loadFile(rst_filename)

  checker.checkHeadings()
  checker.checkTrailings()

  checker.writeChangedData() if (fixInplace)
end

checker.summary(fixInplace)
