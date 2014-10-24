module Rack
  module Handler
    class David
      DEFAULT_OPTIONS = {
        :Host  => ENV['RACK_ENV'] == 'development' ? '::1' : '::',
        :Port  => ::CoAP::PORT
      }

      def self.run(app, options={})
        options = DEFAULT_OPTIONS.merge(options)

        supervisor = ::David::Server.supervise_as(:david, app, options)

        begin
          sleep
        rescue Interrupt
          supervisor.terminate
        end
      end

      def self.valid_options
        host, port = DEFAULT_OPTIONS.values_at(:Host, :Port)

        {
          'Block=BOOLEAN'     => 'Support for blockwise transfer.',
          'CBOR=BOOLEAN'      => 'Transparent JSON/CBOR conversion.',
          'Host=HOST'         => "Hostname to listen on (default: #{host})",
          'Log=LOG'           => 'Change logging (debug|none).',
          'Multicast=BOOLEAN' => 'Multicast support.',
          'Port=PORT'         => "Port to listen on (default: #{port})"
        }
      end
    end

    register :david, David
  end
end
