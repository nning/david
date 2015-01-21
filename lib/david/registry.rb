module David
  module Registry
    protected
    
    def dedup_cache
      Celluloid::Actor[:dedup_cache] || DedupCache.supervise_as(:dedup_cache)
    end

    def log
      @log ||= Celluloid.logger 
      @log ||= ::Logger.new(nil)
    end

    def mid_cache
      Celluloid::Actor[:mid_cache] || MidCache.supervise_as(:mid_cache)
    end

    def observe
      Celluloid::Actor[:observe]
    end

    def server
      Celluloid::Actor[:server]
    end
  end
end
