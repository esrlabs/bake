module Bake
  class ExitHelperException < StandardError
  end

  class ExitHelper
    @@exit_code = 0
    @@exit_test = false
    
    def self.set_exit_code(val)
      @@exit_code = val
    end

    def self.exit_code()
      @@exit_code
    end

    def self.reset_exit_code()
      @@exit_code = 0
    end    

    def self.enable_exit_test()
      @@exit_test = true
    end    
    
    def self.disable_exit_test()
      @@exit_test = false
    end
        
    def self.exit(val)
      raise ExitHelperException.new if @@exit_test
      @@exit_code = val
      Kernel::exit
    end

  end
end

at_exit do
  exit(Bake::ExitHelper.exit_code)
end
