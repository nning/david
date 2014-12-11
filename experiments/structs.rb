require 'benchmark'

Foo = Struct.new(:a, :b, :c)
Bar = Struct.new(:a, :b, :c)

data = []

arrays  = {}
structs = {}

1000000.times do
  a, b, c = ([0]*3).map { rand(0..9999) }
  data.push [a, b, c]
end

Benchmark.bm do |x|
  x.report('fill arrays ') do
    data.each do |d|
      a, b, c = d
      arrays[[a, b, c]] = [a, b, c]
    end
  end

  x.report('fill structs') do
    data.each do |d|
      a, b, c = d
      structs[Foo.new(a, b, c)] = Bar.new(a, b, c)
    end
  end


  x.report('read arrays ') do
    100000.times do
      a, b, c = data.sample
      arrays[[a, b, c]]
    end
  end

  x.report('read structs') do
    100000.times do
      a, b, c = data.sample
      structs[Foo.new(a, b, c)]
    end
  end
end
