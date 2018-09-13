module David
end

require 'bundler/setup'
Bundler.require(:default, :cbor)

unless defined?(JRuby)
  begin
    require 'cbor'
  rescue LoadError
    $stderr << "`gem install cbor` for transparent JSON/CBOR conversion "
    $stderr << "support.\n"
  end

  begin
    require 'tinydtls'
  rescue LoadError
    $stderr << "`gem install tinydtls` for DTLs support.\n"
  end
end

require 'celluloid/current'
require 'celluloid/io'
require 'coap'
require 'forwardable'
require 'ipaddr'
require 'rack'

include CoRE

$:.unshift(File.expand_path(File.dirname(__FILE__)))

require 'rack/hello_world'
require 'rack/handler/david'
require 'rack/handler/coap'

require 'david/guerilla/rack/handler'
require 'david/guerilla/rack/utils'

require 'david/actor'
require 'david/registry'
require 'david/exchange'
require 'david/garbage_collector'
require 'david/transmitter'
require 'david/version'

require 'david/observe'
require 'david/server'

if defined?(Rails)
  require 'david/rails/action_controller/base'

  require 'david/railties/config'
  require 'david/railties/middleware'
end
