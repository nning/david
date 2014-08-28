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

$: << File.dirname(__FILE__)

require 'rack/hello_world'
require 'rack/handler/david'
require 'rack/handler/coap'

require 'david/guerilla/rack/handler'

require 'david/version'
require 'david/server'

if defined? Rails
  require 'david/railties/config'
  require 'david/railties/middleware'
end
