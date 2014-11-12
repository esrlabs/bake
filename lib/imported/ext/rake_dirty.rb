require 'rake'
module Rake
  class Task
    # return true if this or one of the prerequisites is dirty
    def dirty?
      return calc_dirty_for_prerequsites if apply?(name)

      if needed?
        return true
      end
      return calc_dirty_for_prerequsites
    end

    def calc_dirty_for_prerequsites
      res = prerequisites.find do |p|
        t = Task[p]
        if t != nil
          if t.dirty?
            true
          else
            false
          end
        else
          false
        end
      end
      return res != nil
    end
  end
end
