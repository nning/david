#\ -o ::1 -p 5683 -O Block=false -O Multicast=false -O Observe=false -O Log=debug -E none

module David; module ETSI; end; end

require 'bundler/setup'
Bundler.setup

require 'david'
require 'david/etsi/mandatory/rack'

run David::ETSI::Mandatory::Rack.new
