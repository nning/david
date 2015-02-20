require 'csv'

def process_line(line)
  line.split(', ').map { |x| x.split('=')[1] }
end

def process_lines(lines)
  lines.map { |line| process_line(line) }
end

def avg_lines(lines)
  ls = process_lines(lines)
  ls[0].zip(*ls[1..2]).map { |x| avg(*x.map(&:to_f)) }
end

def avg(*args)
  args.reduce(:+) / args.size.to_f
end

def sd_lines(lines)
  sd(*process_lines(lines).map { |a| a[4].to_f })
end

def sd(*args)
  avg = avg(*args)
  Math.sqrt(avg(*args.map { |x| (x - avg)**2 }))
end

CSV.open(ARGV[0] + '.csv', 'wb') do |csv|
  csv << %w[concurrent loss throughput sd]
  File.readlines(ARGV[0]).each_slice(3) do |lines|
    conc, _, total, loss, throughput = avg_lines(lines)
    sd = sd_lines(lines)
    csv << [conc, (loss/total)*100, throughput, sd].map { |x| x.round(5) }
  end
end
