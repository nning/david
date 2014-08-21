module Rack
  module Handler
    class David
      def self.run(app, options={})
        environment = ENV['RACK_ENV'] || 'development'
        default_host = environment == 'development' ? '::1' : '::'

        host = options.delete(:Host) || default_host
        port = options.delete(:Port) || ::CoAP::PORT

        args = [host, port, app, options]

        ::David::Server.run(*args)
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
