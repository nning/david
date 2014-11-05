class Request < Struct.new(:host, :port, :message)
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

  def etag
    message.options[:etag]
  end

  def get_etag?
    message.options[:etag].nil? && get?
  end

  def get?
    message.mcode == :get
  end

  def non?
    message.tt == :non
  end

  def observe?
    !message.options[:observe].nil?
  end

  def token
    message.options[:token]
  end

  def valid_method?
    CoAP::METHODS.include?(message.mcode)
  end
end
