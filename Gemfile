source 'https://rubygems.org'

gemspec

gem 'cbor', platforms: :ruby
gem 'coap', '~> 0.0.17.dev', github: 'nning/coap'

group :test do
  gem 'coveralls', require: false
end

group :development do
  gem 'sqlite3', platforms: :ruby
  gem 'activerecord-jdbcsqlite3-adapter', platforms: :jruby
end
