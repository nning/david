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
        if config.coap.only
          UNWANTED.each { |klass| app.middleware.delete(klass) }
        end

        app.middleware.delete(Rack::Lock)

        app.middleware.swap(ActionDispatch::ShowExceptions, David::ShowExceptions)
        app.middleware.insert_after(David::ShowExceptions, David::ResourceDiscoveryProxy)
      end
    end
  end
end
