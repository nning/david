source 'https://rubygems.org'

gemspec

gem 'coap', '~> 0.0.17.dev', github: 'nning/coap'

group :cbor do
  gem 'cbor', platforms: :ruby
end

group :development do
  gem 'sqlite3', platforms: :ruby
  gem 'activerecord-jdbcsqlite3-adapter', platforms: :jruby
end

group :test do
  gem 'coveralls', require: false
end
