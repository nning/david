#\ -o ::1 -p 5683 -O Block=false -O Multicast=false -O Observe=false -O Log=debug -E none

module David; module Interop; end; end

require 'bundler/setup'
Bundler.setup

require 'david'
require 'david/interop/mandatory_etsi/rack'

run David::Interop::MandatoryETSI::Rack.new
