#\ -o :: -p 5683 -O Log=debug

require_relative 'lib/david'
require_relative 'lib/rack/hello_world'

use Rack::ETag

run Rack::HelloWorld.new
