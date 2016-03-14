module Bake

  class ExitHelper
    @@exit_code = 0

    def self.set_exit_code(val)
      @@exit_code = val
    end
    
    def self.exit_code()
      @@exit_code
    end

    def self.reset_exit_code()
      @@exit_code = 0
    end    

    def self.exit(val)
      @@exit_code = val
      Kernel::exit
    end

  end
end

at_exit do
  if Bake::ExitHelper.exit_code != 0
    exit(Bake::ExitHelper.exit_code)
  elsif not $!.nil?
    if $!.respond_to?("success")
      exit($!.success? ? 0 : 1)
    else
      exit(1)
    end
  else
    exit(0)
  end
end
