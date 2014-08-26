module David
  class Railtie < Rails::Railtie
    UNWANTED = [
      ActionDispatch::Cookies,
      ActionDispatch::DebugExceptions,
      ActionDispatch::Flash,
      ActionDispatch::RemoteIp,
      ActionDispatch::RequestId,
      ActionDispatch::Session::CookieStore,
      ActionDispatch::ShowExceptions,
      Rack::ETag,
      Rack::Lock,
    ]

    initializer 'david.clear_out_middleware', after: true do |app|
      UNWANTED.each { |klass| app.middleware.delete klass }
    end
  end
end
