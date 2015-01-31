#\ -o ::1 -p 5683 -O Block=false -O Multicast=false -O Observe=false -O Log=none

require 'bundler/setup'
Bundler.setup

require_relative '../../spec/dummy/config/application'

module Dummy
  class Application
    config.middleware.delete(Rack::ETag)
  end
end

run Rails.application.initialize!
