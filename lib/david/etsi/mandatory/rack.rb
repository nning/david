module David::ETSI::Mandatory
  class Rack
    EMPTY_CONTENT = [2.05, {'Content-Type' => 'text/plain'}, ['foo']]

    def call(env)
      return case request(env)
      when 'GET /test', 'GET /seg1/seg2/seg3', 'GET /query'
        EMPTY_CONTENT
      when 'POST /test'
        [2.01, {}, []]
      when 'PUT /test'
        [2.04, {}, []]
      when 'DELETE /test'
        [2.02, {}, []]
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
