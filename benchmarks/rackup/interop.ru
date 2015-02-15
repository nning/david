#\ -o ::1 -p 5683 -O Multicast=false -O Log=debug -E none

module David; module ETSI; end; end

require 'bundler/setup'
Bundler.setup

require 'david'
require 'david/etsi/mandatory/rack'
require 'david/etsi/optional/rack'

apps = [
  David::ETSI::Mandatory::Rack.new,
  David::ETSI::Optional::Rack.new,
]

run Rack::Cascade.new(apps)
