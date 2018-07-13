module Rack
  module Handler
    class David
      def self.run(app, options={})
        g = Celluloid::Supervision::Container.run!

        if options[:DTLS] == 'true'
          g.supervise(as: :server, type: ::David::Server::CoAPs,
                      args: [app, options.merge!(Port: "5684")])
        else
          g.supervise(as: :server, type: ::David::Server::CoAP,
                      args: [app, options])
        end

        g.supervise(as: :gc, type: ::David::GarbageCollector)
        if options[:Observe] != 'false'
          g.supervise(as: :observe, type: ::David::Observe)
        end

        begin
          Celluloid::Actor[:server].run
        rescue Interrupt
          Celluloid.logger.info 'Terminated'
          Celluloid.logger = nil
          g.terminate
        end
      end

      def self.valid_options
        host, port, maddrs =
          AppConfig::DEFAULT_OPTIONS.values_at(:Host, :Port, :MulticastGroups)

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
          'Port=PORT'             => "Port to listen on (default: #{port})"
        }
      end
    end

    register(:david, David)
  end
end
