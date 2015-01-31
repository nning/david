#\ -o ::1 -p 5683 -O Block=false -O Multicast=false -O Observe=false -O Log=none

require 'bundler/setup'
Bundler.setup

require 'david'
run Rack::HelloWorld.new
