module David
  class Server
    module Options
      protected

      def choose(name, value)
        send(('choose_' + name.to_s).to_sym, value)
      end

      def choose_block(value)
        default_to_true(:block, value)
      end

      def choose_cbor(value)
        if value.nil? && defined? Rails
          value = Rails.application.config.coap.cbor
        end

        !!value
      end

      def choose_default_format(value)
        if value.nil? && defined? Rails
          value = Rails.application.config.coap.default_format
        end

        value.nil? ? 'application/json' : value
      end

      # Rails starts on 'localhost' since 4.2.0.beta1
      # (Resolv class seems not to consider /etc/hosts)
      def choose_host(value)
        Socket::getaddrinfo(value, nil, nil, Socket::SOCK_STREAM)[0][3]
      end

      def choose_logger(log)
        fd = $stderr
        level = ::Logger::INFO

        case log
        when 'debug'
          level = ::Logger::DEBUG
        when 'none'
          fd = File.open('/dev/null', 'w')
        end

        logger = ::Logger.new(fd)
        logger.level = level
        logger.formatter = proc do |sev, time, prog, msg|
          "#{time.strftime('[%Y-%m-%d %H:%M:%S]')} #{sev}  #{msg}\n"
        end

        Celluloid.logger = logger

        logger
      end

      def choose_mcast(value)
        default_to_true(:multicast, value)
      end

      def choose_observe(value)
        default_to_true(:observe, value)
      end

      def default_to_true(key, value)
        if value.nil? && defined? Rails
          value = Rails.application.config.coap.send(key)
        end

        return true if value.nil? || value.to_s == 'true'

        false
      end

      module_function :default_to_true
    end
  end
end
