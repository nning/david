module David
end

require 'bundler/setup'
Bundler.require

require 'ipaddr'

include CoRE

require_relative 'rack/hello_world'
require_relative 'rack/handler/david'

require_relative 'david/version'
require_relative 'david/server'
