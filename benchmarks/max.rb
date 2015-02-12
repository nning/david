#!/usr/bin/env ruby
require 'csv'
puts CSV.parse(File.read(ARGV[0])).map { |x| x[2].to_f }.unshift.max
