module Rack
  module Handler
    class David
      def self.run(app, options={})
        g = Celluloid::SupervisionGroup.run!

        g.supervise_as(:server, ::David::Server, app, options)
        g.supervise_as(:gc, ::David::GarbageCollector)

        unless options[:Observe] == 'false'
          g.supervise_as(:observe, ::David::Observe)
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
        host, port = AppConfig::DEFAULT_OPTIONS.values_at(:Host, :Port)

        {
          'Block=BOOLEAN'     => 'Support for blockwise transfer (default: true)',
          'CBOR=BOOLEAN'      => 'Transparent JSON/CBOR conversion (default: false)',
          'DefaultFormat=F'   => 'Content-Type if CoAP accept option on request is undefined',
          'Host=HOST'         => "Hostname to listen on (default: #{host})",
          'Log=LOG'           => 'Change logging (debug|none)',
          'Multicast=BOOLEAN' => 'Multicast support (default: true)',
          'Observe=BOOLEAN'   => 'Observe support (default: true)',
          'Port=PORT'         => "Port to listen on (default: #{port})"
        }
      end
    end

    register(:david, David)
  end
end
