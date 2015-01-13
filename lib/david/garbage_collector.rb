module David
  class GarbageCollector
    include Actor

    def initialize(tick_interval = 10, dedup_timeout = 5)
      @tick_interval = tick_interval
      @dedup_timeout = dedup_timeout

      async.run

      log.debug 'GarbageCollector initialized'
    end

    def clean_dedup_cache(now = Time.now.to_i)
      server.dedup_cache.delete_if do |k, v|
        now - v[1] >= @dedup_timeout
      end
    end

    private

    def run
      loop { sleep @tick_interval; tick }
    end

    def tick
      unless server.dedup_cache.empty?
        log.debug 'GarbageCollector tick'

        clean_dedup_cache
        log.debug server.dedup_cache 
      end
    end
  end
end
