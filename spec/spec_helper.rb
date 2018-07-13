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

    def ipv4?
      @ipv4 ||= !ENV['IPV4'].nil?
    end

    def localhost
      ipv4? ? '127.0.0.1' : '::1'
    end

    def random_port
      rand((2**10+1)..(2**16-1))
    end

    def req(method, path, options = {})
      mid = rand(0xffff) unless respond_to?(:mid)

      payload = options.delete(:payload)
      port    = options.delete(:port) || random_port
      host    = ipv4? ? '127.0.0.1' : '::1'

      options.merge!(mid: mid)

      client = CoAP::Client.new(retransmit: false, recv_timeout: 0.1,
        token: false)

      response = client.send(method, path, host, port, payload, options)

      [mid, response]
    end

    def supervised_server(options)
      defaults = {
        :Host => localhost,
        :Port => CoAP::PORT,
        :Log => debug
      }

      defaults[:Multicast] = false if defined?(JRuby)

      app = options.delete(:app) || Rack::HelloWorld

      g = Celluloid::Supervision::Container.run!

      g.supervise(as: :server_udp, type: ::David::Server::CoAP,
        args: [app, defaults.merge(options)])

      g.supervise(as: :gc, type: ::David::GarbageCollector)

      unless options[:Observe] == 'false'
        g.supervise(as: :observe, type: ::David::Observe)
      end

      Celluloid::Actor[:server_udp].async.run

      g 
    end
  end
end

include David
include David::TestHelper
