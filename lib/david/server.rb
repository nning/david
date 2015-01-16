require 'david/server/deduplication'
require 'david/server/multicast'
require 'david/server/options'
require 'david/server/respond'

module David
  class Server
    include Celluloid::IO
    include CoAP::Coding

    include Deduplication
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

      @default_format = choose(:default_format, options[:DefaultFormat])

      @dedup_cache = {}

      logger.info "David #{David::VERSION} on #{RUBY_DESCRIPTION}"
      logger.info "Starting on [#{@host}]:#{@port}"

      @ipv6 = IPAddr.new(@host).ipv6?
      af = @ipv6 ? ::Socket::AF_INET6 : ::Socket::AF_INET

      # Actually Celluloid::IO::UDPSocket.
      @socket = UDPSocket.new(af)
      multicast_initialize if @mcast
      @socket.bind(@host, @port)

      async.run
    end

    private

    def handle_input(*args)
      data, sender, _, anc = args
      host, port = sender.ip_address, sender.ip_port

      message = CoAP::Message.parse(data)
      request = Request.new(host, port, message, anc)

      return unless request.con? || request.non?
      return unless request.valid_method?
      return if !request.non? && request.multicast?

      logger.info "[#{host}]:#{port}: #{message} (block #{request.block.num})"
      logger.debug message.inspect

      if request.con? && duplicate?(request) #&& !request.idempotent?
        response, options = cached_response(request)
        logger.debug "(mid:#{request.mid} duplicate, response cached)"
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
