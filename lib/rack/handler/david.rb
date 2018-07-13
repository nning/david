module Rack
  module Handler
    class David
      def self.run(app, options={})
        g = Celluloid::Supervision::Container.run!

        g.supervise(as: :server_udp, type: ::David::Server::CoAP, args: [app, options])
        if options[:DTLS] == 'true'
          g.supervise(as: :server_dtls, type: ::David::Server::CoAPs, args: [app, options])
        end

        g.supervise(as: :gc, type: ::David::GarbageCollector)
        if options[:Observe] != 'false'
          g.supervise(as: :observe, type: ::David::Observe)
        end

        begin
          Celluloid::Actor[:server_udp].run
          if options[:DTLS] == 'true'
            Celluloid::Actor[:server_dtls].run
          end
        rescue Interrupt
          Celluloid.logger.info 'Terminated'
          Celluloid.logger = nil
          g.terminate
        end
      end

      def self.valid_options
        host, port, dport, maddrs =
          AppConfig::DEFAULT_OPTIONS.values_at(:Host, :Port, :PortDTLS, :MulticastGroups)

        {
          'Block=BOOLEAN'         => 'Support for blockwise transfer (default: true)',
          'CBOR=BOOLEAN'          => 'Transparent JSON/CBOR conversion (default: false)',
          'DTLS=BOOLEAN'          => 'DTLS support (default: false)',
          'DefaultFormat=F'       => 'Content-Type if CoAP accept option on request is undefined',
          'Host=HOST'             => "Hostname to listen on (default: #{host})",
          'Log=LOG'               => 'Change logging (debug|none)',
          'Multicast=BOOLEAN'     => 'Multicast support (default: true)',
          'MulticastGroups=ARRAY' => "Multicast groups (default: #{maddrs.join(', ')})",
          'Observe=BOOLEAN'       => 'Observe support (default: true)',
          'Port=PORT'             => "UDP port to listen on (default: #{port})",
          'PortDTLS=PORT'         => "DTLS port to listen on (default: #{dport})"
        }
      end
    end

    register(:david, David)
  end
end
