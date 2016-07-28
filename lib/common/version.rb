module Bake
  class Version
    def self.number
      "2.19.0"
    end
  end

  expectedRGen = "0.8.1"
  expectedRText = "0.8.1"

  begin
    gem "rgen", "=#{expectedRGen}"
  rescue Exception => e
    puts "Warning: Failed to load rgen #{expectedRGen}, using latest version"
  end

  begin
    gem "rtext", "=#{expectedRText}"
  rescue Exception => e
    puts "Warning: Failed to load rtext #{expectedRText}, using latest version"
  end

end
