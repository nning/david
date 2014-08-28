module David
end

require 'bundler/setup'
Bundler.require

require 'cbor'
require 'celluloid'
require 'celluloid/io'
require 'coap'
require 'ipaddr'
require 'rack'

include CoRE

require_relative 'rack/hello_world'
require_relative 'rack/handler/david'
require_relative 'rack/handler/coap'

require_relative 'david/guerilla/rack/handler'

require_relative 'david/version'
require_relative 'david/server'

if defined? Rails
  require_relative 'david/railties/config'
  require_relative 'david/railties/middleware'
end
