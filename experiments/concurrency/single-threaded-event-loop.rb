require 'celluloid'
require 'coap'
require 'david'

class Listener
  include Celluloid::IO
  include David::Server::Respond

  def initialize(socket)
    @socket = socket
    @cache = {}
    @app = Rack::HelloWorld.new
    @block = true
    @observe = true
  end

  def run
    loop do
      begin
        data, sender, _, anc = @socket.to_io.recvmsg_nonblock
      rescue ::IO::WaitReadable
        Celluloid::IO.wait_readable(@socket)
        retry
      end

      host, port = sender.ip_address, sender.ip_port

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

socket = UDPSocket.new(Socket::AF_INET6)
socket.bind('::1', 5683)

trap('EXIT') { socket.close }

#l = Listener.pool(size: 100, args: [socket])
l = Listener.new(socket)
l.run

Process.waitall
