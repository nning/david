module David
end

require 'bundler/setup'
Bundler.require

unless defined? JRuby
  require 'cbor'
end

require 'celluloid'
require 'celluloid/io'
require 'coap'
require 'ipaddr'
require 'rack'

include CoRE

$:.unshift(File.expand_path(File.dirname(__FILE__)))

require 'rack/hello_world'
require 'rack/handler/david'
require 'rack/handler/coap'

require 'david/guerilla/rack/handler'

require 'david/observe'
require 'david/request'
require 'david/server'
require 'david/version'

if defined? Rails
  require 'david/railties/config'
  require 'david/railties/middleware'
end
