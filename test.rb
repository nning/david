require 'bundler/setup'
Bundler.require

require 'benchmark'

include CoRE

#uri = ARGV.pop
uri  = 'coap://[::1]/value'
n, c = ARGV.map(&:to_i)

threads = []
value   = 0

c.times do
  threads << Thread.start do
    n.times do |i|
      new_value = CoAP::Client.new.get_by_uri(uri).payload.to_i
      value = new_value if new_value > value
    end
  end
end

Benchmark.bm do |b|
  b.report { threads.map(&:join) }
end

puts value

FileUtils.rm_f('tmp')

Benchmark.bm do |b|
  b.report do
    c.times do
      fork do
        value = 0

        n.times do |i|
          new_value = CoAP::Client.new.get_by_uri(uri).payload.to_i
          value = new_value if new_value > value
        end

        File.open('tmp', 'a') do |f|
          f.write("#{value}\n")
        end
      end
    end
  end
end

value = 0

File.readlines('tmp').each do |line|
  new_value = line.to_i
  value = new_value if new_value > value
end

puts value
