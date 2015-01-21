require 'david/server/deduplication'
require 'david/server/multicast'
require 'david/server/options'
require 'david/server/respond'

module David
  class Server
    include Celluloid::IO
    include Registry

    include Deduplication
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

      @dedup_cache = {}

      link(mid_cache)

      log.info "David #{David::VERSION} on #{RUBY_DESCRIPTION}"
      log.info "Starting on [#{@host}]:#{@port}"

      af = ipv6? ? ::Socket::AF_INET6 : ::Socket::AF_INET

      # Actually Celluloid::IO::UDPSocket.
      @socket = UDPSocket.new(af)
      multicast_initialize! if @mcast
      @socket.bind(@host, @port)

      async.run
    end

    private

    def dispatch(*args)
      data, sender, _, anc = args

      if defined?(JRuby)
        port, _, host = sender[1..3]
      else
        host, port = sender.ip_address, sender.ip_port
      end

      message  = CoAP::Message.parse(data)
      exchange = Exchange.new(host, port, message, anc)

      return if !exchange.non? && exchange.multicast?

      log.info('<- ' + exchange.to_s)
      log.debug(message.inspect)

      if exchange.response?
        mid_cache.delete(exchange)
      elsif exchange.request?
        handle_request(exchange)
      end
    end

    def handle_request(exchange)
      if exchange.con? && exchange.duplicate? #&& !exchange.idempotent?
        response = mid_cache.lookup(exchange)[0].message
        log.debug("dedup cache hit #{exchange.mid}")
      else
        response, _ = respond(exchange)
      end

      unless response.nil?
        exchange.message = response
        Transmission.new(@socket).send(exchange)
      end
    end

    def ipv6?
      IPAddr.new(@host).ipv6?
    end

    def run
      loop do
        if defined?(JRuby)
          async.dispatch(*@socket.recvfrom(1152))
        else
          begin
            async.dispatch(*@socket.to_io.recvmsg_nonblock)
          rescue ::IO::WaitReadable
            Celluloid::IO.wait_readable(@socket)
            retry
          end
        end
      end
    end

    def shutdown
      @socket.close unless @socket.nil?
    end
  end
end
