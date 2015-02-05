module David
  module Registry
    protected

    def log
      @log ||= server.log
    end

    def gc
      Celluloid::Actor[:gc]
    end

    def observe
      Celluloid::Actor[:observe]
    end

    def server
      Celluloid::Actor[:server]
    end
  end
end
