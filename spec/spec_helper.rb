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
require 'david/etsi'

module David
  module TestHelper
    def debug
      @debug ||= ENV['DEBUG'].nil? ? 'none' : 'debug'
    end

    def random_port
      rand((2**10+1)..(2**16-1))
    end

    def req(method, path, options = {})
      mid = rand(0xffff) unless respond_to?(:mid)
      port = random_port unless respond_to?(:port)

      payload = options.delete(:payload)
      options.merge!(mid: mid)

      client = CoAP::Client.new(retransmit: false, recv_timeout: 0.1,
        token: false)

      response = client.send(method, path, '::1', nil, payload, options)

      [mid, response]
    end

    def supervised_server(options)
      defaults = {
        :Host => '::1',
        :Port => CoAP::PORT,
        :Log => debug
      }

      defaults[:Multicast] = false if defined?(JRuby)

      app = options.delete(:app) || Rack::HelloWorld

      g = Celluloid::SupervisionGroup.run!

      g.supervise_as(:server, ::David::Server, app, defaults.merge(options))
      g.supervise_as(:gc, ::David::GarbageCollector)

      unless options[:Observe] == 'false'
        g.supervise_as(:observe, ::David::Observe)
      end

      Celluloid::Actor[:server].async.run

      g 
    end
  end
end

include David
include David::TestHelper
