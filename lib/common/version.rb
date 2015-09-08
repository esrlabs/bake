module Bake
  class Version
    def self.number
      "2.11.3"
    end
  end
    
  expectedRGen = "0.6.0"
  expectedRText = "0.2.0"
  
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
