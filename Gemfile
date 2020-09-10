source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

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
  gem 'roda', '~> 2'

  gem 'rails', '~> 5.2.4', '>= 5.2.4.4'
  gem 'rspec-rails', '~> 3.5.2'

  gem 'sinatra', github: 'sinatra'
  gem 'rack-protection', github: 'sinatra'
end
