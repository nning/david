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
#     ActionDispatch::ShowExceptions,
        Rack::ETag,
        Rack::Lock,
      ]

      initializer 'david.clear_out_middleware' do |app|
        if config.coap.only
          UNWANTED.each { |klass| app.middleware.delete klass }
        end
      end
    end
  end
end
