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

  def r
    rand(0..9999)
  end

  x.report('ThreadSafe::Hash') do
    p.run { a[[r.to_s, r]] = [r] }
  end

  x.report('Hash') do
    p.run { b[[r.to_s, r]] = [r] }
  end

  x.report('ThreadSafe::Cache') do
    p.run { c[[r.to_s, r]] = [r] }
  end

  x.compare!
end
