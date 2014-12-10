require 'david/server/multicast'
require 'david/server/options'
require 'david/server/respond'

module David
  class Server
    include Celluloid::IO
    include CoAP::Codification

    include Multicast
    include Options
    include Respond

    attr_reader :logger, :socket

    finalizer :shutdown

    def initialize(app, options)
      @block   = choose(:block,   options[:Block])
      @cbor    = choose(:cbor,    options[:CBOR])
      @host    = choose(:host,    options[:Host])
      @logger  = choose(:logger,  options[:Log])
      @mcast   = choose(:mcast,   options[:Multicast])
      @observe = choose(:observe, options[:Observe])
      @port    = options[:Port].to_i

      @app     = app.respond_to?(:new) ? app.new : app

      @cache   = {}

      logger.info "David #{David::VERSION} on #{RUBY_DESCRIPTION}"
      logger.info "Starting on [#{@host}]:#{@port}"

      @ipv6 = IPAddr.new(@host).ipv6?
      af = @ipv6 ? ::Socket::AF_INET6 : ::Socket::AF_INET

      # Actually Celluloid::IO::UDPSocket.
      @socket = UDPSocket.new(af)

      begin
        multicast_initialize if @mcast
      rescue Errno::ENODEV, Errno::EADDRNOTAVAIL
        logger.warn 'Multicast initialization failure: Device not found.'
        @mcast = false
      end

      @socket.bind(@host, @port)

      async.run
    end

    private

    def cache_response(request, response)
      unless duplicate?(request)
        @cache[[request.host, request.port, request.mid]] =
          [response, request.options]
      end
    end

    def cached_response(request)
      @cache[[request.host, request.port, request.mid]]
    end

    def duplicate?(request)
      return !!cached_response(request)
    end

    def handle_input(*args)
      data, sender, _, anc = args
      host, port = sender.ip_address, sender.ip_port

      message = CoAP::Message.parse(data)
      request = Request.new(host, port, message, anc)

      return unless request.con? || request.non?
      return unless request.valid_method?
      return if !request.non? && request.multicast?

      logger.info "[#{host}]:#{port}: #{message}"
      logger.debug message.inspect

      if duplicate?(request) && request.non?
        response, options = cached_response(request)
        logger.debug "(duplicate #{request.mid})"
      else
        response, options = respond(request)
      end

      unless response.nil?
        logger.debug response.inspect

        CoAP::Ether.send(response, host, port, options.merge(socket: @socket))

        request.options = options
        cache_response(request, response)
      end
    end

    def run
      loop do
        begin
          async.handle_input(*@socket.to_io.recvmsg_nonblock)
        rescue ::IO::WaitReadable
          Celluloid::IO.wait_readable(@socket)
          retry
        end
      end
    end

    def shutdown
      @socket.close unless @socket.nil?
    end
  end
end
