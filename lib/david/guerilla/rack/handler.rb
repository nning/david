# Monkey-patch Rack to first try David.
# https://github.com/rack/rack/blob/master/lib/rack/handler.rb#L46
module Rack
  module Handler
    def self.default(options = {})
      # Guess.
      if ENV.include?("PHP_FCGI_CHILDREN")
        Rack::Handler::FastCGI
      elsif ENV.include?(REQUEST_METHOD)
        Rack::Handler::CGI
      elsif ENV.include?("RACK_HANDLER")
        self.get(ENV["RACK_HANDLER"])
      else
        # Return David as handler unless Rails is loaded and config.coap.only
        # is set to false.
        return Rack::Handler::David unless rails_coap_only

        # Original Rack handler order.
        pick ['puma', 'thin', 'webrick']
      end
    end

    private

    def self.rails_coap_only
      defined?(Rails) && Rails.application &&
        !Rails.application.config.coap.only
    end
  end
end
