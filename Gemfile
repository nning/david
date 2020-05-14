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

  gem 'grape', '>= 1.1.0'
  gem 'hobbit', '>= 0.6.1'
  gem 'nyny', '>= 2.2.1'
  gem 'roda', '~> 2', '>= 2.29.0'

  gem 'rails', '~> 5.1.6'
  gem 'rspec-rails', '~> 3.5.2'

  gem 'sinatra', github: 'sinatra'
  gem 'rack-protection', github: 'sinatra'
end
