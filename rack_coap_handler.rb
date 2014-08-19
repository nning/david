require 'bundler/setup'
Bundler.require

require 'ipaddr'
require 'pp'

include CoRE

class Rack::HelloWorld
  def call(env)
    [200, {'Content-Type' => 'text/plain'}, 'Hello World!']
  end
end

class CoRE::CoAP::ExampleServer
  include Celluloid::IO
  include CoAP::Codification

  finalizer :shutdown

  def initialize(host, port, app, options)
    puts "Starting on [#{host}]:#{port}."

    ipv6 = IPAddr.new(host).ipv6?
    af = ipv6 ? ::Socket::AF_INET6 : ::Socket::AF_INET

    # Actually Celluloid::IO::UDPServer.
    # (Use celluloid-io from git, 0.15.0 does not support AF_INET6).
    @socket = UDPSocket.new(af)
    @socket.bind(host, port.to_i)

    @host, @port, @app = host, port, app

    async.run
  end

  def shutdown
    @socket.close unless @socket.nil?
  end

  def run
    loop { async.handle_input(*@socket.recvfrom(1024)) }
  end

  private

  def answer(host, port, message)
    @socket.send(message.to_wire, 0, host, port)
  end

  def app_response(request, response)
pp  env = basic_env(request)

    code, options, body = @app.call(env)

    response.mcode = http_to_coap_code(code)
    response.payload = body

    response
  end

  def basic_env(request)
    {
      'REQUEST_METHOD'    => coap_to_http_method(request.mcode),
      'SCRIPT_NAME'       => '',
      'PATH_INFO'         => path_encode(request.options[:uri_path]),
      'QUERY_STRING'      => query_encode(request.options[:uri_query])
                               .gsub(/^\?/, ''),
      'SERVER_NAME'       => @host,
      'SERVER_PORT'       => @port.to_s,
      'CONTENT_LENGTH'    => request.payload.size.to_s,
      'rack.version'      => [1, 2],
      'rack.url_scheme'   => 'http',
      'rack.input'        => StringIO.new(request.payload),
      'rack.errors'       => $stderr,
      'rack.multithread'  => true,
      'rack.multiprocess' => true,
      'rack.run_once'     => false,
    }
  end

  def coap_to_http_method(method)
    method.to_s.upcase
  end

  def handle_input(data, sender)
    _, port, host = sender
    puts "Received data from [#{host}]:#{port}:"

pp  request = CoAP::Message.parse(data)

    response = initialize_response(request)
    response = app_response(request, response)

    answer(host, port, response)
  end

  def http_to_coap_code(code)
    a = code / 100
    b = code - (a * 100)

    [a, b]
  end

  def initialize_response(request)
    CoAP::Message.new \
      tt: :ack,
      mcode: 2.00,
      mid: SecureRandom.random_number(999),
      token: request.options[:token]
  end
end

module Rack
  module Handler
    class CoAPExample
      def self.run(app, options={})
        environment = ENV['RACK_ENV'] || 'development'
        default_host = environment == 'development' ? '::1' : '::'

        host = options.delete(:host) || default_host
        port = options.delete(:port) || CoAP::PORT

        args = [host, port, app, options]

        CoAP::ExampleServer.run(*args)
      end

      def self.valid_options
        environment = ENV['RACK_ENV'] || 'development'
        default_host = environment == 'development' ? '::1' : '::'

        {
          'host=HOST' => "Hostname to listen on (default: #{default_host})",
          'port=PORT' => "Port to listen on (default: #{CoAP::PORT})",
        }
      end
    end
  end
end

klass = Rack::HelloWorld.new
klass = Rack::Lint.new(klass) if ARGV.first == '-d'

Rack::Handler::CoAPExample.run(klass)
