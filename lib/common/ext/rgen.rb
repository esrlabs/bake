module RGen
module Util

  class FileCacheMap
    alias_method :orig_store_data, :store_data
    def store_data(key_path, value_data)
      begin
        orig_store_data(key_path, value_data)
      rescue Exception=>e
        if Bake.options.verbose >= 3
          cf = cache_file(key_path)
          Bake.formatter.printWarning("Warning: Could not write cache file #{cf}")
          if Bake.options.debug
            puts e.message
            puts e.backtrace
          end
        end
      end
    end
  end

end
end
