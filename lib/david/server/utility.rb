module David
  class Server
    module Utility
      protected

      # This can only use each on body and currently does not support streaming.
      def body_to_string(body)
        p body
        s = ''
        body.each { |line| s << line.to_s << "\r\n" }
        body.close if body.respond_to?(:close)
        s.chomp
      end

      def ipv6?
        @ipv6 ||= IPAddr.new(@options[:Host]).ipv6?
      end

      def dtls?
        @dtls ||= defined? TinyDTLS::UDPSocket and
          @socket.is_a? TinyDTLS::UDPSocket
      end

      def jruby_or_rbx?
        @jruby_or_rbx ||= !!(defined?(JRuby) || defined?(Rubinius))
      end
    end
  end
end
