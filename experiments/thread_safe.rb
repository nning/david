require 'benchmark/ips'
require 'celluloid'
require 'thread_safe'

class Stresser
  include Celluloid

  def run(&block)
    block.call
  end
end

Benchmark.ips do |x|
  x.time = 60
  x.warmup = 60

  a = ThreadSafe::Hash.new
  b = Hash.new
  c = ThreadSafe::Cache.new

  p = Stresser.pool(size: 1000)

  range = 0..99999

  x.report('ThreadSafe::Hash') do
    p.run { a[rand(range)] = rand(range) }
  end

  x.report('Hash') do
    p.run { b[rand(range)] = rand(range) }
  end

  x.report('ThreadSafe::Cache') do
    p.run { c[rand(range)] = rand(range) }
  end

  x.compare!
end
