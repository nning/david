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

    def add(host, port, request, env, etag)
      request = request.dup

      request.mid = nil
      request.options.delete(:observe)

      self[[host, request.options[:token]]] ||=
        [0, port, request, env, etag, Time.now.to_i]
    end

    def delete(host, request)
      _delete([host, request.options[:token]])
    end

    def include?(host, request)
      _include?([host, request.options[:token]])
    end

    def to_s
      self.map { |k, v| [*k, v[3]['PATH_INFO'], v[0]].inspect }.join(', ')
    end

    private

    def handle_update(key)
      value   = self[key]

      host    = key[0]
      n       = value[0] += 1
      port    = value[1]
      request = value[2]
      env     = value[3]

      response, options = server.respond(host, port, request, env)

      unless response.nil?
        if response.mcode != [2, 5] && response.mcode != [2, 3]
          self.delete(host, request)
          response.options[:observe] = nil
        end

        answer = respond(response, host, port, n, options)

        if !answer.nil? && answer.tt == :rst
          self.delete(host, request)
        end
      end
    end

    def log
      @log ||= Celluloid.logger 
      @log ||= ::Logger.new(nil)
    end

    def respond(message, host, port, n, options)
      answer = nil

      message.options[:observe] = n

      log.debug message.inspect

      begin
        options.merge!(retransmit: false, socket: server.socket)
        answer = CoAP::Ether.request(message, host, port, options).last
        log.debug answer.inspect
      rescue Timeout::Error
      end

      answer
    end

    def run
      loop { tick; sleep @tick_interval }
    end

    def server
      Celluloid::Actor[:server]
    end

    def tick
      log.debug 'Observe tick'
      log.debug self unless self.empty?

      self.each_key { |key| async.handle_update(key) }
    end
  end
end
