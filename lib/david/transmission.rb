module David
  class Transmission
    include Registry

    AF_INET6 = 'AF_INET6'.freeze

    def initialize(socket)
      @log = Celluloid.logger
      @socket = socket || server.socket
    end

    # TODO Retransmissions
    def send(exchange)
      host = normalize_host(exchange.host)

      @socket.send(exchange.message.to_wire, 0, host, exchange.port)
      mid_cache.add(exchange)

      @log.info('-> ' + exchange.to_s)
      @log.debug(exchange.message.inspect)
    end

    private
    
    def ipv6?
      @socket.addr[0] == AF_INET6
    end

    def mid_cache
      Celluloid::Actor[:mid_cache]
    end

    def normalize_host(host)
      ip = IPAddr.new(Resolv.getaddress(host))

      if ipv6? && ip.ipv4?
        ip = ip.ipv4_mapped
      end
    rescue Resolv::ResolvError
    else 
      ip.to_s
    end
  end
end
