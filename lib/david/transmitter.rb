module David
  class Transmitter
    include Registry

    AF_INET6 = 'AF_INET6'.freeze

    def initialize(socket)
      @log = Celluloid.logger
      @socket = socket
    end

    # TODO Retransmissions
    def send(exchange)
      host = normalize_host(exchange.host)

      @socket.send(exchange.message.to_wire, 0, host, exchange.port)

      @log.info('-> ' + exchange.to_s)
      @log.debug(exchange.message.inspect)
    end

    private
    
    def ipv6?
      @socket.addr[0] == AF_INET6
    end

    def normalize_host(host)
      ip = IPAddr.new(host)

      if ipv6? && ip.ipv4?
        ip = ip.ipv4_mapped
      end
    rescue ArgumentError
      begin
        host = Resolv.getaddress(host)
        retry
      rescue Resolv::ResolvError
      end
    else 
      ip.to_s
    end
  end
end
