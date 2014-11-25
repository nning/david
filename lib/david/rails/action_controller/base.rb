class ActionController::Base
  def self.discovery(options)
    discovery_actor.register(self, options)
  end

  protected

  def self.discovery_actor
    Celluloid::Actor[:discovery]
  end
end
