$:.unshift File.expand_path('lib', File.dirname(__FILE__))
require 'david/version'

Gem::Specification.new do |s|
  s.name = 'david'
  s.version = David::VERSION

  s.summary = 'CoAP server with Rack interface.'
  s.description = "David is a CoAP server with Rack interface to bring the
    illustrious family of Rack compatible web frameworks into the Internet of
    Things."

  s.homepage = 'https://github.com/nning/david'
  s.license  = 'MIT'
  s.author   = 'henning mueller'
  s.email    = 'henning@orgizm.net'

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.add_dependency 'celluloid-io', '~> 0.16', '>= 0.16.1'
  s.add_dependency 'coap',         '>= 0.1'
  s.add_dependency 'rack',         '~> 1.6'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 3.2'
end
