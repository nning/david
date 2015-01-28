module David
  module MidCache
    def self.included(base)
      base.send(:attr_reader, :mid_cache)
    end

    def cache
      @mid_cache
    end

    def cache_add(key, message)
      @mid_cache[key] = [message, Time.now.to_i]
    end

    def cache_clean!(timeout)
      now = Time.now.to_i
      @mid_cache.delete_if { |_, v| now - v[1] >= timeout }
      log.debug(@mid_cache.map { |k, v| v[0].to_s })
    end

    def cache_delete(key)
      @mid_cache.delete(key)
    end

    def cache_get(key)
      @mid_cache[key]
    end
  end
end
