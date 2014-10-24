require 'celluloid/io'
require 'ipaddr'
require 'socket'

ifname, af = ARGV

ifname ||= 'lo'
af     ||= 'inet6'

ifaddr  = Socket.getifaddrs.select { |x| x.name == ifname }.first
ifindex = ifaddr.ifindex

if af == 'inet6'
  maddr = 'ff02::fd'
# maddr = 'ff05::fd'

  mreq = IPAddr.new(maddr).hton + [ifindex].pack('i_')

  sock = Celluloid::IO::UDPSocket.new(Socket::AF_INET6)
  sock.to_io.setsockopt(Socket::IPPROTO_IPV6, Socket::IPV6_JOIN_GROUP, mreq)
else
  maddr = '224.0.1.187'

  # Ignore interface for now.
  mreq = IPAddr.new(maddr).hton + IPAddr.new('0.0.0.0').hton

  sock = Celluloid::IO::UDPSocket.new
  sock.to_io.setsockopt(Socket::IPPROTO_IP, Socket::IP_ADD_MEMBERSHIP, mreq)
end

puts `netstat -g`

if af == 'inet6'
  sock.to_io.setsockopt(Socket::IPPROTO_IPV6, Socket::IPV6_LEAVE_GROUP, mreq)
else
  sock.to_io.setsockopt(Socket::IPPROTO_IP, Socket::IP_DROP_MEMBERSHIP, mreq)
end
