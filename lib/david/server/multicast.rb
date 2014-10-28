module David
  class Server
    # See https://tools.ietf.org/html/rfc7252#section-12.8
    module Multicast
      def multicast_initialize
        @socket.to_io.setsockopt(:SOL_SOCKET, :SO_REUSEADDR, 1)

        if @ipv6
          maddrs = ['ff02::fd', 'ff05::fd']
          maddrs.each { |maddr| multicast_listen_ipv6(maddr) }
        else
          maddrs = ['224.0.1.187']
          multicast_listen_ipv4(maddrs.first)
        end

        logger.debug "Joined multicast groups: #{maddrs.join(', ')}."
      end

      def multicast_listen_ipv4(address)
        mreq = IPAddr.new(address).hton + IPAddr.new('0.0.0.0').hton
        @socket.to_io.setsockopt(:IPPROTO_IP, :IP_ADD_MEMBERSHIP, mreq)
      end

      def multicast_listen_ipv6(address)
        mreq = IPAddr.new(address).hton + [0].pack('i_')
        @socket.to_io.setsockopt(:IPPROTO_IPV6, :IPV6_JOIN_GROUP, mreq)
      end
    end
  end
end
