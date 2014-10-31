module David
  class Observe < Hash
    include Celluloid

    alias_method :_delete, :delete
    alias_method :_include?, :include?

    def initialize(tick_interval = 3)
      @tick_interval = tick_interval
      async.run

      log.debug 'Observe initialized'
    end

    def add(host, token, env, etag)
      self[[host, token]] ||= [env, etag, Time.now.to_i]
    end

    def delete(host, token)
      _delete([host, token])
    end

    def include?(host, token)
      _include?([host, token])
    end

    def to_s
      self.map { |k, v| [*k, v[0]['PATH_INFO']].inspect }.join(', ')
    end

    private

    def log
      @log ||= Celluloid.logger 
      @log ||= ::Logger.new(nil)
    end

    def run
      loop { tick; sleep @tick_interval }
    end

    def tick
      log.debug 'Observe tick'
      log.debug self unless self.empty?
    end
  end
end
