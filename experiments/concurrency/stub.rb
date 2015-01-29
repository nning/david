require 'celluloid'
require 'coap'
require 'david'

class Listener
  include David::Server::Respond

  def initialize(mode, socket, cache)
    @mode = mode
    @socket = socket
    @cache = cache
    @app = Rack::HelloWorld.new
    @block = true
    @observe = true
  end

  def run
    loop do
      if defined?(JRuby) || @mode == :prefork || @mode == :threaded
        data, sender = @socket.recvfrom(1152)
        port, _, host = sender[1..3]
      else
        begin
          data, sender, _, anc = @socket.to_io.recvmsg_nonblock
        rescue ::IO::WaitReadable
          Celluloid::IO.wait_readable(@socket)
          retry
        end

        host, port = sender.ip_address, sender.ip_port
      end

      message = CoAP::Message.parse(data)
      exchange = David::Exchange.new(host, port, message, anc)

      return if !exchange.non? && exchange.multicast?
      
      key = exchange.key
      cached = @cache[key]

      if exchange.ack? && !cached.nil?
        @cache.delete(key)
      elsif exchange.request?
        if exchange.con? && !cached.nil?
          response = cached[0]
        else
          response, _ = respond(exchange)
        end
      end

      unless response.nil?
        @socket.send(response.to_wire, 0, host, port)

        if !cached.nil?
          cached[1] = Time.now.to_i
        elsif exchange.reliable?
          @cache[[host, response.mid]] = [response, Time.now.to_i]
        end
      end
    end
  end
end


trap('EXIT') { socket.close }

cache = {}

case ARGV[0]
  when 'prefork'
    # ~33000
    socket = UDPSocket.new(Socket::AF_INET6)
    socket.bind('::', 5683)
    4.times { fork { Listener.new(:prefork, socket, cache).run } }
  when 'threaded'
    # ~16000
    socket = UDPSocket.new(Socket::AF_INET6)
    socket.bind('::', 5683)
    Listener.send(:include, Celluloid)
    Listener.pool(size: 8, args: [:threaded, socket, cache]).run
  else
    # ~14000
    socket = Celluloid::IO::UDPSocket.new(Socket::AF_INET6)
    socket.bind('::', 5683)
    Listener.new(:sped, socket, cache).run
end

Process.waitall
