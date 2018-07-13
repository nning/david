module David
  class GarbageCollector
    include Actor

    def initialize(options = {})
      @tick_interval = options[:tick_interval] || 10
      @timeout = options[:timeout] || 5

      log.debug('GarbageCollector initialized')

      async.run
    end

    private

    def run
      every(@tick_interval) { tick }
    end

    def tick
      servers.each do |server|
        unless server.cache.empty?
          log.debug("GarbageCollector tick for #{server.class.name}")
          server.cache_clean!(@timeout)
        end
      end
    end
  end
end
