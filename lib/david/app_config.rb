module David
  class AppConfig < Hash
    DEFAULT_OPTIONS = {
      :Block => true,
      :CBOR => false,
      :DefaultFormat => 'application/json',
      :Host => ENV['RACK_ENV'] == 'development' ? '::1' : '::',
      :Log => nil,
      :MinimalMapping => false,
      :Multicast => true,
      :MulticastGroups => ['ff02::fd', 'ff05::fd'],
      :Observe => true,
      :Port => ::CoAP::PORT
    }

    def initialize(hash = {})
      self.merge!(DEFAULT_OPTIONS)
      self.merge!(hash)

      (self.keys & DEFAULT_OPTIONS.keys).each do |key|
        optionize!(key)
      end
    end

    private

    def choose_block(value)
      default_to_true(:block, value)
    end

    def choose_cbor(value)
      default_to_false(:cbor, value)
    end

    def choose_defaultformat(value)
      value = from_rails(:default_format)
      return nil if value.nil?
      value
    end

    # Rails starts on 'localhost' since 4.2.0.beta1
    # (Resolv class seems not to consider /etc/hosts)
    def choose_host(value)
      return nil if value.nil?
      Socket::getaddrinfo(value, nil, nil, Socket::SOCK_STREAM)[0][3]
    end

    def choose_log(value)
      log = ::Logger.new($stderr)
      value = value.to_s

      log.level = ::Logger::INFO
      log.level = ::Logger::DEBUG if value == 'debug'
      log.level = ::Logger::FATAL if value == 'none'

      log.formatter = proc do |sev, time, prog, msg|
        "#{time.strftime('[%Y-%m-%d %H:%M:%S]')} #{sev}  #{msg}\n"
      end

      Celluloid.logger = log

      log
    end

    def choose_minimalmapping(value)
      value
    end

    def choose_multicast(value)
      default_to_true(:multicast, value)
    end

    def choose_multicastgroups(value)
      from_rails(:multicast_groups) || value
    end

    def choose_observe(value)
      default_to_true(:observe, value)
    end

    def choose_port(value)
      value.nil? ? nil : value.to_i
    end

    def default_to_false(key, value)
      return true if value.to_s == 'true'

      r = from_rails(key)
      return r unless r.nil? || value == 'false'

      false
    end

    def default_to_true(key, value)
      return false if value.to_s == 'false'

      r = from_rails(key)
      return r unless r.nil? || value == 'true'

      true
    end

    def from_rails(key)
      if defined?(Rails) && !Rails.application.nil?
        Rails.application.config.coap.send(key)
      end
    end

    def optionize!(key)
      method = ('choose_' << key.to_s.downcase).to_sym
      value = self.send(method, self[key])
      self[key] = value unless value.nil?
    end
  end
end
