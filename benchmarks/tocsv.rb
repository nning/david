require 'csv'

def process_line(line)
  line.split(', ').map { |x| x.split('=')[1] }
end

def process_lines(lines)
  lines.map! { |line| process_line(line) }
  lines[0].zip(*lines[1..2]).map { |x| avg(*x.map(&:to_f)) }
end

def avg(*args)
  args.reduce(:+) / args.size.to_f
end

CSV.open(ARGV[0] + '.csv', 'wb') do |csv|
  csv << %w[concurrent total loss throughput]
  File.readlines(ARGV[0]).each_slice(3) do |lines|
    conc, _, total, loss, throughput = process_lines(lines)
    csv << [conc, (loss/total)*100, throughput].map { |x| x.round(5) }
  end
end
