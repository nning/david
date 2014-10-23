require 'david/well_known'
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
        Rack::Lock,
        Rack::MethodOverride,
        Rack::Runtime,
      ]

      initializer 'david.clear_out_middleware' do |app|
        if config.coap.only
          UNWANTED.each { |klass| app.middleware.delete klass }
        end

        app.middleware.insert_after(Rails::Rack::Logger, David::WellKnown)
        app.middleware.swap(ActionDispatch::ShowExceptions, David::ShowExceptions)
      end
    end
  end
end
