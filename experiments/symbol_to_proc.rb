require 'benchmark/ips'

Benchmark.ips do |x|
  a = [0..99999]

  x.report('map') do
    a.map { |e| e.to_s }
  end

  x.report('symbol to proc') do
    a.map(&:to_s)
  end

  x.compare!
end
