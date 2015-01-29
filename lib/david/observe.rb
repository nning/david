module David
  class Observe < Hash
    include Actor

    alias_method :_delete, :delete
    alias_method :_include?, :include?

    def initialize(tick_interval = 3)
      @tick_interval = tick_interval
      async.run

      log.debug 'Observe initialized'
    end

    def add(exchange, env, etag)
      exchange.message.tt = :non
      exchange.message.mid = nil
      exchange.message.options.delete(:observe)

      self[[exchange.host, exchange.token]] ||=
        [0, exchange, env, etag, Time.now.to_i]
    end

    def delete(exchange)
      _delete([exchange.host, exchange.token])
    end

    def include?(exchange)
      _include?([exchange.host, exchange.token])
    end

    def to_s
      self.map { |k, v| [*k, v[2]['PATH_INFO'], v[0]].inspect }.join(', ')
    end

    private

    def bump(key, n, response)
      self[key][0] = n
      self[key][3] = response.options[:etag]
      self[key][4] = Time.now.to_i
    end

    # TODO If ETag did not change but max-age of last notification is expired,
    #      return empty 2.03.
    def handle_update(key)
      n, exchange, env, etag = self[key]
      n += 1

      response, options = server.respond(exchange, env)

      return if response.nil?

      if response.mcode[0] != 2
        self.delete(exchange)
        transmit(exchange, response, options)
        return
      end

      if etag != response.options[:etag]
        response.options[:observe] = n
        transmit(exchange, response, options)

        # TODO Implement removing of observe relationship on RST answer to
        #      notification in main dispatcher
        # if !answer.nil? && answer.tt == :rst
        #   self.delete(exchange)
        #   return
        # end

        bump(key, n, response)
      end
    end

    def transmit(exchange, message, options)
      log.debug message.inspect

      begin
        server.socket.send(message.to_wire, 0, exchange.host, exchange.port)
      rescue Timeout::Error, RuntimeError
      end
    end

    def run
      every(@tick_interval) { tick }
    end

    def tick
      unless self.empty?
        log.debug 'Observe tick'
        log.debug self
      end

      self.each_key { |key| async.handle_update(key) }
    end
  end
end
