require 'david/server/options'
require 'david/server/response'

module David
  class Server
    include Celluloid::IO
    include CoAP::Codification

    include Options
    include Response

    attr_reader :logger

    finalizer :shutdown

    def initialize(app, options)
      @cbor   = choose(:cbor,   options[:CBOR])
      @host   = choose(:host,   options[:Host])
      @logger = choose(:logger, options[:Debug])
      @port   = options[:Port].to_i

      @app    = app.respond_to?(:new) ? app.new : app

      logger.info "David #{David::VERSION} on #{RUBY_DESCRIPTION}"
      logger.info "Starting on [#{@host}]:#{@port}"

      ipv6 = IPAddr.new(@host).ipv6?
      af = ipv6 ? ::Socket::AF_INET6 : ::Socket::AF_INET

      # Actually Celluloid::IO::UDPServer.
      # (Use celluloid-io from git, 0.15.0 does not support AF_INET6).
      @socket = UDPSocket.new(af)
      @socket.bind(@host, @port)

      async.run
    end

    private

    def shutdown
      @socket.close unless @socket.nil?
    end

    def run
      loop { async.handle_input(*@socket.recvfrom(1024)) }
    end

    def answer(host, port, message)
      @socket.send(message.to_wire, 0, host, port)
    end

    def handle_input(data, sender)
      _, port, host = sender
      request = CoAP::Message.parse(data)

      logger.info "[#{host}]:#{port}: #{request}"
      logger.debug request.inspect

      response = respond(host, port, request)

      logger.debug response.inspect

      answer(host, port, response)
    end
  end
end
