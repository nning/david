require 'coap'
require 'david'

socket = UDPSocket.new(Socket::AF_INET6)
socket.bind('::1', 5683)

trap('EXIT') { socket.close }

10.times do
  fork do
    loop do
      data, sender  = socket.recvfrom(1152)
      port, _, host = sender[1..3]

      message = CoAP::Message.parse(data)
      exchange = David::Exchange.new(host, port, message)

      if exchange.con? && exchange.get? && message.options[:uri_path] == ['hello']
        response = CoAP::Message.new(1, :ack, [2, 5], message.mid, {}, 'Hello World!')
      else
        response = CoAP::Message.new(1, :ack, [4, 5], message.mid, {}, nil)
      end

      socket.send(response.to_wire, 0, host, port)
    end
  end
end

Process.waitall
