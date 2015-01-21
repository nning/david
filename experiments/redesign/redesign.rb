require 'celluloid'
require 'celluloid/io'

require 'coap'
require 'david'

class Exchange < David::Request
  def initialize(*args)
    @logger = Celluloid.logger
    super(*args)
  end

  def initialize_response(mcode = 2.05)
    type = con? ? :ack : :non

    CoAP::Message.new \
      tt: type,
      mcode: mcode,
      mid: message.mid || SecureRandom.random_number(0xffff),
      token: token
  end

  def transmit
    @logger.debug(inspect)
    server.socket.send(message.to_wire, 0, host, port)
    mid_cache.add(self)
  end

  def ==(other)
    mid == other.mid && token == other.token
  end

  private

  def mid_cache
    Celluloid::Actor[:mid_cache]
  end

  def server
    Celluloid::Actor[:server]
  end
end

class MidCache
  include Celluloid

  def initialize
    @cache = {}
  end

  def add(exchange)
    @cache[exchange.mid] = exchange
  end

  def delete(mid)
    @cache.delete(mid)
  end

  def lookup(mid)
    @cache[mid]
  end

  def present?(mid)
    !lookup(mid).nil?
  end
end

class Server
  include Celluloid::IO

  finalizer :shutdown

  attr_reader :socket

  def initialize
    @socket = UDPSocket.new(::Socket::AF_INET6)
    @socket.to_io.setsockopt(:SOCKET, :REUSEADDR, true)
    @socket.bind('::', CoAP::PORT)
    
    link(mid_cache)

    @logger = Celluloid.logger

    async.run
  end

  private

  def dispatch(*args)
    data, sender = args
    port, _, host = sender[1..3]

    message  = CoAP::Message.parse(data)
    exchange = Exchange.new(host, port, message)

    @logger.debug exchange.to_s
    @logger.debug exchange.inspect

    if mid_cache.present?(message.mid) && exchange.ack?
      mid_cache.delete(message.mid)
      handle_response(exchange)
    else
      handle_request(exchange)
    end
  end

  def handle_request(exchange)
    if exchange.post?
      @temp = exchange

      message  = CoAP::Message.new(tt: :con, mcode: :get, mid: 42, token: 42, uri_path: ['hello'])
      exchange = Exchange.new('coap.me', CoAP::PORT, message)
    else
      exchange.message = exchange.initialize_response(4.00)
    end

    exchange.transmit
  end

  def handle_response(exchange)
    exchange.message.mid = @temp.mid
    exchange.message.options[:token] = @temp.token

    @temp.message = exchange.message

    @temp.transmit
  end

  def mid_cache
    Celluloid::Actor[:mid_cache] || MidCache.supervise_as(:mid_cache)
  end

  def run
    loop { async.dispatch(*@socket.recvfrom(1152)) }
  end

  def shutdown
    @socket.close unless @socket.nil?
  end
end

Server.supervise_as(:server)

sleep
