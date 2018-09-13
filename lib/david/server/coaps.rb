module David
  class Server
    class CoAPs < Server
      def create_socket(af)
        socket = TinyDTLS::UDPSocket.new(af)
        socket.add_client("foobar", "foobar")

        return socket
      end

      def port_key
        :PortDTLS
      end

      def protocol_scheme
        "coaps"
      end
    end
  end
end
