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
      @block  = choose(:block,  options[:Block])
      @cbor   = choose(:cbor,   options[:CBOR])
      @host   = choose(:host,   options[:Host])
      @logger = choose(:logger, options[:Log])
      @mcast  = choose(:mcast,  options[:Multicast])
      @port   = options[:Port].to_i

      @app    = app.respond_to?(:new) ? app.new : app

      logger.info "David #{David::VERSION} on #{RUBY_DESCRIPTION}"
      logger.info "Starting on [#{@host}]:#{@port}"

      ipv6 = IPAddr.new(@host).ipv6?
      af = ipv6 ? ::Socket::AF_INET6 : ::Socket::AF_INET

      # Actually Celluloid::IO::UDPSocket.
      @socket = UDPSocket.new(af)

      multicast_listen(@socket, ipv6) if @mcast

      @socket.bind(@host, @port)

      async.run
    end

    private

    def handle_input(data, sender)
      _, port, host = sender
      request = CoAP::Message.parse(data)

      return unless [:con, :non].include?(request.tt)

      logger.info "[#{host}]:#{port}: #{request}"
      logger.debug request.inspect

      response, options = respond(host, port, request)

      unless response.nil?
        logger.debug response.inspect
        CoAP::Ether.send(response, host, port, options.merge(socket: @socket))
      end
    end

    # See https://tools.ietf.org/html/rfc7252#section-12.8
    def multicast_listen(socket, ipv6)
      if ipv6
        ['ff02::fd', 'ff05::fd'].each do |maddr|
          mreq = IPAddr.new(maddr).hton + [0].pack('i_')
          @socket.to_io.setsockopt(Socket::IPPROTO_IPV6,
            Socket::IPV6_JOIN_GROUP, mreq)
        end
      else
        mreq = IPAddr.new('224.0.1.187').hton + IPAddr.new('0.0.0.0').hton
        @socket.to_io.setsockopt(Socket::IPPROTO_IP, Socket::IP_ADD_MEMBERSHIP,
          mreq)
      end

      @socket
    end

    def run
      loop { async.handle_input(*@socket.recvfrom(1024)) }
    end

    def shutdown
      @socket.close unless @socket.nil?
    end
  end
end
