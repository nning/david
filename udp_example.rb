require 'bundler/setup'
Bundler.require

class UDPExample
  include Celluloid::IO
  finalizer :shutdown

  def initialize(host, port)
    puts "Starting on [#{host}]:#{port}."

    # Actually Celluloid::IO::UDPServer.
    # (Use celluloid-io from git, 0.15.0 does not support AF_INET6).
    @socket = UDPSocket.new(::Socket::AF_INET6)
    @socket.bind(host, port.to_i)

    async.run
  end

  def shutdown
    @socket.close unless @socket.nil?
  end

  def run
    loop { async.handle_input(*@socket.recvfrom(1024)) }
  end

  private

  def handle_input(data, sender)
    _, port, host = sender
    $stderr << "Received data from [#{host}]:#{port}:\n"
    puts data
  end
end

if ARGV.size != 2
  $stderr << "#{File.basename(__FILE__)} <host> <port>\n"
  exit 1
end

UDPExample.run(*ARGV)
