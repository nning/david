module David::Interop::MandatoryETSI
  class Rack
    def call(env)
      return case [env['REQUEST_METHOD'], env['PATH_INFO']]
      when ['GET', '/test']
        [2.05, {'Content-Type' => 'text/plain'}, []]
      when ['POST', '/test']
        [2.01, {}, []]
      when ['PUT', '/test']
        [2.04, {}, []]
      when ['DELETE', '/test']
        [2.02, {}, []]
      end
    end
  end
end
