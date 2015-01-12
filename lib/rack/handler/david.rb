module Rack
  module Handler
    class David
      DEFAULT_OPTIONS = {
        :Host => ENV['RACK_ENV'] == 'development' ? '::1' : '::',
        :Port => ::CoAP::PORT
      }

      def self.run(app, options={})
        options = DEFAULT_OPTIONS.merge(options)

        g = Celluloid::SupervisionGroup.run!

        g.supervise_as(:server, ::David::Server, app, options)
        g.supervise_as(:observe, ::David::Observe) if options[:Observe] != false
        g.supervise_as(:gc, ::David::GarbageCollector)

        begin
          sleep
        rescue Interrupt
          Celluloid.logger.info 'Terminated'
          Celluloid.logger = nil
          g.terminate
        end
      end

      def self.valid_options
        host, port = DEFAULT_OPTIONS.values_at(:Host, :Port)

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

    register :david, David
  end
end
