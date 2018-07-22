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

  begin
    s.files = `git ls-files`.split($/)
  rescue
    s.files = Dir.glob('**/*').select { |x| x !~ /.*\.gem$/ }
  end

  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.add_runtime_dependency 'celluloid',    '~> 0.17.3'
  s.add_runtime_dependency 'celluloid-io', '~> 0.17.3'
  s.add_runtime_dependency 'coap',         '~> 0.1'
  s.add_runtime_dependency 'rack',         '~> 2.0'

  s.add_development_dependency 'rake',  '~> 0'
  s.add_development_dependency 'rspec', '~> 3.2'
end
