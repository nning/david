module David
  class Server
    # See https://tools.ietf.org/html/rfc7252#section-12.8
    module Multicast
      def multicast_initialize(socket, ipv6)
        if ipv6
          ['ff02::fd', 'ff05::fd'].each do |maddr|
            multicast_listen_ipv6(socket, maddr)
          end
        else
          multicast_listen_ipv4(socket, '224.0.1.187')
        end

        socket.to_io.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1)

        socket
      end

      def multicast_listen_ipv4(socket, address)
        mreq = IPAddr.new(address).hton + IPAddr.new('0.0.0.0').hton
        socket.to_io.setsockopt(Socket::IPPROTO_IP, Socket::IP_ADD_MEMBERSHIP, mreq)
      end

      def multicast_listen_ipv6(socket, address)
        #ifindex = Socket.getifaddrs.select { |x| x.name == 'lo' }.first.ifindex
        ifindex = 0
        mreq = IPAddr.new(address).hton + [ifindex].pack('i_')
        socket.to_io.setsockopt(Socket::IPPROTO_IPV6, Socket::IPV6_JOIN_GROUP, mreq)
      end
    end
  end
end
