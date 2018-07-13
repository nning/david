module David
  class Server
    class CoAP < Server
      def create_socket(af)
        Celluloid::IO::UDPSocket.new(af)
      end

      def port_key
        :Port
      end

      def protocol_scheme
        "coap"
      end
    end
  end
end
