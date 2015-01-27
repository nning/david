require 'benchmark/ips'

max = 10000

keys1  = ([0]*max).map { rand(0..99999).to_s }
keys2  = ([0]*max).map { rand(0..99999) }
values = ([0]*max).map { rand(0..99999) }

a = {}
b = {}

Benchmark.ips do |x|
  x.report('Array key (insert)') do
    max.times do |i|
      a[[keys1[i], keys2[i]]] = values[i]
    end
  end

  x.report('Nested Hash (insert)') do
    max.times do |i|
      if b[keys1[i]].nil?
        b[keys1[i]] = {keys2[i] => values[i]}
      else
        b[keys1[i]].merge!(keys2[i] => values[i])
      end
    end
  end

  x.report('Set key (insert)') do
    max.times do |i|
      key = Set.new
      key << keys1[i]
      key << keys2[i]
      a[key] = values[i]
    end
  end

  x.compare!
end

Benchmark.ips do |x|
  x.report('Array key (lookup)') do
    max.times do |i|
      v = a[[keys1[i], keys2[i]]]
    end
  end

  x.report('Nested Hash (lookup)') do
    max.times do |i|
      v = b[keys1[i]][keys2[i]]
    end
  end

  x.report('Set key (lookup)') do
    max.times do |i|
      key = Set.new
      key << keys1[i]
      key << keys2[i]
      v = a[key]
    end
  end

  x.compare!
end
