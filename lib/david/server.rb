require 'david/server/mid_cache'
require 'david/server/multicast'
require 'david/server/options'
require 'david/server/respond'

module David
  class Server
    include Celluloid::IO

    include MidCache
    include Multicast
    include Options
    include Respond

    attr_reader :socket

    finalizer :shutdown

    def initialize(app, options)
      @block   = choose(:block,   options[:Block])
      @cbor    = choose(:cbor,    options[:CBOR])
      @host    = choose(:host,    options[:Host])
      @log     = choose(:logger,  options[:Log])
      @mcast   = choose(:mcast,   options[:Multicast])
      @observe = choose(:observe, options[:Observe])
      @port    = options[:Port].to_i

      @app     = app.respond_to?(:new) ? app.new : app

      @default_format = choose(:default_format, options[:DefaultFormat])

      @mid_cache = {}

      log.info "David #{David::VERSION} on #{RUBY_DESCRIPTION}"
      log.info "Starting on [#{@host}]:#{@port}"

      af = ipv6? ? ::Socket::AF_INET6 : ::Socket::AF_INET

      # Actually Celluloid::IO::UDPSocket.
      @socket = UDPSocket.new(af)
      multicast_initialize! if @mcast
      @socket.bind(@host, @port)
    end

    def run
      loop do
        if defined?(JRuby) || defined?(Rubinius)
          dispatch(*@socket.recvfrom(1152))
        else
          begin
            dispatch(*@socket.to_io.recvmsg_nonblock)
          rescue ::IO::WaitReadable
            Celluloid::IO.wait_readable(@socket)
            retry
          end
        end
      end
    end

    private

    def dispatch(*args)
      data, sender, _, anc = args

      if defined?(JRuby) || defined?(Rubinius)
        port, _, host = sender[1..3]
      else
        host, port = sender.ip_address, sender.ip_port
      end

      message  = CoAP::Message.parse(data)
      exchange = Exchange.new(host, port, message, anc)

      return if !exchange.non? && exchange.multicast?

      log.info('<- ' + exchange.to_s)
      log.debug(message.inspect)

      key = exchange.key
      cached = cache_get(key)

      if exchange.response? && !cached.nil?
        cache_delete(key)
      elsif exchange.request?
        handle_request(exchange, key, cached)
      end
    end

    def handle_request(exchange, key, cached)
      if exchange.con? && !cached.nil? #&& !exchange.idempotent?
        response = cached[0]
        log.debug("dedup cache hit #{exchange.mid}")
      else
        response, _ = respond(exchange)
      end

      unless response.nil?
        exchange.host
        @socket.send(response.to_wire, 0, exchange.host, exchange.port)
        cache_add(key, response) if response.tt == :ack
      end
    end

    def ipv6?
      IPAddr.new(@host).ipv6?
    end

    def shutdown
      @socket.close unless @socket.nil?
    end
  end
end
