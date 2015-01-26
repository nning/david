#!/usr/bin/env ruby

require 'benchmark/ips'

require 'celluloid'
Celluloid.logger = nil

require 'coap'
include CoRE

uri = ARGV[0] || 'coap://[::1]/hello'
n = (ARGV[1] || 100).to_i

class Tester
  include Celluloid

  def run(uri)
    response = CoAP::Client.new.get_by_uri(uri)
    raise unless response.mcode == [2, 5]
  end
end

Benchmark.ips do |x|
  x.warmup  = 30
  x.time    = 30

  x.report(uri) do
    Tester.pool(size: n).run(uri)
  end

  x.compare!
end
