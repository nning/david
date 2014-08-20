require 'bundler/setup'
Bundler.require

require 'benchmark'

include CoRE

uri  = ARGV.pop
n, c = ARGV.map(&:to_i)

threads = []

c.times do
  threads << Thread.start do
    n.times do |i|
      CoAP::Client.new.get_by_uri(uri)
    end
  end
end

Benchmark.bm do |b|
  b.report { threads.map(&:join) }
end
