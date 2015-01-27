require 'benchmark/ips'

def r
  rand(0..99999)
end

Benchmark.ips do |x|
  x.report('interpolation') do
    "foo #{r} #{r} #{r}"
  end

  x.report('addition') do
    'foo ' + r.to_s + ' ' + r.to_s
  end

  x.report('concatenation') do
    'foo ' << r.to_s << ' ' << r.to_s
  end

  x.compare!
end
