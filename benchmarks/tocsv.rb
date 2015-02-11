require 'csv'

CSV.open(ARGV[0] + '.csv', 'wb') do |csv|
  csv << %w[concurrent time total loss throughput]
  File.readlines(ARGV[0]).each do |line|
    csv << line.split(', ').map { |x| x.split('=')[1] }[0..4]
  end
end
