#\ -o ::1 -p 5683 -O Block=false -O Multicast=false -O Observe=false -O Log=none

require_relative '../lib/david'

run Rack::HelloWorld.new
