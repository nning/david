#\ -o :: -p 5683 -O Log=debug

require_relative 'lib/david'

class Example
  def call(env)
    dup._call(env)
  end

  def _call(env)
    if env['REQUEST_METHOD'] != 'GET'
      return [405, {}, ['']]
    end

    return case env['PATH_INFO']
    when '/hello'
      message = 'Hello, World!'

      [200,
        # If Content-Length is not given, Rack assumes chunked transfer.
        {'Content-Type' => 'text/plain', 'Content-Length' => message.size.to_s},
        [message]
      ]
    when '/time'
      # Rack::ETag does not add an ETag header, if response code other than
      # 200 or 201, so CoAP/Float return codes do not work, here.
      [200,
        {'Content-Type' => 'text/plain'},
        [Time.now.to_s]
      ]
    else
      [404, {}, ['']]
    end
  end
end

use Rack::ETag
run Example.new
