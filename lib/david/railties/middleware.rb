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
#       ActionDispatch::ShowExceptions,
        Rack::ConditionalGet,
        Rack::ETag,
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
      end
    end
  end
end
