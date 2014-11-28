require 'david/resource_discovery_proxy'
require 'david/show_exceptions'

module David
  module Railties
    class Middleware < Rails::Railtie
      UNWANTED = [
        ActionDispatch::Cookies,
        ActionDispatch::DebugExceptions,
        ActionDispatch::Flash,
        ActionDispatch::RemoteIp,
        ActionDispatch::RequestId,
        ActionDispatch::Session::CookieStore,
        Rack::ConditionalGet,
        Rack::Head,
        Rack::MethodOverride,
        Rack::Runtime,
      ]

      initializer 'david.clear_out_middleware' do |app|
        # Remove middleware not applicable to CoAP
        if config.coap.only
          UNWANTED.each { |klass| app.middleware.delete(klass) }
        end

        # Enable multithreading for Rails
        app.middleware.delete(Rack::Lock)

        # Show exceptions as JSON
        app.middleware.swap \
          ActionDispatch::ShowExceptions,
          David::ShowExceptions

        # Include Resource Discovery middleware
        if config.coap.resource_discovery
          app.middleware.insert_after \
            David::ShowExceptions,
            David::ResourceDiscoveryProxy
        end
      end
    end
  end
end
