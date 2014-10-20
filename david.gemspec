require_relative 'lib/david/version'

Gem::Specification.new do |s|
  s.name = 'david'
  s.version = David::VERSION

  s.summary = 'CoAP server with Rack interface.'
  s.description = "David is a CoAP server with Rack interface to bring the
    illustrious family of Rack compatible web frameworks into the Internet of
    Things."

  s.homepage = 'https://github.com/nning/david'
  s.license  = 'GPL-3.0'
  s.author   = 'henning mueller'
  s.email    = 'henning@orgizm.net'

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.add_dependency 'cbor',         '~> 0.5'
  s.add_dependency 'celluloid-io', '~> 0.16'
  s.add_dependency 'coap',         '~> 0'
  s.add_dependency 'rack',         '~> 1.5'
end
