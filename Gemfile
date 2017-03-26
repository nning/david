source 'https://rubygems.org'

gemspec

group :cbor do
  gem 'cbor', platforms: :ruby
end

group :development do
  gem 'ruby-prof', platforms: :mri
end

group :test do
  gem 'coveralls', require: false

  gem 'grape'
  gem 'hobbit'
  gem 'nyny'
  gem 'roda'

  gem 'rails', '~> 5.0.0'
  gem 'rspec-rails', '~> 3.5.0'

  gem 'sinatra', github: 'sinatra'
  gem 'rack-protection', github: 'sinatra'
end
