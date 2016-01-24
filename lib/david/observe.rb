module David
  class Observe
    extend Forwardable

    include Actor

    def_delegators :@store, :first, :keys, :size

    def initialize(tick_interval = 3)
      @tick_interval = tick_interval
      @store = {}

      async.run

      log.debug('Observe initialized')
    end

    def add(exchange, env, etag)
      exchange.message.options.delete(:observe)

      @store[[exchange.host, exchange.token]] ||=
        [0, exchange, env, etag, Time.now.to_i]
    end

    def delete(exchange)
      @store.delete([exchange.host, exchange.token])
    end

    def get(key)
      @store[key]
    end

    def include?(exchange)
      @store.include?([exchange.host, exchange.token])
    end

    def to_s
      @store.map { |k, v| [*k, v[2]['PATH_INFO'], v[0]].inspect }.join(', ')
    end

    private

    def bump(key, n, response)
      @store[key][0] = n
      @store[key][3] = response.options[:etag]
      @store[key][4] = Time.now.to_i
    end

    # TODO If ETag did not change but max-age of last notification is expired,
    #      return empty 2.03.
    def handle_update(key)
      n, exchange, env, etag = @store[key]
      n += 1

      response, options = server.respond(exchange, env)

      return if response.nil?

      if response.mcode[0] != 2
        self.delete(exchange)
        transmit(exchange, response, options)
        return
      end

      if etag != response.options[:etag]
        response.tt = :con
        response.mid = SecureRandom.random_number(0xffff)
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
      begin
        server.socket.send(message.to_wire, 0, exchange.host, exchange.port)
        log.debug(message.inspect)
      rescue Timeout::Error, RuntimeError, Errno::ENETUNREACH
      end
    end

    def run
      every(@tick_interval) { tick }
    end

    def tick(fiber = true)
      unless @store.empty?
        log.debug('Observe tick')
        log.debug(@store)
      end

      @store.each_key do |key|
        if fiber
          async.handle_update(key)
        else
          handle_update(key)
        end
      end
    end
  end
end
