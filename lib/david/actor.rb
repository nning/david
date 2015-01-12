module David
  module Actor
    def self.included(base)
      base.include Celluloid
    end

    protected

    def log
      @log ||= Celluloid.logger 
      @log ||= ::Logger.new(nil)
    end

    def server
      Celluloid::Actor[:server]
    end
  end
end
