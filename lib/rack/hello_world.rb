module Rack
  class HelloWorld
#   include Celluloid

    def call(env)
      dup._call(env)
    end

    def _call(env)
      if env['REQUEST_METHOD'] != 'GET'
        return [405, {}, ['']]
      end

      return case env['PATH_INFO']
      when '/.well-known/core'
        [200,
          {'Content-Type' => 'application/link-format'},
          ['</hello>;rt="hello";ct=0']
        ]
      when '/echo/accept'
        [200,
          {'Content-Type' => env['HTTP_ACCEPT'], 'Content-Length' => '0'},
          []
        ]
      when '/hello'
        [200,
          # If Content-Length is not given, Rack assumes chunked transfer.
          {'Content-Type' => 'text/plain', 'Content-Length' => '12'},
          ['Hello World!']
        ]
      when '/wait'
        sleep 10
        [200,
          {'Content-Type' => 'text/plain'},
          ['You waited!']
        ]
      when '/value'
        @@value ||= 0
        @@value  += 1

        [200,
          {'Content-Type' => 'text/plain'},
          ["#{@@value}"]
        ]
      when '/block'
        n = 17
        [200,
          {'Content-Type' => 'text/plain', 'Content-Length' => n.to_s},
          ['+'*n]
        ]
      when '/code'
        [2.05,
          {'Content-Type' => 'text/plain'},
          []
        ]
      when '/time'
        # Rack::ETag does not add an ETag header, if response code other than
        # 200 or 201, so CoAP/Float return codes do not work, here.
        [200,
          {'Content-Type' => 'text/plain'},
          [Time.now.to_s]
        ]
      when '/cbor'
        require 'json'

        body = JSON.parse(env['rack.input'].read).to_s

        [200,
          {
            'Content-Type' => 'text/plain',
            'Content-Length' => body.bytesize.to_s
          },
          [body]
        ]
      when '/json'
        require 'json'

        body = {'Hello' => 'World!'}.to_json

        [200,
          {
            'Content-Type' => 'application/json',
            'Content-Length' => body.bytesize.to_s
          },
          [body]
        ]
      else
        [404, {}, ['']]
      end
    end
  end
end
