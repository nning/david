#!/usr/bin/env ruby

require 'benchmark/ips'

require 'coap'
include CoRE

uri = ARGV[0] || 'coap://[::1]/hello'

Benchmark.ips do |x|
  x.warmup  = 30
  x.time    = 30

  x.report(uri) do
    response = CoAP::Client.new.get_by_uri(uri)
    raise unless response.mcode == [2, 5]
  end

  x.compare!
end
