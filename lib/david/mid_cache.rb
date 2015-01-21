module David
  class MidCache
    include Actor

    def initialize(options = {})
      @cache = {}

      @tick_interval = options[:tick_interval] || 10
      @timeout = options[:timeout] || 5

      log.debug('MidCache initialized')

      async.run
    end

    def add(exchange)
      @cache[[exchange.host, exchange.mid]] = [exchange, now]
    end

    def delete(exchange)
      @cache.delete([exchange.host, exchange.mid])
    end

    def lookup(exchange)
      @cache[[exchange.host, exchange.mid]]
    end

    def present?(exchange)
      !lookup(exchange).nil?
    end

    private

    def clean
      @cache.delete_if { |_, v| now - v[1] >= @timeout }
    end

    def now
      Time.now.to_i
    end

    def run
      loop { sleep @tick_interval; tick }
    end

    def tick
      unless @cache.empty?
        log.debug('MidCache GC tick')

        clean
        log.debug(@cache.map { |k, v| v[0].to_s })
      end
    end
  end
end
