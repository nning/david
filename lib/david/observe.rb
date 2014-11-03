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

    def add(host, port, socket, request, env, etag)
      request = request.dup

      request.mid = nil
      request.options.delete(:observe)

      self[[host, request.options[:token]]] ||=
        [0, port, socket, request, env, etag, Time.now.to_i]
    end

    def delete(host, request)
      _delete([host, request.options[:token]])
    end

    def include?(host, request)
      _include?([host, request.options[:token]])
    end

    def to_s
      self.map { |k, v| [*k, v[4]['PATH_INFO'], v[0]].inspect }.join(', ')
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
        port    = value[1]
        socket  = value[2]
        request = value[3]
        env     = value[4]

        response, options = server.respond(host, port, request, env)

        unless response.nil?
          response.options[:observe] = n

          log.debug response.inspect

          if response.mcode != [2, 5] && response.mcode != [2, 3]
            self.delete(host, request)
            response.options[:observe] = nil
          end

          begin
            answer = CoAP::Ether.request(response, host, port,
              options.merge(retransmit: false, socket: socket)).last

            log.debug answer.inspect
          rescue Timeout::Error
          else
            self.delete(host, request) if answer.tt == :rst
          end
        end
      end
    end
  end
end
