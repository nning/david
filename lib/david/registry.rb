require 'david/fake_logger'

module David
  module Registry
    protected

    def log
      @log ||= Celluloid.logger
    # In some tests no server actor is present
    rescue NoMethodError
      @log ||= FakeLogger.new
    end

    # def gc
    #   Celluloid::Actor[:gc]
    # end

    def observe
      # Supervision is only initialized from here in tests.
      Observe.supervise(as: :observe) if Celluloid::Actor[:observe].nil?
      Celluloid::Actor[:observe]
    end

    def servers
      server_udp  = Celluloid::Actor[:server_udp]
      server_dtls = Celluloid::Actor[:server_dtls]

      servers = []
      [:server_udp, :server_dtls].each do |key|
        server = Celluloid::Actor[key]
        unless server.nil?
          servers << server
        end
      end

      servers
    end
  end
end
