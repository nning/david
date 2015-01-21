module David
  class MidCache
    include Celluloid

    def initialize
      @cache = {}
    end

    def add(exchange)
      @cache[[exchange.host, exchange.mid]] = [exchange, Time.now.to_i]
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
  end
end
