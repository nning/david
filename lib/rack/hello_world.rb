module Rack
  class HelloWorld
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
      when '/hello'
        [200,
          {'Content-Type' => 'text/plain'},
          ['Hello World!']
        ]
      when '/wait'
        sleep 10
        [200,
          {'Content-Type' => 'text/plain'},
          ['You waited!']
        ]
      else
        [404, {}, ['']]
      end
    end
  end
end
