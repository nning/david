module David
  class Server
    # See https://tools.ietf.org/html/rfc7252#section-12.8
    module Multicast
      def multicast_initialize
        @socket.to_io.setsockopt(:SOL_SOCKET, :SO_REUSEADDR, 1)

        if @ipv6
          maddrs = ['ff02::fd', 'ff05::fd']
          maddrs << 'ff02::1' if OS.osx? # OSX needs ff02::1 explicitly joined.
          maddrs.each { |maddr| multicast_listen_ipv6(maddr) }

          setsockopts_ipv6
        else
          maddrs = ['224.0.1.187']
          multicast_listen_ipv4(maddrs.first)

          setsockopts_ipv4
        end

        logger.debug "Joined multicast groups: #{maddrs.join(', ')}"
      rescue Errno::ENODEV, Errno::EADDRNOTAVAIL
        logger.warn 'Multicast initialization failure: Device not found.'
        @mcast = false
      end

      def multicast_listen_ipv4(address)
        mreq = IPAddr.new(address).hton + IPAddr.new('0.0.0.0').hton
        @socket.to_io.setsockopt(:IPPROTO_IP, :IP_ADD_MEMBERSHIP, mreq)
      end

      def multicast_listen_ipv6(address)
        ifindex = 0

        # http://lists.apple.com/archives/darwin-kernel/2014/Mar/msg00012.html
        if OS.osx?
          ifname  = Socket.if_up?('en1') ? 'en1' : 'en0'
          ifindex = Socket.if_nametoindex(ifname)
        end

        mreq = IPAddr.new(address).hton + [ifindex].pack('i_')
        @socket.to_io.setsockopt(:IPPROTO_IPV6, :IPV6_JOIN_GROUP, mreq)
      end

      def setsockopts_ipv4
        @socket.to_io.setsockopt(:IPPROTO_IP, :IP_PKTINFO, 1)
      end

      def setsockopts_ipv6
        @socket.to_io.setsockopt(:IPPROTO_IPV6, :IPV6_RECVPKTINFO, 1)
      end
    end
  end
end
