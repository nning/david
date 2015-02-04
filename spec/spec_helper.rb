# Coveralls
require 'coveralls'
Coveralls.wear!
SimpleCov.start { add_filter 'spec/dummy' }

# Rails
ENV['RAILS_ENV'] ||= 'test'

require File.expand_path("../dummy/config/environment",  __FILE__)
require 'rspec/rails'

# David
$:.unshift(File.expand_path('../lib', File.dirname(__FILE__)))

require 'david'
require 'david/interop'

module David
  module TestHelper
    def debug
      @debug ||= ENV['DEBUG'].nil? ? 'none' : 'debug'
    end

    def random_port
      rand((2**10+1)..(2**16-1))
    end

    def req(method, path, options = {})
      payload = options.delete(:payload)
      options.merge!(mid: mid)

      client = CoAP::Client.new(retransmit: false, recv_timeout: 0.1)
      client.send(method, path, '::1', port, payload, options)
    end

    def supervised_server(options)
      defaults = {
        :Host => '::1',
        :Port => CoAP::PORT,
        :Log => debug
      }

      defaults[:Multicast] = false if defined?(JRuby)

      app = options.delete(:app) || Rack::HelloWorld

      server = David::Server.new(app, defaults.merge(options))
      server.async.run

      server
    end
  end
end

include David
include David::TestHelper
