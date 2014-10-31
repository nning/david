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

    def add(host, request, env, etag)
      request = request.dup

      request.mid = nil
      request.options.delete(:observe)

      self[[host, request.options[:token]]] ||=
        [0, request, env, etag, Time.now.to_i]
    end

    def delete(host, request)
      _delete([host, request.options[:token]])
    end

    def include?(host, request)
      _include?([host, request.options[:token]])
    end

    def to_s
      self.map { |k, v| [*k, v[2]['PATH_INFO'], v[0]].inspect }.join(', ')
    end

    private

    def log
      @log ||= Celluloid.logger 
      @log ||= ::Logger.new(nil)
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

      self.each do |key, value|
        host    = key[0]
        n       = value[0] += 1
        request = value[1]
        env     = value[2]

        response, options = server.respond(host, CoAP::PORT, request, env)

        unless response.nil?
          response.options[:observe] = n

          log.debug response.inspect
          CoAP::Ether.send(response, host)
        end
      end
    end
  end
end
