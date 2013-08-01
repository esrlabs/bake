module Cxxproject
  class Version
    def self.bake
      "1.0.21"
    end
  end
    
  expectedCxx = "0.5.67"
  expectedRGen = "0.6.0"
  expectedRText = "0.2.0"
  
  begin
    gem "cxxproject", "=#{expectedCxx}"
  rescue Exception => e
    puts "Warning: Failed to load cxxproject #{expectedCxx}, using latest version"
  end    

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
