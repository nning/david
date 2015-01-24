module David
  module MidCache
    def self.included(base)
      base.send(:attr_reader, :mid_cache)
    end

    def cache
      @mid_cache
    end

    def cache!(exchange)
      @mid_cache[exchange.key] = [exchange, Time.now.to_i]
    end

    def cache_clean!(timeout)
      now = Time.now.to_i
      @mid_cache.delete_if { |_, v| now - v[1] >= timeout }
      log.debug(@mid_cache.map { |k, v| v[0].to_s })
    end

    def cache_delete(key)
      @mid_cache.delete(key)
    end

    def cached?(key)
      @mid_cache.include?(key)
    end

    def cached_message(key)
      @mid_cache[key][0].message
    end
  end
end
