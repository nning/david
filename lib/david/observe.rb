require 'time'

module David
# class ObserveValue < Struct.new(:n, :request, :env, :etag, :time)
# end

  class Observe < Hash
    include Celluloid

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
        [0, request, env, etag, Time.now.rfc2822]
#       ObserveValue.new(0, request, env, etag, Time.now.rfc2822)
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

    def handle_update(key)
      n, request, env, etag, time = self[key]
      n += 1

      env['HTTP_IF_MODIFIED_SINCE'] = time
      env['HTTP_IF_NONE_MATCH'] = etag

      response, options = server.respond(request, env)

      log.debug([response.mcode, etag, options[:http_etag]])

      return if response.nil?

      if response.mcode != [2, 5] && response.mcode != [2, 3]
        self.delete(request)
        request(response, request.host, request.port, options)
      end

      if response.mcode == [2, 5] && etag != options[:http_etag]
        response.options[:observe] = n

        answer = request(response, request.host, request.port, options)

        if !answer.nil? && answer.tt == :rst
          self.delete(request)
          return
        end

        self[key][0] = n
        self[key][3] = options[:http_etag]
        self[key][4] = Time.now.rfc2822
      end
    end

    def log
      @log ||= Celluloid.logger 
      @log ||= ::Logger.new(nil)
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

    def server
      Celluloid::Actor[:server]
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
