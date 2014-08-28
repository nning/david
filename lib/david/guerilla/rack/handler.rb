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
        pick ['david', 'thin', 'puma', 'webrick']
      end
    end
  end
end
