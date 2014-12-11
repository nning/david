class Request < Struct.new(:host, :port, :message, :ancillary, :options)
  def accept
    message.options[:accept]
  end

  def block
    @block ||= if message.options[:block2].nil?
      CoAP::Block.new(0, false, 1024)
    else
      CoAP::Block.new(message.options[:block2]).decode
    end
  end

  def con?
    message.tt == :con
  end

  def delete?
    message.mcode == :delete
  end

  def etag
    message.options[:etag]
  end

  def get_etag?
    message.options[:etag].nil? && get?
  end

  def get?
    message.mcode == :get
  end

  def idempotent?
    get? || put? || delete?
  end

  def mid
    message.mid
  end

  def multicast?
    a = ancillary
    return false if a.nil?

    return @multicast unless @multicast.nil?

    @multicast =
      a.cmsg_is?(:IP, :PKTINFO) && a.ip_pktinfo[0].ipv4_multicast? ||
      a.cmsg_is?(:IPV6, :PKTINFO) && a.ipv6_pktinfo[0].ipv6_multicast?
  end

  def non?
    message.tt == :non
  end

  def observe?
    !message.options[:observe].nil?
  end

  def post?
    message.mcode == :post
  end

  def put?
    message.mcode == :put
  end

  def token
    message.options[:token]
  end

  def valid_method?
    CoAP::METHODS.include?(message.mcode)
  end
end
