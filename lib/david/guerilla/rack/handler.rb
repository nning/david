# Monkey-patch Rack to first try David.
# https://github.com/rack/rack/blob/master/lib/rack/handler.rb#L46-L61
module Rack
  module Handler
    def self.default(options = {})
      # Guess.
      if ENV.include?("PHP_FCGI_CHILDREN")
        # We already speak FastCGI
        options.delete :File
        options.delete :Port
        Rack::Handler::FastCGI
      elsif ENV.include?("REQUEST_METHOD")
        Rack::Handler::CGI
      elsif ENV.include?("RACK_HANDLER")
        self.get(ENV["RACK_HANDLER"])
      else
        # Change original Rack handler order.
        handlers = ['david', 'thin', 'puma', 'webrick']

        if defined?(Rails)
          # If Rails is loaded, remove david as first handler if
          # config.coap.only is set to false.
          if Rails.application && !Rails.application.config.coap.only
            handlers = handlers[1..-1]
          end
        end

        pick handlers
      end
    end
  end
end
