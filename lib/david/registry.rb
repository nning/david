require 'david/fake_logger'

module David
  module Registry
    protected

    def log
      @log ||= server.log
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

    def server
      Celluloid::Actor[:server]
    end
  end
end
