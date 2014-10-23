module David
  class Server
    module Options
      protected

      def choose(name, value)
        send(('choose_' + name.to_s).to_sym, value)
      end

      def choose_block(value)
        if value.nil? && defined? Rails
          value = Rails.application.config.coap.block
        end

        value.nil? ? true : !!value
      end

      def choose_cbor(value)
        if value.nil? && defined? Rails
          value = Rails.application.config.coap.cbor
        end

        !!value
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
    end
  end
end
