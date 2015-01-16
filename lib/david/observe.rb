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

    def add(request, env, etag)
      request.message.mid = nil
      request.message.options.delete(:observe)

      # TODO Check if Array or Struct is more efficient.
      self[[request.host, request.token]] ||=
        [0, request, env, etag, Time.now.to_i]
    end

    def delete(request)
      _delete([request.host, request.token])
    end

    def include?(request)
      _include?([request.host, request.token])
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
      n, request, env, etag = self[key]
      n += 1

      response, options = server.respond(request, env)

      return if response.nil?

      if response.mcode[0] != 2
        self.delete(request)
        request(response, request.host, request.port, options)
        return
      end

      if etag != response.options[:etag]
        response.options[:observe] = n

        answer = request(response, request.host, request.port, options)

        if !answer.nil? && answer.tt == :rst
          self.delete(request)
          return
        end

        bump(key, n, response)
      end
    end

    def request(message, host, port, options)
      answer = nil

      log.debug message.inspect

      begin
        options.merge!(retransmit: false, socket: server.socket)
        answer = CoAP::Ether.request(message, host, port, options).last
        log.debug answer.inspect
      rescue Timeout::Error, RuntimeError
      end

      answer
    end

    def run
      loop { tick; sleep @tick_interval }
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
