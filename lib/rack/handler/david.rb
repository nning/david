module Rack
  module Handler
    class David
      DEFAULT_OPTIONS = {
        :Host => ENV['RACK_ENV'] == 'development' ? '::1' : '::',
        :Port => ::CoAP::PORT
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
        environment = ENV['RACK_ENV'] || 'development'
        default_host = environment == 'development' ? '::1' : '::'

        {
          'Host=HOST'   => "Hostname to listen on (default: #{default_host})",
          'Port=PORT'   => "Port to listen on (default: #{::CoAP::PORT})",
          'Debug=DEBUG' => 'Debug output.',
        }
      end
    end

    register :david, David
  end
end
