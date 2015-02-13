module David::ETSI::Optional
  class Rack
    def call(env)
      return case request(env)
      when 'GET /large'
        [2.05, {'Content-Type' => 'text/plain'}, ['*'*1025]]
      when 'GET /obs'
        [2.05,
          {
            'Content-Type' => 'text/plain',
            'ETag' => rand(0xffff).to_s
          },
          [Time.now.to_s]
        ]
      else
        [4.04, {}, []]
      end
    end

    private

    def request(env)
      env['REQUEST_METHOD'] + ' ' + env['PATH_INFO']
    end
  end
end
